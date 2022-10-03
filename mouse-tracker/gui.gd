extends PanelContainer

const ConfigKeys := {
	"DAMPING": "mouse_tracker_damping",
	"SCREEN": "mouse_tracker_screen"
}
const IS_FLOAT := true
const IS_INT := false

var logger := Logger.new("MouseTrackerGui")

func _init() -> void:
	for val in ConfigKeys.values():
		var res: Result = Safely.wrap(AM.cm.runtime_subscribe_to_signal(val))
		if res.is_err() and res.unwrap_err() != Error.Code.PUB_SUB_ALREADY_CONNECTED:
			logger.error(res)
			return

	var sc := ScrollContainer.new()
	ControlUtil.all_expand_fill(sc)
	
	add_child(sc)

	var vbox := VBoxContainer.new()
	ControlUtil.h_expand_fill(vbox)

	sc.add_child(vbox)
	
	vbox.add_child(_usage())

	vbox.add_child(HSeparator.new())

	vbox.add_child(_toggle_tracking())

	vbox.add_child(HSeparator.new())

	vbox.add_child(_advanced_options())

static func _on_line_edit_changed(text: String, key: String, is_float: bool) -> void:
	if text.empty():
		return
	if is_float and not text.is_valid_float():
		return
	elif not text.is_valid_integer():
		return

	AM.ps.publish(key, text.to_int() if not is_float else text.to_float())

func _usage() -> Label:
	var r := Label.new()
	ControlUtil.h_expand_fill(r)
	r.autowrap = true
	if OS.get_name().to_lower() == "linux":
		r.text = tr("MOUSE_TRACKER_USAGE_LABEL_TEXT_LINUX")
	else:
		r.text = tr("MOUSE_TRACKER_USAGE_LABEL_TEXT")
	
	return r

func _advanced_options() -> VBoxContainer:
	var r := VBoxContainer.new()
	ControlUtil.h_expand_fill(r)

	var toggle := CheckButton.new()
	ControlUtil.h_expand_fill(toggle)
	toggle.pressed = false
	toggle.text = tr("MOUSE_TRACKER_SHOW_ADVANCED_OPTIONS_TOGGLE")
	toggle.hint_tooltip = tr("MOUSE_TRACKER_SHOW_ADVANCED_OPTIONS_HINT")

	r.add_child(toggle)

	var inner := VBoxContainer.new()
	ControlUtil.h_expand_fill(inner)
	inner.visible = false

	r.add_child(inner)

	inner.add_child(_damping())
	inner.add_child(_screen())

	toggle.connect("toggled", self, "_on_advanced_options_toggled", [inner])

	return r

func _on_advanced_options_toggled(state: bool, control: Control) -> void:
	control.visible = state

func _damping() -> HBoxContainer:
	var r := HBoxContainer.new()
	ControlUtil.h_expand_fill(r)
	r.hint_tooltip = tr("MOUSE_TRACKER_DAMPING_HINT")
	
	var label := Label.new()
	ControlUtil.h_expand_fill(label)
	label.text = tr("MOUSE_TRACKER_DAMPING_LABEL")
	label.hint_tooltip = tr("MOUSE_TRACKER_DAMPING_HINT")

	r.add_child(label)
	
	var line_edit := LineEdit.new()
	ControlUtil.h_expand_fill(line_edit)
	line_edit.hint_tooltip = tr("MOUSE_TRACKER_DAMPING_HINT")

	var initial_value = AM.cm.get_data(ConfigKeys.DAMPING)
	if typeof(initial_value) == TYPE_NIL:
		initial_value = 16.0
		AM.ps.publish(ConfigKeys.DAMPING, initial_value)
	
	line_edit.text = str(initial_value)

	r.add_child(line_edit)

	line_edit.connect("text_changed", self, "_on_line_edit_changed", [ConfigKeys.DAMPING, IS_FLOAT])
	
	return r

func _screen() -> HBoxContainer:
	var r := HBoxContainer.new()
	ControlUtil.h_expand_fill(r)
	r.hint_tooltip = tr("MOUSE_TRACKER_SCREEN_HINT")

	var label := Label.new()
	ControlUtil.h_expand_fill(label)
	label.text = tr("MOUSE_TRACKER_SCREEN_LABEL")
	label.hint_tooltip = tr("MOUSE_TRACKER_SCREEN_HINT")

	r.add_child(label)

	var line_edit := LineEdit.new()
	ControlUtil.h_expand_fill(line_edit)
	line_edit.hint_tooltip = tr("MOUSE_TRACKER_SCREEN_HINT")

	var initial_value = AM.cm.get_data(ConfigKeys.SCREEN)
	if typeof(initial_value) == TYPE_NIL:
		initial_value = -1
		AM.ps.publish(ConfigKeys.SCREEN, initial_value)

	line_edit.text = str(initial_value)

	r.add_child(line_edit)

	line_edit.connect("text_changed", self, "_on_line_edit_changed", [ConfigKeys.SCREEN, IS_INT])

	return r

func _toggle_tracking() -> Button:
	var r := Button.new()
	r.text = tr("MOUSE_TRACKER_TOGGLE_TRACKING_START")
	r.hint_tooltip = tr("MOUSE_TRACKER_TOGGLE_TRACKING_BUTTON_HINT")
	r.focus_mode = Control.FOCUS_NONE
	r.connect("pressed", self, "_on_toggle_tracking", [r])

	return r

func _on_toggle_tracking(button: Button) -> void:
	var trackers = get_tree().current_scene.get("trackers")
	if typeof(trackers) != TYPE_DICTIONARY:
		logger.error("Incompatible runner, aborting")
		return
	
	var tracker: TrackingBackendTrait
	var found := false
	for i in trackers.values():
		if i is TrackingBackendTrait and i.get_name() == "MouseTracker":
			tracker = i
			found = true
			break
	
	if found:
		logger.debug("Stopping mouse tracker")
		
		tracker.stop_receiver()
		trackers.erase(tracker.get_name())
		
		button.text = tr("MOUSE_TRACKER_TOGGLE_TRACKING_START")
	else:
		logger.debug("Starting mouse tracker")
		
		var res: Result = Safely.wrap(AM.em.load_resource("MouseTracker", "mouse_tracker.gd"))
		if res.is_err():
			logger.error(res)
			return
		
		var mouse_tracker = res.unwrap().new()
		
		trackers[mouse_tracker.get_name()] = mouse_tracker
		
		button.text = tr("MOUSE_TRACKER_TOGGLE_TRACKING_STOP")
	
	AM.ps.publish(Globals.TRACKER_TOGGLED, not found, "MouseTracker")
