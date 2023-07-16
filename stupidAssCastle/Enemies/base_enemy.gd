class_name Enemy
extends CharacterBody3D

signal died

@onready var animator = $AnimatedSprite3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var health = 3

func _ready():
    pass

func _process(delta):
    if health <= 0:
        died.emit()
        animator.play("death")
        await get_tree().create_timer(0.75).timeout
        queue_free()

func get_ai():
    return $AIScript
