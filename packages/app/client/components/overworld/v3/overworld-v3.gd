@tool
extends Node2D

@export var _tile_set : TileSet
@export var _tile_map_layer_offset := Vector2i(0, 0)

func _ready() -> void:
	if Engine.is_editor_hint():
		if is_connected('child_entered_tree', _on_child_entered_tree):
			Log.trace(self, "Signal 'child_entered_tree' is connected")
		else:
			Log.trace(self, "Connect to 'child_entered_tree' signal")
			connect("child_entered_tree", _on_child_entered_tree)

func _on_child_entered_tree(node: Node):
	Log.event(self, "Detect new child in tree (%s.%s)" % [node.get_parent().name, node.name])
	#tile_map_layer_node_on_update(node)
