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
	
