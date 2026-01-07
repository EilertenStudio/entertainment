extends Control

func _ready() -> void:
	if process_mode == ProcessMode.PROCESS_MODE_DISABLED: return
	
	print("[SettingManager] Update Godot settings!")
	
	# --- GESTIONE CPU / FPS ---
	# Forza il limite dei frame (massimo risparmio per VPS)
	Engine.max_fps = 30

	# Low Processor Mode: Non renderizza se nulla si muove
	#OS.low_processor_usage_mode = true
	# Tempo di sleep tra i frame (in microsecondi)
	#OS.low_processor_usage_mode_sleep_usec = 20000 

	# --- RENDERING QUALITY ---
	# Disabilita V-Sync per non aspettare il monitor virtuale di Xvfb
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# Disabilita Anti-Aliasing che peserebbe sulla CPU (Software Rasterizer)
	get_viewport().msaa_2d = Viewport.MSAA_DISABLED

	# Disabilita il rendering 3D (anche se sei in una scena 2D)
	get_viewport().get_window().disable_3d = true

	# --- DEBUG INFO ---
	print("[SettingManager] Low Processor Mode: ", OS.low_processor_usage_mode)
	print("[SettingManager] Max FPS set to: ", Engine.max_fps)
