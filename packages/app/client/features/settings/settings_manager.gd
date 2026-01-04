extends Node2D

func _ready() -> void:
	# Sincronizza il motore con il framerate di FFmpeg
	Engine.max_fps = 30
	
	# Riduce la frequenza dei calcoli fisici (standard è 60)
	Engine.physics_ticks_per_second = 30
	
	# Previene picchi di calcolo della fisica in caso di lag
	Engine.max_physics_steps_per_frame = 2
	
	# Attiva la modalità a basso consumo (ideale per VPS/Headless)
	OS.low_processor_usage_mode = true
	
	# Imposta un tempo di "riposo" (in microsecondi) tra i frame
	# 6900 µs è un buon valore per i 30 FPS
	OS.low_processor_usage_mode_sleep_usec = 6900
	
	# Disabilita il V-Sync (non supportato dal driver software Mesa)
	#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	# Nasconde il cursore via script (alternativa o rinforzo a FFmpeg)
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
