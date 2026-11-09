#!/usr/bin/env python3
"""Audit Roblox source for 2D world stand-ins without banning legitimate GUI."""
from __future__ import annotations
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src"
WORLD_2D = re.compile(r'Instance\.new\s*\(\s*["\'](CanvasGroup|ScreenGui|ImageLabel|ImageButton|BillboardGui|SurfaceGui)["\']\s*\)')
WORLD_3D = re.compile(r'Instance\.new\s*\(\s*["\'](Model|MeshPart|Part|WedgePart|UnionOperation|Terrain|SpawnLocation)["\']\s*\)')
UI_CLASSES = re.compile(r'Instance\.new\s*\(\s*["\'](CanvasGroup|ScreenGui|ImageLabel|ImageButton|BillboardGui|SurfaceGui)["\']\s*\)')
FORBIDDEN_WORLD_MARKER = re.compile(r'--\s*WORLD_OBJECT_2D_STANDIN\b')
world_paths = []
ui_paths = []
findings = []
for file in sorted(SOURCE.rglob("*.luau")):
    text = file.read_text(encoding="utf-8")
    rel = file.relative_to(ROOT).as_posix()
    is_client = rel.startswith("src/client/")
    is_server = rel.startswith("src/server/")
    d3 = sorted(set(WORLD_3D.findall(text)))
    d2 = sorted(set(UI_CLASSES.findall(text)))
    if is_server:
        world_paths.append((rel, d3, d2))
        if d2:
            findings.append(f"{rel}: GUI constructor in server world script ({', '.join(d2)}); review placement")
    elif is_client:
        ui_paths.append((rel, d2))
    if FORBIDDEN_WORLD_MARKER.search(text):
        findings.append(f"{rel}: explicit 2D world-object stand-in marker")
if not world_paths:
    findings.append("No server-side world scripts found")
if not any(classes for _, classes, _ in world_paths):
    findings.append("No server-side 3D instance constructors found")
print("# Catch a Cloud — source-level 3D world audit")
print("\n## Server source (3D constructors; GUI constructors)")
for rel, d3, d2 in world_paths:
    print(f"- {rel}: 3D={','.join(d3) or 'none'}; GUI={','.join(d2) or 'none'}")
print("\n## Client UI (allowed 2D constructors)")
for rel, d2 in ui_paths:
    print(f"- {rel}: {','.join(d2) or 'none'}")
print("\n## Review findings")
if findings:
    for item in findings:
        print(f"- {item}")
else:
    print("- No server-side GUI constructors or explicit 2D world stand-ins found.")
print("\nLimits: static source audit only; cannot prove in-game rendering or inspect dynamic asset contents.")
if findings:
    sys.exit(1)
