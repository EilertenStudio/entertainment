class_name TileMapIsometricManager extends Object


#func tile_map_layer_node_children_sort(node: Node):
	#Log.debug(self, "[%s.%s] Sort children" % [node.get_parent().name, node.name])
	#var children = node.get_children()
	#children.sort_custom(func(a, b): return a.name < b.name)
	#print(children)
	##for i in range(children.size()):
		##move_child(children[i], i)

func tile_map_layer_update(node: TileMapLayer, tile_set: TileSet, layer_offset: Vector2i):
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
	var new_position = Vector2(0, new_z_index * layer_offset.y * -1)
	
	node.tile_set = tile_set
	node.position = new_position
	node.z_index = new_z_index
	node.y_sort_enabled = true
	
	Log.trace(self, "[%s.%s] Updated position at %s with z-index: %s" % [node.get_parent().name, node.name, node.position, node.z_index])
