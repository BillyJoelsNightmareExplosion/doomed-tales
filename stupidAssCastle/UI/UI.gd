extends Control

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@onready var healthtext = $UserInterfaceControl/HealthValue
@onready var ammotext = $UserInterfaceControl/AmmoValue

# Called when the node enters the scene tree for the first time.
func _ready():
    var Triggers=get_tree().get_nodes_in_group("DialougTrigger")
    for i in Triggers:
        i.dialoug_entered.connect(dialoug)
        
    get_tree().paused=true
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    $UserInterfaceControl.visible=false
    $Dialoug.visible=false
    $PausedMenu.visible=false
    

var pause = true
var TriggerCounter=0
var TextArray
var ArrSize
var CurrentText


func _input(event):
    process_mode = Node.PROCESS_MODE_ALWAYS
    if event.is_action_pressed("ui_cancel"):
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
        if Input.is_action_just_pressed("dialog_forward"):
            if CurrentText==ArrSize:
                $UserInterfaceControl.visible=true
                $Dialoug.visible=false
            else:
                CurrentText+=1
                play()
                $Dialoug/RichTextLabel.text=TextArray[CurrentText-1]


func _on_start_button_pressed():
    $StartScreen.visible=false
    $UserInterfaceControl.visible=true
    get_tree().paused=false
    process_mode = Node.PROCESS_MODE_PAUSABLE
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    



func _on_quit_button_pressed():
    get_tree().quit()


func _on_resume_button_pressed():
    pause = not pause
    $PausedMenu.visible=false
    get_tree().paused=false
    process_mode = Node.PROCESS_MODE_PAUSABLE
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
func dialoug(triggerNode):
    triggerNode.queue_free()
    play()
    $UserInterfaceControl.visible=false
    $Dialoug/RichTextLabel.visible=true
    #Here you need to fill TextArray with the current dialoug
    ArrSize=TextArray.size()
    $Dialoug/RichTextLabel.text=TextArray[0]
    CurrentText=1


func play():
    $Dialoug/RichTextLabel.visible_ratio = 0
    $Dialoug/RichTextLabel/TextAnimation.play("TextCrawl")
