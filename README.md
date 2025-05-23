# Blender Post Import

A post-import script for Blender files in Godot 4 that dynamically links Blender scenes together (to remove duplicate data) and injects Godot scenes as child nodes (for interactivity).

### How it works

The script works by scanning your Blender file for any node name ending in `-link`.

If a "link node" is found, the script will use the name of the node to find a matching `.tscn` or `.blend` file in your Godot project.

If a matching "linked scene" is found, the script will inject it into your imported Blender scene as an external resource.

### Instructions

1. Create a Godot project
2. Copy this script into your Godot project. I recommend placing it in `addons/godot_blender_post_import/`
3. Create a Blender file with some reusable content inside your Godot project. Let's call it `file1.blend`
4. Create another Blender file in your Godot project called `file2.blend`.
  a. Go to `File > Link...` and choose `file1.blend > collections > Scene collection`
  b. Create an empty called `file1-link`
  c. Go to `file1-link > Object Properties > Instancing` and choose `Collection > Scene collection [file1.blend]`
5. Open Godot and wait for Godot to import both Blender files
6. Double click `file2.blend` in the Godot FileSystem to open import settings.
  a. Set `Import Script` to `addons/godot_blender_post_import/blender_post_import.gd`
  b. Click `Reimport`
  c. Wait for Godot to finish
7. Right click `file2.blend` and choose `New Inherited Scene`
8. Observe that the `file1-link` node now contains a scene link to `file2.blend`
