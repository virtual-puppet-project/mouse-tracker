extends PanelContainer

var logger := Logger.new("MouseTrackerGui")

func _init() -> void:
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

func _usage() -> Label:
	var r := Label.new()
	ControlUtil.h_expand_fill(r)
	r.autowrap = true
	if OS.get_name().to_lower() == "linux":
		r.text = tr("MOUSE_TRACKER_USAGE_LABEL_TEXT_LINUX")
	else:
		r.text = tr("MOUSE_TRACKER_USAGE_LABEL_TEXT")
	
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
