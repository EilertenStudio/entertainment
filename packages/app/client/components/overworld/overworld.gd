@tool
extends Node2D

@export var tile_texture_origin := Vector2(0, 0)
@export var tile_map_containers: Array[Node]:
	set(value):
		tile_map_containers = value
		tile_map_container_init()

func _ready() -> void:
	if Engine.is_editor_hint():
		tile_map_container_init()
		tile_map_layer_tree_init()
		tile_map_layer_tree_update()
	pass

func tile_map_container_init(_trace := false):
	for container in tile_map_containers:
		if not container.is_connected('child_entered_tree', tile_map_container_on_child_update):
			container.connect("child_entered_tree", tile_map_container_on_child_update)

func tile_map_container_on_child_update(node: Node):
	tile_map_layer_child_update(node)

func tile_map_layer_tree_init(_trace := false):
	for node in self.find_children("*", "TileMapLayer", true):
		tile_map_layer_child_init(node, _trace)
	
func tile_map_layer_tree_update(_trace := false):
	for node in self.find_children("*", "TileMapLayer", true):
		tile_map_layer_child_update(node, _trace)
	
func tile_map_layer_child_init(node: TileMapLayer, _trace := false):
	if _trace: print("[Overworld] Connected to 'renamed' signal for %s" % node.name)
	node.connect("renamed", func():
		tile_map_layer_child_update(node, _trace)
	)
	#print("Connected to 'visibility_changed' signal for %s" % node.name)
	#node.connect("visibility_changed", func():
		#tile_map_layer_child_update(node)
	#)
	
func tile_map_layer_child_update(node: Node, _trace := false):
	if _trace: print("[Overworld] Updating TileMapLayer: %s" % node)
	var tags = node.name.split("_");
	var type = tags[-2]
	var new_z_index = int(tags[-1])
	var new_position = Vector2(0, new_z_index * tile_texture_origin.y)
	
	match type:
		"FD":
			new_position.y *= +1
			new_z_index *= -1
		"FU":
			new_position.y *= -1
			new_z_index *= +1
	
	node.position = new_position
	if node is CanvasItem:
		node.z_index = new_z_index
	
	if _trace: print("[Overworld] Updated position for %s at %s with z-index: %s" % [node.name, node.position, node.z_index])
