extends CharacterBody3D


@export var SPEED = 5.0
# Do we even do jumping?
@export var JUMP_VELOCITY = 4.5
@export var LOOK_SENSITVITY = 1

var mouse_sense = 0.1

@onready var head = $Head

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
    pass
    
func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle Jump.
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
    
func _input(event):
    #get mouse input for camera rotation
    if event is InputEventMouseMotion:
        rotate_y(deg_to_rad(-event.relative.x * mouse_sense) * LOOK_SENSITVITY)
        # code for up/down look
        # head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
        # head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
