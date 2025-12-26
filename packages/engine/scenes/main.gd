extends Control

@onready var client_controller: Control = $ClientController
@onready var client_connect_info: Label = $ClientController/ClientConnectInfo
@onready var client_connect_button: Button = $ClientController/ClientConnectButton

func _ready() -> void:
	_init_client(true)
	pass

func _process(_delta: float) -> void:
	_update_client()
	pass

#region Client
func _init_client(autoconnect: bool) -> void:
	client_connect_button.connect("button_down", func():
		match ClientManager.get_connection_state():
			WebSocketPeer.STATE_CLOSED:
				ClientManager.set_connection_state(WebSocketPeer.STATE_OPEN)
			WebSocketPeer.STATE_OPEN:
				ClientManager.set_connection_state(WebSocketPeer.STATE_CLOSED)
		pass
	)
	if autoconnect:
		ClientManager.set_connection_state(WebSocketPeer.STATE_OPEN)
	pass
func _update_client() -> void:
	ClientManager.check_connection_state(
		func on_open(): 
			_update_client_connect_info("Client connected at %s" % [ClientManager.socket_url])
			_update_client_connect_button("Disconnect")
			pass,
		func on_closed(_code, _reason):
			_update_client_connect_info("Client disconnect")
			_update_client_connect_button("Connect")
			pass
	)
	ClientManager.update_connection_state(
		func on_packet(packet: String):
			print(packet)
			pass
	)
	pass
func _update_client_connect_info(text: String, color: Color = Color.WHITE, trace: bool = false):
	if trace: print(text)
	client_connect_info.text = text
	client_connect_info.add_theme_color_override("font", color)
	pass
func _update_client_connect_button(text: String, color: Color = Color.WHITE, trace: bool = false):
	if trace: print(text)
	client_connect_button.text = text
	client_connect_button.add_theme_color_override("font", color)
	pass
#endregion
