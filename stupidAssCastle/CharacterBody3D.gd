extends CharacterBody3D

signal need_bluud(posi, rot)

@export var SPEED = 5.0
# Do we even do jumping?
@export var JUMP_VELOCITY = 4.5
@export var LOOK_SENSITVITY = 0.1

@export var DAMAGE = 1
@export var RANGE = 100
@export var PELLET_COUNT = 15
@export var SPREAD = 30 # in max degrees, think cone
@export var SHOTTIME = 0.5

@export var MAX_AMMO = 7
@export var MAX_HEALTH = 5

@export var DASHSPEED = 10
@export var DASHFORTIME = 0.5
@export var DASHCOOLDOWN = 2.5

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var stock = $Head/Stock
@onready var muzzle = $Head/Stock/Barrel/Muzzle
@onready var anim_player = $AnimationPlayer

@onready var world = get_tree().root.get_children()[0]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var aim_casts = []
var half_spread

var health = MAX_HEALTH
var ammo = MAX_AMMO
var can_shoot = true

var can_dash = true
var is_dashing = false

func _ready():
    # getting pellet spread to work
    for i in range(PELLET_COUNT):
        var aim_cast = RayCast3D.new()
        aim_cast.target_position = Vector3(0, 0, -1 * RANGE)
        aim_casts.append(aim_cast)
        camera.add_child(aim_cast)
    half_spread = SPREAD / 2
    fire(false) # randomize rotations without killing anything
    
    $DashCooldown.wait_time = DASHCOOLDOWN
    $DashTimer.wait_time = DASHFORTIME
    $ShotgunTimer.wait_time = SHOTTIME

func _physics_process(delta):
    
    if Input.is_action_just_pressed("fire"):
        if can_shoot:
            fire()
    elif Input.is_action_just_pressed("reload"):
        # Anim
        anim_player.play("reload")
        # UI
        ammo = MAX_AMMO
    else:
        # recoil reset
        stock.rotation_degrees.x = stock.rotation_degrees.x * 0.97
    
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle Jump.
    #if Input.is_action_just_pressed("jump") and is_on_floor():
        #velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        var use_speed
        if is_dashing:
            use_speed = DASHSPEED
        else:
            use_speed = SPEED
        velocity.x = direction.x * use_speed
        velocity.z = direction.z * use_speed
    else:
        var use_speed
        if is_dashing:
            use_speed = DASHSPEED
        else:
            use_speed = SPEED
        velocity.x = move_toward(velocity.x, 0, use_speed)
        velocity.z = move_toward(velocity.z, 0, use_speed)

    if Input.is_action_just_pressed("dash"):
        if can_dash:
            dash()

    move_and_slide()
    
func dash():
    is_dashing = true
    $DashTimer.start()

func stop_dash():
    is_dashing = false
    can_dash = false
    $DashTimer.stop()
    $DashCooldown.start()

func _input(event):
    #get mouse input for camera rotation
    if event is InputEventMouseMotion and world.capture_mouse:
        rotate_y(deg_to_rad(-event.relative.x * LOOK_SENSITVITY))
        # code for up/down look
        # head.rotate_x(deg_to_rad(-event.relative.y * LOOK_SENSITVITY))
        # head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func fire(kill=true): # I've added this kill arg just so positions get scrambled on ready
    if not ammo or anim_player.is_playing():
        return
    ammo -= 1
    can_shoot = false
    $ShotgunTimer.start()
    
    stock.rotation_degrees.x -= 10
    
    for aim_cast in aim_casts:
        # rotate randomly
        aim_cast.rotation_degrees = Vector3((randi_range (half_spread * -1, half_spread)),(randi_range (half_spread * -1, half_spread)), 0)
        # check collision and do shit
        if aim_cast.is_colliding():
                var bullet = get_world_3d().direct_space_state
                var query = PhysicsRayQueryParameters3D.create(muzzle.global_transform.origin, aim_cast.get_collision_point())
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
                        need_bluud.emit(collision.position, Vector3(90,(randi_range (0,360)),0))
                        target.health -= DAMAGE
                        
func reset_dash():
    can_dash = true
    $DashCooldown.stop()

func reset_shoot_cooldown():
    can_shoot = true
    $ShotgunTimer.stop()
