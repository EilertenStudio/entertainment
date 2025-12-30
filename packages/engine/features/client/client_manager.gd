class_name ClientManager extends Node

enum State {
	CONNECTED,
	DISCONNECTED
}

static var client_socket = WebSocketPeer.new()

@export var client_connection_url := "ws://127.0.0.1:8080"
@onready var client_connection_info := $ClientController/ConnectionInfo
@onready var client_configuration_fetch_button := $ClientController/UpdateConfiguration
@onready var client_connection_state_reconnect_button := $ClientController/Reconnect

@export var client_autoconnect := false
@export var client_state := State.DISCONNECTED

@export var client_configuration: Dictionary

func _ready() -> void:
	# == Inizialize features
	client_configuration_init(true)
	# == Initialize nodes
	client_configuration_fetch_button.connect('button_down', func():
		client_configuration_fetch(true)
		pass
	)
	client_connection_state_reconnect_button.connect('button_down', func():
		client_connection_state_set(WebSocketPeer.STATE_CLOSED)
		pass
	)
	# == Applu configurations
	if client_autoconnect:
		client_state = State.CONNECTED
	pass

func _process(_delta: float) -> void:
	# == Update context states
	client_state_update(true)
	pass

signal client_state_connected()
signal client_state_disconnected()

func client_state_update(_trace := false):
	# Get current state from websocket
	var connection_state = client_connection_state_get()
	# Check the desired state and conditions
	match client_state:
		State.DISCONNECTED:
			match connection_state:
				# When connected -> disconnect
				WebSocketPeer.STATE_OPEN, WebSocketPeer.STATE_CONNECTING:
					client_connection_state_set(WebSocketPeer.STATE_CLOSED, _trace)
					client_state_disconnected.emit()
		State.CONNECTED:
			match connection_state:
				# When disconnect -> connect
				WebSocketPeer.STATE_CLOSED, WebSocketPeer.STATE_CLOSING:
					client_connection_state_set(WebSocketPeer.STATE_OPEN, _trace)
					client_state_connected.emit()
				# When connect -> update features
				_:
					client_command_update(_trace)
	pass

func client_connection_state_get(_trace := false):
	client_socket.poll()
	return client_socket.get_ready_state()

func client_connection_state_set(state: int, _trace := false):
	match state:
		WebSocketPeer.STATE_OPEN:
			if _trace: print("Set connection state to OPEN")
			if client_socket.connect_to_url(client_connection_url) == OK:
				while client_socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
					client_socket.poll()
			else:
				printerr("Set connection state failed at %s" % client_connection_url)
		WebSocketPeer.STATE_CLOSED:
			if _trace: print("Set connection state to CLOSED")
			client_socket.close(1000, "Closed by user")
	pass

signal client_command_received(packet: Dictionary)

func client_command_update(_trace := false):
	match client_connection_state_get():
		WebSocketPeer.STATE_OPEN:
			while client_socket.get_available_packet_count() > 0:
				var rawData = client_socket.get_packet()
				if rawData:
					var packet = JSON.parse_string(rawData.get_string_from_utf8())
					if _trace: print("Receive new packet %s" % packet)
					client_command_received.emit(packet)
	pass

func client_command_send(_name: String, data = null, _trace := false):
	match client_connection_state_get():
		WebSocketPeer.STATE_OPEN:
			var packet = {
				"timestamp": Time.get_unix_time_from_system(),
				"name": _name
			}
			if data:
				packet.data = data
			
			client_socket.send_text(JSON.stringify(packet))
		WebSocketPeer.STATE_CLOSED:
			printerr("Cannot send command due socket is not connected")
	pass

func client_configuration_init(_trace := false):
	connect('client_command_received', func(packet):
		match packet.name:
			"configuration_set":
				if _trace: print("Receive new configuration")
				client_configuration = packet.data
		pass
	)
	pass

func client_configuration_fetch(_trace := false):
	if _trace: print("Ask to server for configuration data")
	client_command_send("configuration_get")
	pass

#func _ready() -> void:
	#_connection_button_init()
	#if _autoconnect:
		#_connection_state_set(WebSocketPeer.STATE_OPEN)
	#pass
#
#func _process(_delta: float) -> void:
	#_connection_state_check(
		#func on_open(): 
			#_state_update(ClientState.CONNECTED)
			##if !_configuration_fetched:
				##Manager.send(Message)
			#pass,
		#func on_closed(code, reason, reconnect):
			#if reconnect:
				#_state_update(ClientState.RECONNECTING)
			#else:
				#_state_update(ClientState.DISCONNECTED, code, reason)
			#pass
	#)
	#_connection_state_update(
		#func on_packet(packet: String):
			#print(packet)
			#pass
	#)
	#pass

#func _state_update(state: ClientState, code: int = 0, reason: String = "", _trace: bool = false):
	#match state:
		#ClientState.CONNECTED:
			#_connection_info_update(" connected at %s" % [_socket_url])
			#_connection_button_update("Disconnect")
		#ClientState.RECONNECTING:
			#_connection_info_update("Reconnecting at %s" % [_socket_url])
		#ClientState.DISCONNECTED:
			#_connection_info_update(" disconnect with (code: %s) (reason: %s)" % [code, reason])
			#_connection_button_update("Connect")
	#
#func _connection_state_get():
	#_socket.poll()
	#return _socket.get_ready_state()
#
#func _connection_state_set(state: int, trace := false):
	#match state:
		#WebSocketPeer.STATE_OPEN:
			#if trace: print("Set connection state to OPEN")
			#if _socket.connect_to_url(_socket_url) == OK:
				#_socket.poll()
			#else:
				#printerr("Set connection state failed at %s" % _socket_url)
		#WebSocketPeer.STATE_CLOSED:
			#if trace: print("Set connection state to CLOSED")
			#_socket.close(1000, "Closed by user")
	#pass
#
#func _connection_state_check(on_open: Callable, on_closed: Callable, trace := false):
	#var state = _connection_state_get()
	#match state:
		#WebSocketPeer.STATE_CONNECTING:
			#if trace: print("Connection state in CONNECTING")
		#WebSocketPeer.STATE_OPEN:
			#if trace: print("Connection state is OPEN")
			#on_open.call()
		#WebSocketPeer.STATE_CLOSING:
			#if trace: print("Connection state in CLOSING")
		#WebSocketPeer.STATE_CLOSED:
			#if trace: print("Connection state is CLOSED")
			#var code = _socket.get_close_code()
			#var reason = _socket.get_close_reason()
			#var reconnect = code == -1
			#
			#on_closed.call(code, reason, reconnect)
			#
			#if reconnect:
				#_connection_state_set(WebSocketPeer.STATE_OPEN, false)
	#pass
#
#func _connection_state_update(on_packet: Callable, trace := false):
	#match _connection_state_get():
		#WebSocketPeer.STATE_OPEN:
			#while _socket.get_available_packet_count() > 0:
				#if trace: print("Detect new packet to consume")
				#var packet = _socket.get_packet()
				#on_packet.call(packet.get_string_from_utf8())
		#_:
			#pass
	#pass
	#
#func _connection_info_update(text: String, color: Color = Color.WHITE, trace: bool = false):
	#if trace: print(text)
	#_connection_info.text = text
	#_connection_info.add_theme_color_override("font", color)
	#pass
#
#func _connection_button_init():
	#_connection_button.connect("button_down", func():
		#match _connection_state_get():
			#WebSocketPeer.STATE_CLOSED:
				#_connection_state_set(WebSocketPeer.STATE_OPEN)
			#WebSocketPeer.STATE_OPEN:
				#_connection_state_set(WebSocketPeer.STATE_CLOSED)
		#pass
	#)
	#pass
#func _connection_button_update(text: String, color: Color = Color.WHITE, trace: bool = false):
	#if trace: print(text)
	#_connection_button.text = text
	#_connection_button.add_theme_color_override("font", color)
	#pass
#
#
#func _command_send(command: ClientCommand, data = null):
	#match _connection_state_get():
		#WebSocketPeer.STATE_OPEN:
			#var packet = {
				#"type": command,
				#"timestamp": Time.get_unix_time_from_system()
			#}
			#if data:
				#packet.data = data
			#
			#_socket.send_text(JSON.stringify(packet))
		#WebSocketPeer.STATE_CLOSED:
			#printerr("Cannot send command due socket is not connected")
	#pass
