extends Control

@onready var client_manager: ClientManager = $Foreground/ClientManager

func _ready() -> void:
	client_manager.connect("client_state_connected", func():
		print("Connection ready to fetch configuration")
		client_manager.client_configuration_fetch()
		pass
	)
	pass

func _process(_delta: float) -> void:
	
	pass
