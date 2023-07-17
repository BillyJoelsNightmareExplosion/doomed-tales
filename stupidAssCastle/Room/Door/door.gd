extends StaticBody3D

@export var open_at_start = false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready():
    if open_at_start:
        visible = false
        collision_shape.disabled = true


func close():
    visible = true
    collision_shape.set_deferred("disabled", false)
    print(collision_shape.disabled)


func open():
    # TODO: Animate the doors opening
    queue_free()
