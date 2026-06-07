#!/usr/bin/env python3
"""Embed a Lottie/Bodymovin export's external PNGs as base64 data-URIs so the
animation becomes a single self-contained .json (no `images/` folder needed at
runtime). Re-run this after each After Effects re-export.

Usage:
    python3 embed_kiran_lottie.py [INPUT_JSON] [OUTPUT_JSON]

Defaults:
    INPUT_JSON  = ./data.json
    OUTPUT_JSON = ./date-the-sun/Resources/Animations/<comp-name>.json

Each asset's images are read from the folder named by its `u` field
(typically `images/`), resolved relative to INPUT_JSON. If that path is missing
it falls back to an `images/` folder next to this script.
"""
import base64
import json
import os
import sys


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    inp = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.join(here, "data.json")
    base = os.path.dirname(inp)

    with open(inp, "r") as f:
        anim = json.load(f)

    embedded = 0
    for asset in anim.get("assets", []):
        p = asset.get("p")
        if not p or p.startswith("data:"):
            continue  # vector asset, or already embedded
        folder = asset.get("u", "") or ""
        img_path = os.path.join(base, folder, p)
        if not os.path.isfile(img_path):
            img_path = os.path.join(here, "images", p)  # fallback
        with open(img_path, "rb") as imgf:
            raw = imgf.read()
        ext = os.path.splitext(p)[1].lower().lstrip(".")
        mime = "jpeg" if ext in ("jpg", "jpeg") else ext
        asset["p"] = "data:image/%s;base64,%s" % (mime, base64.b64encode(raw).decode("ascii"))
        asset["u"] = ""
        asset["e"] = 1
        embedded += 1

    name = anim.get("nm", "animation")
    default_out = os.path.join(here, "date-the-sun", "Resources", "Animations", name + ".json")
    out = os.path.abspath(sys.argv[2]) if len(sys.argv) > 2 else default_out
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w") as f:
        json.dump(anim, f, separators=(",", ":"))

    print("Embedded %d image(s)." % embedded)
    print("  in : %s (%.0f KB)" % (inp, os.path.getsize(inp) / 1024))
    print("  out: %s (%.0f KB)" % (out, os.path.getsize(out) / 1024))


if __name__ == "__main__":
    main()
