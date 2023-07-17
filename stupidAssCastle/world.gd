extends Node3D

var capture_mouse = true


func get_player() -> CharacterBody3D:
    return $Player
    
func get_ui():
    return $UI
    
func get_medkit_audio() -> AudioStreamPlayer:
    return $MedkitAudio
