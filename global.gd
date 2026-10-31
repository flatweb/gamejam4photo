@tool
extends Node

var _options : Dictionary

## Vérifie que l'option est active via la présence du fichier user de même nom
func has_option(opt : String) -> bool:
	if not _options.has(opt):
		var file = FileAccess.open("user://"+opt, FileAccess.READ)
		_options[opt] = (file != null)
		if file != null : file.close()
	return _options[opt]

## Récupère dans un tableau toutes les valeurs contenues dans le fichier d'option 
func for_options(opt : String) -> Array[String] :
	if not has_option(opt): return []
	
	var result = Array()
	var file = FileAccess.open("user://" + opt, FileAccess.READ)
	if file != null :
		while file.get_position() < file.get_length() :
			var content : String = file.get_line().strip_edges()
			if content != "" :
				result.append(content.strip_edges())
	return result
	
func printmsg(text : String):
	var ui = get_node("UI")
	ui.pushtext(text)

var _stampstimer : Timer = Timer.new()

func _ready():
	if Engine.is_editor_hint():
		return
	_stampstimer.timeout.connect(hidestamps.bind())
	_stampstimer.one_shot = true
	get_node('/root').add_child.call_deferred(_stampstimer)
	
func showstamp(nom : String):
	hidestamps()
	var stamps = get_node("/root/Root/UI/StampsContainer")
	for rect in stamps.get_children():
		if rect.name == "Rect"+nom:
			rect.show()
	_stampstimer.start(2.0)
	
func hidestamps():
	for rect in get_node("/root/Root/UI/StampsContainer").get_children() :
		rect.hide()
	
