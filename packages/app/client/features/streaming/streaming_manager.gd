class_name StreamingManager extends Control

enum ProcessState {
	ON,
	OFF
}

@export var streaming_process_state := ProcessState.OFF:
	set(value):
		if _process_disabled() or streaming_process_state == value: return
		
		Log.info(self, "[process.state] Set to %s" % ProcessState.keys()[value])
		
		match value:
			ProcessState.ON:
				Log.info(self, "[process.state] Request start process")
				if streaming_process_start():
					streaming_process_state = value
			ProcessState.OFF:
				Log.info(self, "[process.state] Request stop process")
				if streaming_process_stop():
					streaming_process_state = value
		
@export var streaming_process = null
@export var streaming_process_script = "res://features/streaming/scripts/streaming_process.sh"
@export var streaming_process_output = null

func _process_disabled():
	return process_mode == ProcessMode.PROCESS_MODE_DISABLED

func streaming_process_script_path():
	return ProjectSettings.globalize_path(streaming_process_script)

func streaming_process_start():
	if streaming_process != null: 
		Log.warn(self, "[process.start] Already started. Abort operation")
		return false
		
	var process_code = -1
	
	match OS.get_name():
		"Linux":
			process_code = OS.create_process("sh", [ streaming_process_script_path(), "start" ])
		_:
			Log.warn(self, "[process.start] OS not supported yet")
			return false
	
	if process_code != -1:
		streaming_process = process_code
		Log.info(self, "[process.start] Command succedeed with code: %s" % process_code)
		return true
	else:
		Log.error(self, "[process.start] Command failed with code: %s" % process_code)
		return false

func streaming_process_stop():
	if streaming_process == null:
		Log.warn(self, "[process.start] Already stopped. Abort operation")
		return false
	
	var process_code = -1
	match OS.get_name():
		"Linux":
			process_code = OS.execute("sh", [ streaming_process_script_path(), "stop" ])
		_:
			Log.warn(self, "[process.stop] OS not supported yet")
			return false
			
	if process_code == 0:
		streaming_process = null
		Log.info(self, "[process.stop] Command succedeed with code: %s" % process_code)
		return true
	else:
		Log.error(self, "[process.stop] Command failed with code: %s" % process_code)
		return false
