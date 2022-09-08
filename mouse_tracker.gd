extends TrackingBackendTrait

var logger := Logger.new(get_name())

var tracker: Reference
var apply_func: FuncRef

var screen_size := Vector2.ZERO
var screen_midpoint := Vector2.ZERO
var screen_scale: float = 16.0

var mouse_pos := Vector2.ZERO

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _init() -> void:
	# TODO make this configurable
	screen_size = OS.get_screen_size()
	screen_midpoint = screen_size / 2

	start_receiver()

#-----------------------------------------------------------------------------#
# Connections                                                                 #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

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
	
	mouse_pos = (tracker.get_position() - screen_midpoint) / screen_scale

	data.bone_rotation.target_value = stored_offsets.rotation_offset - Vector3(
		mouse_pos.y,
		mouse_pos.x,
		0.0
	)
