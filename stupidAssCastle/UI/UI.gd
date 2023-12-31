extends Control

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@onready var healthtext = $UserInterfaceControl/HealthValue
@onready var ammotext = $UserInterfaceControl/AmmoValue

var pause = true
var TriggerCounter=0
var TextArray
var ArrSize
var CurrentText
var can_press_escape=true


# Called when the node enters the scene tree for the first time.
func _ready():
    var Triggers=get_tree().get_nodes_in_group("DialogueTrigger")
    for i in Triggers:
        i.start_dialogue.connect(dialogue)
    
    change_volume($PausedMenu/HSlider.value)
        
    get_tree().paused=true
    can_press_escape=false
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    $UserInterfaceControl.visible=false
    $Dialoug.visible=false
    $PausedMenu.visible=false
    $RestartMenu.visible=false
    
func _input(event):
    process_mode = Node.PROCESS_MODE_ALWAYS
    if event.is_action_pressed("ui_cancel")&&can_press_escape==true:
        pause = not pause
        if pause:
            $PausedMenu.visible=false
            get_tree().paused=false
            #process_mode = Node.PROCESS_MODE_PAUSABLE
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            $PausedMenu.visible=true
            get_tree().paused=true
            #process_mode = Node.PROCESS_MODE_WHEN_PAUSED
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    healthtext.text = str(player.health)
    ammotext.text = str(player.ammo)
    
    if $Dialoug.visible==true:
        if Input.is_action_just_pressed("ui_accept"):
            if CurrentText==ArrSize:
                get_tree().paused=false
                $UserInterfaceControl.visible=true
                $Dialoug.visible=false
            else:
                CurrentText+=1
                play()
                $Dialoug/RichTextLabel.text=TextArray[CurrentText-1]
                
    if player.health<=0:
        $RestartMenu.visible=true
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_start_button_pressed():
    can_press_escape=true
    $StartScreen.visible=false
    $UserInterfaceControl.visible=true
    get_tree().paused=false
    process_mode = Node.PROCESS_MODE_PAUSABLE
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    

func _on_quit_button_pressed():
    get_tree().quit()


func _on_resume_button_pressed():
    can_press_escape=true
    pause = not pause
    $PausedMenu.visible=false
    get_tree().paused=false
    process_mode = Node.PROCESS_MODE_PAUSABLE
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
func dialogue(textArray: Array[String]):
    get_tree().paused=true
    play()
    $UserInterfaceControl.visible=false
    $Dialoug.visible=true
    TextArray=textArray
    ArrSize=TextArray.size()
    $Dialoug/RichTextLabel.text=TextArray[0]
    CurrentText=1


func play():
    $Dialoug/RichTextLabel.visible_ratio = 0
    $Dialoug/RichTextLabel/TextAnimation.play("TextCrawl")


func _on_restart_button_pressed():
    can_press_escape=false
    get_tree().reload_current_scene()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func change_volume(value):
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100))


func _on_h_slider_value_changed(value):
    change_volume(value)
