@tool
extends Node2D

@export var _tile_set : TileSet
@export var _tile_map_layer_offset := Vector2(0, 0)
@export var _tile_map_layer_containers: Array[Node2D]:
	set(value):
		Log.event(self, "Detect tile map layer containers change %s -> %s " % [_tile_map_layer_containers, value])
		_tile_map_layer_containers = value
		if Engine.is_editor_hint():
			tile_map_layer_container_init()

@export_tool_button("Update") 
var tile_map_layer_update_button = tile_map_layer_container_update

func tile_map_layer_container_init():
	for container in _tile_map_layer_containers:
		if container.is_connected('child_entered_tree', tile_map_layer_node_on_child_entered_tree):
			Log.trace(self, "[%s] Signal 'child_entered_tree' is connected" % container.name)
		else:
			Log.trace(self, "[%s] Connect to 'child_entered_tree' signal" % container.name)
			container.connect("child_entered_tree", tile_map_layer_node_on_child_entered_tree)
		
		#if container.is_connected('renamed', tile_map_layer_container_on_renamed):
			#Log.trace(self, "[%s] Signal 'renamed' is connected" % [container.name])
		#else:
			#Log.trace(self, "[%s] Connect to 'renamed' signal" % [container.name])
			#container.connect("renamed", tile_map_layer_container_on_renamed)
		
	if is_node_ready():
		tile_map_layer_container_update()

func tile_map_layer_container_update():
	for container in _tile_map_layer_containers:
		if not container.is_visible_in_tree(): return
		#tile_map_layer_node_children_sort(container)
		for node in container.find_children("*", "TileMapLayer", true):
			tile_map_layer_node_on_update(node)

func tile_map_layer_node_init(node: Node):
	Log.debug(self, "[%s.%s] Initialize node" % [node.get_parent().name, node.name])
	
	if node.is_connected('child_entered_tree', tile_map_layer_node_on_child_entered_tree):
		Log.trace(self, "[%s] Signal 'child_entered_tree' is connected" % node.name)
	else:
		Log.trace(self, "[%s] Connect to 'child_entered_tree' signal" % node.name)
		node.connect("child_entered_tree", tile_map_layer_node_on_child_entered_tree)
	
	if node.is_connected('renamed', tile_map_layer_node_on_renamed):
		Log.trace(self, "[%s.%s] Signal 'renamed' is connected" % [node.get_parent().name, node.name])
	else:
		Log.trace(self, "[%s.%s] Connect to 'renamed' signal" % [node.get_parent().name, node.name]) 
		node.connect("renamed", tile_map_layer_node_on_renamed)

func tile_map_layer_node_on_child_entered_tree(node: Node):
	Log.event(self, "Detect new child in tree (%s.%s)" % [node.get_parent().name, node.name])
	tile_map_layer_node_on_update(node)

func tile_map_layer_node_on_renamed():
	Log.event(self, "Detect renamed event")
	if is_node_ready():
		tile_map_layer_container_update()

func tile_map_layer_node_on_editor_state_changed():
	Log.event(self, "Detect editor_state_changed event")
	if is_node_ready():
		tile_map_layer_container_update()

func tile_map_layer_node_on_update(node: Node2D):
	tile_map_layer_node_init(node)
	if not node.is_visible_in_tree(): return
	if node is TileMapLayer:
		tile_map_layer_update(node)

#func tile_map_layer_node_children_sort(node: Node):
	#Log.debug(self, "[%s.%s] Sort children" % [node.get_parent().name, node.name])
	#var children = node.get_children()
	#children.sort_custom(func(a, b): return a.name < b.name)
	#print(children)
	##for i in range(children.size()):
		##move_child(children[i], i)

func tile_map_layer_update(node: TileMapLayer):
	Log.debug(self, "[%s.%s] Update node" % [node.get_parent().name, node.name])
	
	var parent_tag = node.get_parent().name.split("_")[-1]
	var parent_z_index = 0
	if parent_tag.begins_with("Z"):
		parent_z_index = int(parent_tag.substr(1))
	
	var node_tag = node.name.split("_")[-1]
	var node_z_index = 0
	if node_tag.begins_with("Z"):
		node_z_index = int(node_tag.substr(1))
	
	var new_z_index = parent_z_index + int(node_z_index)
	var new_position = Vector2(0, new_z_index * _tile_map_layer_offset.y * -1)
	
	node.tile_set = _tile_set
	node.position = new_position
	node.z_index = new_z_index
	node.y_sort_enabled = true
	
	Log.trace(self, "[%s.%s] Updated position at %s with z-index: %s" % [node.get_parent().name, node.name, node.position, node.z_index])
