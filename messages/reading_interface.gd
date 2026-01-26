class_name ReadingInterface
extends Control

@export var _note_panel: PanelContainer
@export var _text_label: Label
@export var _done_button: Button


func _ready():
    _done_button.pressed.connect(_on_done_button_pressed)


func initialize(message_text: String):
    _text_label.text = message_text
    _note_panel.visible = true


func _on_done_button_pressed():
    if _note_panel.visible:
        _note_panel.visible = false