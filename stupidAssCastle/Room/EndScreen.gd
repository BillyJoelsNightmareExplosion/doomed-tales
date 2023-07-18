extends Control

func _on_quit_button_pressed():
    get_tree().quit()
    
func _on_restart_button_pressed():
    get_tree().reload_current_scene()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
