extends Area3D

signal start_dialogue(dialogue: Array[String])

@export_multiline var dialogue: Array[String] = []

@onready var room = get_parent()
@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()


func _ready():
    $MeshInstance3D.visible = false
    $MeshInstance3D.queue_free()


func _on_body_entered(body):
    if body != player:
        return
    room.spawn_enemies()
    
    # TODO: Close door behind player
    
    if dialogue.size() > 0:
        start_dialogue.emit(dialogue)
    
    queue_free()
