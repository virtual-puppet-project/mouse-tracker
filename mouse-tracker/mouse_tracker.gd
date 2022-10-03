extends TrackingBackendTrait

const ConfigKeys := {
	"DAMPING": "mouse_tracker_damping",
	"SCREEN": "mouse_tracker_screen"
}

var logger := Logger.new(get_name())

var tracker: Reference
var apply_func: FuncRef

var config_screen: int = -1
var config_screen_scale: float = 16.0

var screen_size := Vector2.ZERO
var screen_midpoint := Vector2.ZERO

var mouse_pos := Vector2.ZERO

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _init() -> void:
	for val in ConfigKeys.values():
		var res: Result = Safely.wrap(AM.ps.subscribe(self, val, "_on_event_published"))
		if res.is_err():
			logger.error(res)
			return

	config_screen = AM.cm.get_data(ConfigKeys.SCREEN, -1)
	config_screen_scale = AM.cm.get_data(ConfigKeys.DAMPING, 16.0)
	
	_set_screen_values()

	start_receiver()

#-----------------------------------------------------------------------------#
# Connections                                                                 #
#-----------------------------------------------------------------------------#

func _on_event_published(payload: SignalPayload) -> void:
	match payload.signal_name:
		ConfigKeys.DAMPING:
			config_screen_scale = payload.data
		ConfigKeys.SCREEN:
			config_screen = payload.data
			_set_screen_values()

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

func _set_screen_values() -> void:
	screen_size = OS.get_screen_size(config_screen)
	screen_midpoint = screen_size / 2

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#

func get_name() -> String:
	return "MouseTracker"

func start_receiver() -> void:
	var res: Result = Safely.wrap(AM.em.load_gdnative_resource(
		"MouseTracker", "MouseTrackerLib", "MousePoller"))
	if res.is_err():
		logger.error("Unable to load mouse tracker")
		return
	
	tracker = res.unwrap()

func stop_receiver() -> void:
	tracker = null

func set_offsets() -> void:
	stored_offsets.translation_offset = Vector3(mouse_pos.x, mouse_pos.y, 0.0)
	stored_offsets.rotation_offset = Vector3(mouse_pos.x, mouse_pos.y, 0.0)

func has_data() -> bool:
	return tracker != null

func apply(data: InterpolationData, _model: PuppetTrait) -> void:
	if tracker == null:
		logger.error("%s failed to load, please report this as a bug" % get_name())
		return
	
	mouse_pos = (tracker.get_position() - screen_midpoint) / config_screen_scale

	data.bone_rotation.target_value = stored_offsets.rotation_offset - Vector3(
		mouse_pos.y,
		mouse_pos.x,
		0.0
	)
