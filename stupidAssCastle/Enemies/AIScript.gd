extends Node

@onready var enemy: CharacterBody3D = get_parent()
@onready var nav_agent = $"../NavigationAgent3D"
@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@export var SPEED = 3.0

enum States {
    Idle, 
    Wander, 
    WaitToAttack, 
    MoveToAttack, 
    Attack, 
    BackUp
}

var current_state = States.Idle

# Called when the node enters the scene tree for the first time.
func _ready():
    print(get_tree().root.get_children()[0])
    
    await get_tree().create_timer(1.0).timeout
    current_state = States.MoveToAttack


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _physics_process(delta):
    if current_state == States.MoveToAttack:
        move_to_attack()
    
func move_to_attack():
    update_target_location(player.global_transform.origin)
    
    var current_location = enemy.global_transform.origin
    var next_location = nav_agent.get_next_path_position()
    var new_velocity = (next_location - current_location).normalized() * SPEED
    
    enemy.velocity = enemy.velocity.move_toward(new_velocity, .25)
    enemy.move_and_slide()

func update_target_location(target_location):
    nav_agent.set_target_position(target_location)
