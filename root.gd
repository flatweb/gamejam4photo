extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PauseContainer.hide()
	$CreditContainer.hide()
	resized()
	loadgame()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$EspaceJeu.show()
	$EspaceJeu.silence()
	$AudioMusique.play()
	$ColorRectHaut.hide()
	$ColorRectBas.hide()


## true si en attente du tout premier Start du jeu avant le niveau 1
var waitingtostart : bool

@export var newlevel_timer : float = 3.0

var game : Node3D

func resized():
	var vp : Viewport = get_viewport()
	$PanelContainer.size = vp.size
	%PauseContainer.size = vp.size
	%CreditContainer.size = vp.size

func loadgame():
	$PanelContainer.show()
	%IntroContainer.show()
	%Label.text = "Chargement..."
	%Label.show()
	%StartButton.hide()
	%AideButton.hide()
	$PanelContainer/IntroContainer/RichTextDontWait.hide()
	$PanelContainer/IntroContainer/RichTextIntro.hide()
	$TimerInactivite.stop()
	
	# On vide la partie précédente : FIXME
	#if game != null :
		#game.queue_free()
		#await get_tree().create_timer(2.0).timeout 
	
	#var gametscn = load("res://game.tscn")
	#game = gametscn.instantiate()
	game = $EspaceJeu
	game.fini.connect(endofgame.bind())
	game.process_mode = Node.PROCESS_MODE_ALWAYS
	#$PanelContainer.add_sibling(game)
	
	%Label.hide()
	$PanelContainer/IntroContainer/RichTextDontWait.show()
	$PanelContainer/IntroContainer/RichTextIntro.show()
	%StartButton.text = "  On y va  "
	%StartButton.show()
	%AideButton.show()
	%StartButton.grab_focus()
	waitingtostart = true
	
	get_tree().paused = true

func _on_aide_button_pressed() -> void:
	showaide() # Replace with function body.

func _on_aide_button_gui_input(event: InputEvent) -> void:
	if %AideButton.visible and event is InputEventJoypadButton:
		showaide()

func _on_popup_child_exiting_tree(_node: Node) -> void:
	%IntroContainer.show()
	%StartButton.grab_focus()

func showaide():
	const aideScene = preload("res://aide.tscn")
	%IntroContainer.hide()
	$Popup.add_child(aideScene.instantiate())

func _on_start_button_pressed() -> void:
	if waitingtostart: return
	start()

# Horreur qui permet de distinguer le shortcut (via manette) du clic sur le bouton de la souris
func _on_start_button_up() -> void:
	if %StartButton.visible:
		pass
		start()  # FIXME ? appelé 2 fois on dirait...

func start():
	# Start ou Continue
	waitingtostart = false
	#
	$TimerInactivite.stop()
	%StartButton.hide()
	%AideButton.hide()
	%IntroContainer.hide()
	$PanelContainer.hide()
	$PanelContainer/IntroContainer/RichTextDontWait.hide()
	$PanelContainer/IntroContainer/RichTextIntro.hide()
	$AudioMusique.stop()
	get_tree().paused = false
	
	game.start()
	$EspaceJeu/Joueur.inactif.connect(inactivite.bind())
	$EspaceJeu/Joueur.actif.connect(endofinactif.bind())

func inactivite():
	$EspaceJeu.silence()
	$AudioMusique.play()
	$EspaceJeu/DirectionalLight3D.light_energy = 0.5
	$ColorRectHaut.show()
	$ColorRectBas.show()

func endofinactif():
	$AudioMusique.stop()
	$EspaceJeu/AudioForetEst.play()
	$EspaceJeu/AudioForetOuest.play()
	$EspaceJeu/AudioPlaine.play()
	$EspaceJeu/DirectionalLight3D.light_energy = 1.0
	$ColorRectHaut.hide()
	$ColorRectBas.hide()


func endofgame():
	endofinactif()
	$AudioMusique.play()
	get_tree().paused = true
	
	var strformat = "{0} photo{1} prise{2} , {3} sujet{4} dans l'album"
	%LabelEndOfGame.text = strformat.format([$EspaceJeu/Joueur.get_photos_prises(),
											"s" if $EspaceJeu/Joueur.get_photos_prises() > 1 else "",
											"s" if $EspaceJeu/Joueur.get_photos_prises() > 1 else "",
											 $EspaceJeu.get_nb_objectifs_atteints(),
											"s" if $EspaceJeu.get_nb_objectifs_atteints() > 1 else ""])
	%LabelEndOfGame.show()
	
	showcredits()

	# Fin de partie
	%RestartButton.show()
	%RestartButton.grab_focus()
	$TimerInactivite.start()

func showcredits() -> void:
	$CreditContainer.show()
	# TODO : animation ....

func _on_timer_inactivite_timeout() -> void:
	# Se déclenche quand on a fini une partie et qu'on ne fait par Restart
	%CreditContainer.hide()
	%PauseContainer.hide()
	get_tree().paused = false
	loadgame()

func _on_retart_button_pressed() -> void:
	%CreditContainer.hide()
	%PauseContainer.hide()
	get_tree().paused = false
	loadgame() # Replace with function body.

func _input(event : InputEvent):
	if not waitingtostart: return
	
	if Input.is_action_just_pressed("start"):
		waitingtostart = false
		start()

func _on_start_button_gui_input(event: InputEvent) -> void:
	if %StartButton.visible and event is InputEventJoypadButton:
		waitingtostart = false
		start()
		
func _unhandled_input(event: InputEvent):
	if (event.is_action_released("ui_cancel")):
		if not get_tree().paused :
			# Mise en pause
			topause()
		else:
			# Sortie de la pause
			# FIXME : on ne passe jamais ici
			outpause()

func topause():
	# Mise en pause
	get_tree().paused = true
	$PauseContainer.show()

func _on_out_pause_button_up() -> void:
	outpause()

func outpause():
	$PauseContainer.hide()
	get_tree().paused = false

func _on_giveup_button_up() -> void:
	pass # Replace with function body.
	$PauseContainer.hide()
	get_tree().paused = false
	endofgame()


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton :
		var mouse = event as InputEventMouseButton
		#print (mouse.button_mask)
		if mouse.button_mask & MOUSE_BUTTON_RIGHT :
			get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
