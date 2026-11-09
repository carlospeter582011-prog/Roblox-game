#!/usr/bin/env python3
"""Upload a user-owned GLB model to Roblox Open Cloud. Never print credentials."""
import json, os, pathlib, sys, time, urllib.request, urllib.error
asset = pathlib.Path(sys.argv[1] if len(sys.argv)>1 else "assets/sports-car.glb")
key=os.environ.get("ROBLOX_API_KEY","")
user=os.environ.get("ROBLOX_CREATOR_USER_ID","")
if not asset.is_file():
    sys.exit(f"Missing {asset}. Add a licensed GLB file before running.")
if not key or not user.isdecimal():
    sys.exit("Configure ROBLOX_API_KEY (asset:write permission) and ROBLOX_CREATOR_USER_ID.")
data=asset.read_bytes()
if not data.startswith(b"glTF"):
    sys.exit("File is not a binary glTF/GLB.")
if len(data)>20_000_000:
    sys.exit("GLB exceeds 20 MB.")
request={"assetType":"Model","displayName":"Sports Car Test","description":"Sports car visual for test experience","creationContext":{"creator":{"userId":user}}}
boundary="----RobloxSportsCarUpload"
def part(name,body,ctype=None):
    h=f"--{boundary}\r\nContent-Disposition: form-data; name=\"{name}\""
    if name=="fileContent":h+='; filename="sports-car.glb"'
    h+="\r\n"
    if ctype:h+=f"Content-Type: {ctype}\r\n"
    return h.encode()+b"\r\n"+body+b"\r\n"
body=part("request",json.dumps(request,separators=(",",":")).encode())+part("fileContent",data,"model/gltf-binary")+f"--{boundary}--\r\n".encode()
def call(url,method="GET",body=None,content_type=None):
    headers={"x-api-key":key}
    if content_type:headers["Content-Type"]=content_type
    req=urllib.request.Request(url,data=body,headers=headers,method=method)
    try:
        with urllib.request.urlopen(req,timeout=60) as r:return json.load(r)
    except urllib.error.HTTPError as e:
        # Print only known-safe structured error fields, never raw response,
        # credentials, request headers or untrusted arbitrary strings.
        try:
            details=json.loads(e.read(8192).decode("utf-8"))
        except (ValueError,UnicodeError):
            details={}
        codes=[]
        messages=[]
        if isinstance(details,dict):
            for item in details.get("errors",[]) if isinstance(details.get("errors"),list) else []:
                if isinstance(item,dict):
                    code=item.get("code")
                    msg=item.get("message")
                    if isinstance(msg,str) and len(msg)<240 and not any(s in msg.lower() for s in ("key", "token", "secret", "authorization")):
                        messages.append(msg)
                    if isinstance(code,(int,str)) and len(str(code))<80:
                        codes.append(str(code))
            msg=details.get("message")
            if isinstance(msg,str) and len(msg)<240 and not any(s in msg.lower() for s in ("key", "token", "secret", "authorization")):
                messages.append(msg)
            for field in ("code","status"):
                value=details.get(field)
                if isinstance(value,(int,str)) and len(str(value))<80:
                    codes.append(str(value))
        print(f"Roblox API {method} HTTP {e.code}; error codes: {', '.join(codes) or 'not supplied'}; messages: {'; '.join(messages) or 'not supplied'}",file=sys.stderr)
        sys.exit("Upload rejected. Check creator ownership, API key validity, account restrictions, and request format.")
op=call("https://apis.roblox.com/assets/v1/assets","POST",body,f"multipart/form-data; boundary={boundary}")
path=op.get("path","")
if not path.startswith("operations/"):sys.exit("No operation ID returned by Roblox.")
for attempt in range(24):
    result=call("https://apis.roblox.com/assets/v1/"+path)
    if result.get("done"):
        asset_id=result.get("response",{}).get("path","")
        if not asset_id.startswith("assets/"):sys.exit("Asset upload failed or was rejected by moderation.")
        print("Uploaded model:",asset_id)
        pathlib.Path("uploaded-sports-car-id.txt").write_text(asset_id.split("/")[-1]+"\n")
        break
    time.sleep(5)
else:sys.exit("Upload still processing; check Roblox asset operation later.")
