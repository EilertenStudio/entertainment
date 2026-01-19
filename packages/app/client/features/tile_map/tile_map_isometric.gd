@tool
class_name TileMapIsometric extends TileMapLayer

@export var tile_map_layer_offset := Vector2i(0, 0):
	set(value):
		tile_map_layer_offset = value
		if value and tile_set:
			on_tile_set_origins_update()

func _ready() -> void:
	self.enabled = false
	
	if Engine.is_editor_hint():
		var tile_map_isometric_ancestor := _get_tile_map_isometric_ancestor(self)
		if not tile_map_isometric_ancestor:
			if get_tree().node_added.is_connected(_on_tree_node_added):
				Log.trace(self, "Signal 'tree_node_added' is connected")
			else:
				Log.trace(self, "Connect to 'tree_node_added' signal")
				get_tree().node_added.connect(_on_tree_node_added)
			
			if get_tree().node_renamed.is_connected(_on_tree_node_renamed):
				Log.trace(self, "Signal 'tree_node_renamed' is connected")
			else:
				Log.trace(self, "Connect to 'tree_node_renamed' signal")
				get_tree().node_renamed.connect(_on_tree_node_renamed)
		else:
			_on_tile_map_isometric_ancestor_fetch(tile_map_isometric_ancestor)

func _get_tile_map_isometric_ancestor(node: Node) -> TileMapIsometric:
	Log.event(self, "Looking for TileMapIsometric ancestor")
	var p := node.get_parent()
	while p != null:
		if p is TileMapIsometric:
			return p
		p = p.get_parent()
	return null

func _on_tile_map_isometric_ancestor_fetch(node: TileMapIsometric = null):
	if not node: 
		node = _get_tile_map_isometric_ancestor(self)
		
	Log.event(self, "Fetch data from (%s)" % [node.name])
	self.tile_set = node.tile_set
	self.tile_map_layer_offset = node.tile_map_layer_offset

func _on_tree_node_added(node: Node):
	if is_ancestor_of(node):
		Log.event(self, "Detect child added in tree (%s)" % [node.name])
		if node is TileMapIsometric: _on_tile_map_container_update(node)
		if node is TileMapIsometricLayer: _on_tile_map_layer_update(node)

func _on_tree_node_renamed(node: Node):
	if is_ancestor_of(node):
		Log.event(self, "Detect child renamed in tree (%s)" % [node.name])
		if node is TileMapIsometric: _on_tile_map_container_update(node)
		if node is TileMapIsometricLayer: _on_tile_map_layer_update(node)

func _on_tile_map_container_update(node: TileMapIsometric):
	Log.debug(self, "[%s] Update container" % [node.get_parent().name])
	
	#_on_tile_map_container_children_sort(node)
	
	# == Update children layers
	for layer in node.find_children("*", "TileMapIsometricLayer"):
		_on_tile_map_layer_update(layer)

#func _on_tile_map_container_children_sort(node: TileMapIsometric):
	#Log.debug(self, "[%s] Sort container children" % [node.get_parent().name])
	#var children = node.get_children()
	#children.sort_custom(func(a, b): return a.name < b.name)
	#for i in range(children.size()):
		#move_child(children[i], i)

func _on_tile_map_layer_update(node: TileMapIsometricLayer):
	Log.debug(self, "[%s.%s] Update node" % [node.get_parent().name, node.name])
	
	var parent_tag := node.get_parent().name.split("_")[-1]
	var parent_z_index := 0
	if parent_tag.begins_with("Z"):
		parent_z_index = int(parent_tag.substr(1))
	
	var node_tag := node.name.split("_")[-1]
	var node_z_index := 0
	if node_tag.begins_with("Z"):
		node_z_index = int(node_tag.substr(1))
	
	var new_z_index := parent_z_index + int(node_z_index)
	var new_position := Vector2(0, new_z_index * tile_map_layer_offset.y * -1)
	
	node.tile_set = self.tile_set
	node.position = new_position
	node.z_index = new_z_index
	#node.y_sort_enabled = true
	
	Log.trace(self, "[%s.%s] Updated position at %s with z-index: %s" % [node.get_parent().name, node.name, node.position, node.z_index])

func on_tile_set_origins_update():
	var ts: TileSet = tile_set
	var new_origin = tile_map_layer_offset
	
	# Cicla attraverso tutte le sorgenti del TileSet
	for i in ts.get_source_count():
		var source_id = ts.get_source_id(i)
		var source = ts.get_source(source_id)
		
		if source is TileSetAtlasSource:
			# Cicla attraverso ogni tile nell'atlas
			for j in source.get_tiles_count():
				var tile_id = source.get_tile_id(j)
				var tile_data = source.get_tile_data(tile_id, 0)
				Log.debug(self, "[Tile] %s" % [tile_data])
				tile_data.texture_origin = new_origin
	
	print("Origin aggiornato per tutti i tile.")
