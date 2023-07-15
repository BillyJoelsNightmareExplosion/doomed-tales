extends CharacterBody3D


@export var SPEED = 5.0
# Do we even do jumping?
@export var JUMP_VELOCITY = 4.5
@export var LOOK_SENSITVITY = 0.1

@export var DAMAGE = 1
@export var RANGE = 100
@export var PELLET_COUNT = 5
@export var SPREAD = 45 # in max degrees, think cone 

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var muzzle = $Head/Gun/Muzzle

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var aimcasts = []

func _ready():
    for i in PELLET_COUNT:
        var aimcast = RayCast3D.new()
        aimcast.target_position = Vector3(0, 0, -1 * RANGE)
        aimcasts.append(aimcast)
        camera.add_child(aimcast)
    print("added aimcasts")
    pass
    
func _physics_process(delta):
    
    if Input.is_action_just_pressed("fire"):
        fire()
    
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
        rotate_y(deg_to_rad(-event.relative.x * LOOK_SENSITVITY))
        # code for up/down look
        # head.rotate_x(deg_to_rad(-event.relative.y * LOOK_SENSITVITY))
        # head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func fire():
    for aimcast in aimcasts:
        # rotate randomly
        
        # check collision and do shit
        if aimcast.is_colliding():
                var bullet = get_world_3d().direct_space_state
                var query = PhysicsRayQueryParameters3D.create(muzzle.global_transform.origin, aimcast.get_collision_point())
                var collision = bullet.intersect_ray(query)

                if collision:
                    var target = collision.collider

                    if target.is_in_group("enemy"):
                        print("hit enemy")
                        target.health -= DAMAGE
