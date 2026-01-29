@tool
class_name TileMapIsometricLigt extends Light2D

@export var with_shadow := false:
	set(value):
		with_shadow = value
		_on_shadow_caster_property_update("enabled", value)
		_on_shadow_caster_property_update("shadow_enabled", value)

func _set(property: StringName, value: Variant) -> bool:
	Log.event(self, "Property changed (%s = %s)" % [property, value])
	match property:
		"height", "color", "energy":
			_on_shadow_caster_property_update(property, value)
	return false 

func _on_shadow_caster_property_update(property: StringName, value: Variant):
	var SHADOW_CASTER: DirectionalLight2D = $SHADOW_CASTER
	if not SHADOW_CASTER:
		if not SHADOW_CASTER: Log.error(self, "SHADOW_CASTER not found as children! Set it.")
	else:
		Log.debug(self, "Update SHADOW_CASTER (%s = %s)" % [property, value])
		SHADOW_CASTER[property] = value
