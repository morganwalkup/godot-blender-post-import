# Blender Post Import

A post-import script for Blender files in Godot 4 that dynamically links Blender scenes together (to remove duplicate data) and injects Godot scenes as child nodes (for interactivity).

### How does it work

The script works by scanning your Blender file for any node name ending in `-link`.

If a "link node" is found, the script will use the name of the node to find a matching `.tscn` or `.blend` file in your Godot project.

If a matching "linked scene" is found, the script will inject it into your imported Blender scene as an external resource.
