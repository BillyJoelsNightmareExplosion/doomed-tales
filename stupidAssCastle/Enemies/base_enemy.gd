class_name Enemy
extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var health = 3

func _ready():
    pass

func _process(delta):
    if health <= 0:
        queue_free()

func get_ai():
    return $AIScript
