extends Control

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@onready var healthtext = $UserInterfaceControl/HealthValue
@onready var ammotext = $UserInterfaceControl/AmmoValue

# Called when the node enters the scene tree for the first time.
func _ready():
    get_tree().paused=true
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    $UserInterfaceControl.visible=false
    $PausedMenu.visible=false
    

var pause = true


func _input(event):
    if event.is_action_pressed("ui_cancel"):
        pause = not pause
        if pause:
            $PausedMenu.visible=false
            get_tree().paused=false
            process_mode = Node.PROCESS_MODE_PAUSABLE
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            $PausedMenu.visible=true
            get_tree().paused=true
            process_mode = Node.PROCESS_MODE_WHEN_PAUSED
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    healthtext.text = str(player.health)
    ammotext.text = str(player.ammo)


func _on_start_button_pressed():
    $StartScreen.visible=false
    $UserInterfaceControl.visible=true
    get_tree().paused=false
    process_mode = Node.PROCESS_MODE_PAUSABLE
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    



func _on_quit_button_pressed():
    get_tree().quit()
