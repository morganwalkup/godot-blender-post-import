@tool
extends EditorScenePostImport
# A post-import script for Blender files.
# Attempts to identify "link" nodes and hydrate them with their linked resource to de-duplicate content.

# Nodes that contain linked content
var _link_nodes: Array[Node] = []
# Cache for linked resource file paths to avoid repeated searches
var _resource_cache: Dictionary = {}

# Called right after the scene is imported
func _post_import(scene: Node) -> Node:
	# Clear variables when starting a new import
	_link_nodes.clear()
	_resource_cache.clear()
	
	# Find all nodes with "-link" in their names
	find_link_nodes(scene)
	
	# Hydrate each link node
	for node in _link_nodes: hydrate_link_node(node)

	# Return the result
	return scene

# Recursively find all nodes in the scene with "-link" in their names
func find_link_nodes(node: Node):
	if node == null:
		return
	
	# Check for both "-link" and "-link_XXX" patterns
	if "-link" in node.name and (node.name.ends_with("-link") or "-link_" in node.name):
		_link_nodes.append(node)
		return # We don't recurse children of -link nodes
	
	# Recurse children
	for child in node.get_children():
		find_link_nodes(child)

# Hydrate a link node by finding and injecting its linked scene
func hydrate_link_node(node: Node):
	# Get the base name without "-link" or "-link_XXX"
	var base_name = node.name
	if "-link_" in base_name: base_name = base_name.split("-link_")[0]
	else: base_name = base_name.replace("-link", "")
	
	# Find linked resource
	var resource_file = find_and_cache_linked_resource(base_name)

	# Print result of resource file search
	if resource_file.is_empty():
		push_warning("Could not find linked resource for node: " + node.name)
		return
	else:
		print("Found linked resource: " + resource_file)

	# Delete all children of the node
	for child in node.get_children():
		child.queue_free()

	# Import the linked scene
	var linked_scene = load(resource_file)
	var linked_node = linked_scene.instantiate()
	node.add_child(linked_node)
	linked_node.owner = node.owner

# Looks up the linked resource and caches it in the _resource_cache
func find_and_cache_linked_resource(base_name: String):
	# Check cache for the linked resource
	if _resource_cache.has(base_name):
		return _resource_cache[base_name]

	# Else, search for matching .tscn file
	var tscn_name = base_name + ".tscn"
	var tscn_file = find_file("res://", tscn_name)
	if not tscn_file.is_empty():
		_resource_cache[tscn_name] = tscn_file
		return tscn_file

	# Else, search for matching .blend file
	var blend_name = base_name + ".blend"
	var blend_file = find_file("res://", blend_name)
	if not blend_file.is_empty():
		_resource_cache[blend_name] = blend_file
		return blend_file

	# Else, the resource does not exist. Store "" in the cache and return it
	_resource_cache[base_name] = ""
	return ""

# Recursively search for a file in a directory and its subdirectories
func find_file(directory: String, target_name: String) -> String:
	var dir = DirAccess.open(directory)
	if dir == null:
		return ""
	
	# First check files in current directory
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			if file_name == target_name:
				dir.list_dir_end()
				return dir.get_current_dir().path_join(file_name)
		file_name = dir.get_next()
	
	# Then check subdirectories
	dir.list_dir_begin()
	file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir_path = dir.get_current_dir().path_join(file_name)
			var result = find_file(subdir_path, target_name)
			if not result.is_empty():
				dir.list_dir_end()
				return result
		file_name = dir.get_next()

	dir.list_dir_end()
	return ""
