extends Node3D

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@onready var healthtext = $UserInterfaceControl/HealthValue
@onready var ammotext = $UserInterfaceControl/AmmoValue

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_area_3d_body_entered(body):
    if player.health!=100:
        if player.health>80:
            player.health=100
        else:
            player.health+=20
        queue_free()
