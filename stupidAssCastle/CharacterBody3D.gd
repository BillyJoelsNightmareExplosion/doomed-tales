extends CharacterBody3D


@export var SPEED = 5.0
# Do we even do jumping?
@export var JUMP_VELOCITY = 4.5
@export var LOOK_SENSITVITY = 0.1

@export var DAMAGE = 1
@export var RANGE = 100
@export var PELLET_COUNT = 7
@export var SPREAD = 40 # in max degrees, think cone

@export var MAX_AMMO = 7
@export var MAX_HEALTH = 5

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var muzzle = $Head/Gun/Muzzle

@onready var healthtext = $Head/Camera3D/UserInterfaceControl/HealthValue
@onready var ammotext = $Head/Camera3D/UserInterfaceControl/AmmoValue

@onready var world: World = get_tree().root.get_children()[0]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var aimcasts = []
var half_spread

var health = MAX_HEALTH
var ammo = MAX_AMMO

func _ready():
    # getting pellet spread to work
    for i in range(PELLET_COUNT):
        var aimcast = RayCast3D.new()
        aimcast.target_position = Vector3(0, 0, -1 * RANGE)
        aimcasts.append(aimcast)
        camera.add_child(aimcast)
    print("added aimcasts")
    half_spread = SPREAD / 2
    fire(false)
    
    # setting UI values
    healthtext.text = str(health)
    ammotext.text = str(ammo)
    pass
    
    
func _process(delta):
    # replace this with the actual taking damage if it becomes a function
    healthtext.text = str(health)
    pass

func _physics_process(delta):
    
    if Input.is_action_just_pressed("fire"):
        fire()
    elif Input.is_action_just_pressed("reload"):
        ammo = MAX_AMMO
        ammotext.text = str(ammo)
    
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
    if event is InputEventMouseMotion and world.capture_mouse:
        rotate_y(deg_to_rad(-event.relative.x * LOOK_SENSITVITY))
        # code for up/down look
        # head.rotate_x(deg_to_rad(-event.relative.y * LOOK_SENSITVITY))
        # head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func fire(kill=true): # I've added this kill arg just so positions get scrambled on ready
    if not ammo:
        return
    ammo -= 1
    ammotext.text = str(ammo)
    
    for aimcast in aimcasts:
        # rotate randomly
        aimcast.rotation_degrees = Vector3((randi_range (half_spread * -1, half_spread)),(randi_range (half_spread * -1, half_spread)), 0)
        # check collision and do shit
        if aimcast.is_colliding():
                var bullet = get_world_3d().direct_space_state
                var query = PhysicsRayQueryParameters3D.create(muzzle.global_transform.origin, aimcast.get_collision_point())
                var collision = bullet.intersect_ray(query)

                if collision:
                    var target = collision.collider
#                    # debug
#                    var mesh = MeshInstance3D.new()
#                    mesh.mesh = SphereMesh.new()
#                    mesh.mesh.radius = 0.1
#                    mesh.mesh.height = 0.1
#                    mesh.global_position = collision.position
#                    get_tree().root.add_child(mesh)
                    
                    if target.is_in_group("enemy") and kill:
                        target.health -= DAMAGE
