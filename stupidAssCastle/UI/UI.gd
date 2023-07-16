extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
    $UserInterfaceControl.visible=false
    $PausedMenu.visible=false
    

var pause = true


func _input(event):
    if event.is_action_pressed("ui_cancel"):
        pause = not pause
        if pause:
            $PausedMenu.visible=false
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            $PausedMenu.visible=true
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_start_button_pressed():
    $StartScreen.visible=false
    $UserInterfaceControl.visible=true
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    



func _on_quit_button_pressed():
    get_tree().quit()
