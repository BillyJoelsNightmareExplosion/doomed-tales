extends Node3D

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@onready var audio_player: AudioStreamPlayer = get_tree().root.get_children()[0].get_medkit_audio()


func _on_area_3d_body_entered(body):
    if player.health!=100:
        if player.health>80:
            player.health=100
        else:
            player.health+=20
        audio_player.play()
        queue_free()
