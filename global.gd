extends Node

var _options : Dictionary

# Vérifie que l'option est active via la présence du fichier user de même nom
func has_option(opt : String) -> bool:
	if not _options.has(opt):
		var file = FileAccess.open("user://"+opt, FileAccess.READ)
		_options[opt] = (file != null)
		if file != null : file.close()
	return _options[opt]
