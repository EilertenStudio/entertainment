class_name Log extends Object

enum Level { DEBUG, INFO, WARN, ERROR }

static var current_level = Level.DEBUG if OS.has_feature("editor") else Level.INFO

static func debug(handler: Variant, message: String):
	_log(Level.DEBUG, handler, message)

static func info(handler: Variant, message: String):
	_log(Level.INFO, handler, message)

static func warn(handler: Variant, message: String):
	_log(Level.WARN, handler, message)

static func error(handler: Variant, message: String):
	_log(Level.ERROR, handler, message)

static func _log(level: Level, handler: Variant, message: String):
	if level < current_level:
		return
	
	var category := "Unknown"
	
	if typeof(handler) == TYPE_STRING:
		category = handler
	elif handler is Node:
		category = handler.name
	elif handler is Object:
		if handler.get_script() and handler.get_script().get_global_name() != &"":
			category = handler.get_script().get_global_name()
		else:
			category = handler.get_class()

	var time = Time.get_time_string_from_system()
	var level_name = Level.keys()[level]
	var formatted_msg = "[%s] %-5s [%s] %s" % [time, level_name, category, message]
	
	if level >= Level.WARN:
		printerr(formatted_msg)
	else:
		print(formatted_msg)
