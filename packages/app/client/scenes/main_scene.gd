extends Control

@onready var client_manager: ClientManager = $Foreground/ClientManager
@onready var world_scene: Node3D = $Background/SubViewport/World/WorldScene

#func _enter_tree() -> void:
func _ready() -> void:
	print("Connect to client_state_connected")
	client_manager.connect("client_state_connected", func():
		print("Fetching client configuration")
		client_manager.client_configuration_fetch()
		print("Fetching client users")
		client_manager.client_users_fetch()
		pass
	)
	print("Connect to client_user_join")
	client_manager.connect("client_user_join", func(user):
		var spawner = world_room_spawner_find(user.room.id, user.room.slot)
		if spawner:
			print("Add player at spawner location")
			var player = preload("res://assets/models/player/player.tscn").instantiate()
			spawner.add_child(player)
		else:
			printerr("Spawner not found")
		pass
	)
	print("Connect to client_user_leave")
	client_manager.connect("client_user_leave", func(user):
		var spawner = world_room_spawner_find(user.room.id, user.room.slot)
		if spawner:
			print("Remove player at spawner location")
			for child in spawner.get_children():
				spawner.remove_child(child)
		else:
			printerr("Spawner not found")
		pass
	)
	pass

func _process(_delta: float) -> void:
	pass

func world_room_spawner_find(room_id: String, room_slot: int) -> Marker3D:
	print("Looking for runtime room (id: %s) (slot: %s)" % [room_id, room_slot])
	for spawner in world_scene.get_tree().current_scene.find_children("*", "Marker3D", true):
		if(spawner.name.begins_with(room_id) && spawner.name.ends_with(str(room_slot))):
			print("Find spawner %s" % spawner.name)
			return spawner
	return null
