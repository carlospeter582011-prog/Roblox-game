#!/usr/bin/env python3
"""Generate an original, lightweight cloud GLB; no third-party asset licensing."""
import argparse
import pathlib
import trimesh

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("output", nargs="?", default="assets/original-cloud.glb")
    args = parser.parse_args()
    scene = trimesh.Scene()
    for i, (center, scale) in enumerate([
        ((-1.35, 0.0, 0.0), (1.35, .82, 1.0)),
        ((0.0, .25, 0.0), (1.6, 1.05, 1.15)),
        ((1.3, .05, .0), (1.25, .85, 1.0)),
        ((-.35, .7, -.12), (1.1, .8, .9)),
        ((.85, .6, .1), (.95, .75, .9)),
    ]):
        mesh = trimesh.creation.icosphere(subdivisions=2)
        mesh.apply_scale(scale)
        mesh.apply_translation(center)
        mesh.visual.vertex_colors = [218, 243, 255, 255]
        scene.add_geometry(mesh, node_name=f"cloud_puff_{i}")
    output = pathlib.Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    data = scene.export(file_type="glb")
    assert data[:4] == b"glTF" and len(data) < 20_000_000
    output.write_bytes(data)
    print(f"Generated original cloud GLB ({len(data)} bytes): {output}")

if __name__ == "__main__":
    main()
