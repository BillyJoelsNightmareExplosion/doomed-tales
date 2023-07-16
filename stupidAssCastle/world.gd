extends Node3D

func get_player() -> CharacterBody3D:
    return $Player

# Called when the node enters the scene tree for the first time.
func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()
