extends Control

@onready var start_button = $StartButton
@onready var tutorial_panel = $TutorialScreen
@onready var tutorial_button = $TutorialButton
@onready var close_button = $CloseButton
@onready var quit_button = $QuitButton

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	tutorial_panel.hide()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://main_game.tscn")

func _on_tutorial_button_pressed():
	tutorial_panel.show()

func _on_close_button_pressed():
	tutorial_panel.hide()

func _on_quit_button_pressed():
	get_tree().quit()

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
