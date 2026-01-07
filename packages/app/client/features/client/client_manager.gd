class_name ClientManager extends Node

enum State {
	CONNECTED,
	DISCONNECTED
}

static var client_socket = WebSocketPeer.new()

@export var client_connection_url_env := "APP_SERVER_URL"
@export var client_connection_url := "ws://127.0.0.1:8080"
@onready var client_connection_info := $ClientController/ConnectionInfo
@onready var client_connection_state_reconnect_button := $ClientController/Reconnect

@onready var client_configuration_fetch_button := $ClientController/UpdateConfiguration
@onready var client_users_fetch_button := $ClientController/UpdateUsers

@export var client_autoconnect := false
@export var client_state := State.DISCONNECTED

@export var client_configuration: Dictionary
@export var client_users: Dictionary

func _ready() -> void:
	if process_mode == ProcessMode.PROCESS_MODE_DISABLED: return
	
	# == Initialize variables
	if OS.has_environment(client_connection_url_env):
		client_connection_url = OS.get_environment(client_connection_url_env)
	print("Client connection set to %s" % client_connection_url)
	
	# == Inizialize features
	client_configuration_init(true)
	client_users_init(true)
	
	# == Initialize nodes
	client_connection_state_reconnect_button.connect('button_down', func():
		client_connection_state_set(WebSocketPeer.STATE_CLOSED)
		pass
	)
	client_configuration_fetch_button.connect('button_down', func():
		client_configuration_fetch(true)
		pass
	)
	client_users_fetch_button.connect('button_down', func():
		client_users_fetch(true)
		pass
	)
	
	# == Apply configurations
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
					client_connection_state_set(
						WebSocketPeer.STATE_CLOSED, 
						func on_close():
							client_state_disconnected.emit()
							pass,
						_trace
					)
		State.CONNECTED:
			match connection_state:
				# When disconnect -> connect
				WebSocketPeer.STATE_CLOSED, WebSocketPeer.STATE_CLOSING:
					client_connection_state_set(
						WebSocketPeer.STATE_OPEN,
						func on_open():
							client_state_connected.emit()
							pass,
						_trace
					)
				# When connect -> update features
				WebSocketPeer.STATE_OPEN:
					client_command_update(_trace)
	pass

func client_connection_state_get(_trace := false):
	client_socket.poll()
	return client_socket.get_ready_state()

func client_connection_state_set(state: int, closure: Callable = func(): pass, _trace := false):
	match state:
		WebSocketPeer.STATE_OPEN:
			if _trace: print("Set connection state to OPEN")
			var tentative_count := 0
			var connection_state_result = client_socket.connect_to_url(client_connection_url)
			if connection_state_result == OK:
				client_socket.poll()
				while client_socket.get_ready_state() != WebSocketPeer.STATE_OPEN && tentative_count < 5:
					if _trace: print("Await client connection tentative %s" % (tentative_count + 1))
					client_socket.poll()
					if DisplayServer.get_name() == "headless":
						OS.delay_msec(1000)
					else:
						await get_tree().create_timer(1).timeout
					tentative_count += 1
				if client_socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
					closure.call()
				else:
					client_state = State.DISCONNECTED
			else:
				print("Set connection state failed at %s" % client_connection_url)
		WebSocketPeer.STATE_CLOSED:
			if _trace: print("Set connection state to CLOSED")
			client_socket.close(1000, "Closed by user")
			client_socket.poll()
			var tentative_count := 0
			while client_socket.get_ready_state() != WebSocketPeer.STATE_CLOSED && tentative_count < 5:
				if _trace: print("Await client disconnection tentative %s" % (tentative_count + 1))
				client_socket.poll()
				if DisplayServer.get_name() == "headless":
					OS.delay_msec(1000)
				else:
					await get_tree().create_timer(1).timeout
				tentative_count += 1
			if client_socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
				closure.call()
			else:
				client_state = State.CONNECTED
	pass

signal client_command_received(packet: Dictionary)

func client_command_update(_trace := false):
	match client_connection_state_get():
		WebSocketPeer.STATE_OPEN:
			while client_socket.get_available_packet_count() > 0:
				var rawData = client_socket.get_packet()
				if rawData:
					var packet = JSON.parse_string(rawData.get_string_from_utf8())
					if _trace: print("Receive new packet: %s" % packet.name)
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
	client_command_send("configuration_fetch")
	pass

signal client_user_join(user: Variant)
signal client_user_leave(user: Variant)

func client_users_init(_trace := false):
	connect('client_command_received', func(packet):
		match packet.name:
			"users_set":
				var users = packet.data
				if _trace: print("Receive new users")
				# Emit leave event for all runtime users
				for user in client_users.values():
					print("Emit leave event for user: %s" % user.username)
					client_user_leave.emit(user)
				# Update runtime users
				print("Set new users: %s" % users)
				client_users = users
				# Emit join event for all runtime users
				for user in client_users.values():
					print("Emit join event for user: %s" % user.username)
					client_user_join.emit(user)
			"user_join":
				var user = packet.data
				print("Detect user join: %s | %s" % [user.username, user])
				# Add an user to runtime
				client_users[user.id] = user
				# Emit join event for user
				client_user_join.emit(user)
			"user_leave":
				var user = packet.data
				print("Detect user leave: %s | %s" % [user.username, user])
				# Emit leave event for user
				client_user_leave.emit(user)
				# Add an user to runtime
				client_users.erase(user.id)
		pass
	)
	pass

func client_users_fetch(_trace := false):
	if _trace: print("Ask to server for connected users data")
	client_command_send("users_fetch")
	pass
