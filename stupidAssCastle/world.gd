extends Node3D

var capture_mouse = true


func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
    if event.is_action_pressed("ui_cancel"):
        capture_mouse = not capture_mouse
        if capture_mouse:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func get_player() -> CharacterBody3D:
    return $Player
    
func get_ui():
    return $UI
