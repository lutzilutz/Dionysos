class_name EditNote extends Node

var line_id: int = 0
var hour: int = 0
var minute: int = 0
var second: int = 0
var frame: int = 0
var text: String = ""

func has_timecode() -> bool:
	return hour > 0 or minute > 0 or second > 0 or frame > 0
