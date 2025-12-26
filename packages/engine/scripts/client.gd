class_name ClientManager extends Object

static var socket = WebSocketPeer.new()
static var socket_url = "ws://127.0.0.1:8080"

static func get_connection_state():
	socket.poll()
	return socket.get_ready_state()

static func set_connection_state(state: int, trace := false):
	match state:
		WebSocketPeer.STATE_OPEN:
			if trace: print("Set connection state to OPEN")
			if socket.connect_to_url(socket_url) == OK:
				socket.poll()
			else:
				printerr("Set connection state failed at %s" % socket_url)
		WebSocketPeer.STATE_CLOSED:
			if trace: print("Set connection state to CLOSED")
			socket.close()
	pass

static func check_connection_state(on_open: Callable, on_closed: Callable, trace := false):
	var state = get_connection_state()
	match state:
		WebSocketPeer.STATE_CONNECTING:
			if trace: print("Connection state in CONNECTING")
		WebSocketPeer.STATE_OPEN:
			if trace: print("Connection state is OPEN")
			on_open.call()
		WebSocketPeer.STATE_CLOSING:
			if trace: print("Connection state in CLOSING")
		WebSocketPeer.STATE_CLOSED:
			if trace: print("Connection state is CLOSED")
			var code = socket.get_close_code()
			var reason = socket.get_close_reason()
			on_closed.call(code, reason)
	pass

static func update_connection_state(on_packet: Callable, trace := false):
	match get_connection_state():
		WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count() > 0:
				if trace: print("Detect new packet to consume")
				var packet = socket.get_packet()
				on_packet.call(packet.get_string_from_utf8())
		_:
			pass
	pass
