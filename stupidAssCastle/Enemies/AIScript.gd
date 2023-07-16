extends Node

@onready var enemy: CharacterBody3D = get_parent()
@onready var nav_agent = $"../NavigationAgent3D"
@onready var state_timer = $"../StateTimer"
@onready var try_attack_timer = $"../TryAttackTimer"

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@export var state_update_time = 1.0

@export var wander_for_time = 5.0
@export var wander_move_speed = 2.0
@export var wander_move_dist = 1.0

@export var attack_agro_max = 10;
@export var attack_move_speed = 3.0

var is_attacking = false

enum States {
    Wander,  
    MoveToAttack, 
    Attack, 
    BackUp
}

var current_state = States.Wander

# Called when the node enters the scene tree for the first time.
func _ready():
    print(get_tree().root.get_children()[0])
    state_timer.wait_time = state_update_time
    state_timer.start()
    
    try_attack_timer.wait_time = randi() % attack_agro_max
    try_attack_timer.start()
    
    current_state = States.Wander

func update_state():
    #pick random state between idle and wander
    if !is_attacking:     
        current_state = States.Wander
  
    print(current_state)
    update_nav_pos()

func update_nav_pos():
    if current_state == States.Wander:
        wander()
    
    print (nav_agent.target_position)

func _physics_process(delta):
    if current_state == States.Wander:
        move_enemy(wander_move_speed)
    elif current_state == States.MoveToAttack:
        move_to_attack()
        move_enemy(attack_move_speed)
        if nav_agent.target_reached:
            attack()

#States
func wander():
    #move in a random cardinal direction
    var rand = randi() % 4
    var current_location = enemy.position
    var try_pos;
    match (rand):
        0:
            try_pos = Vector3(current_location.x + wander_move_dist, current_location.y, current_location.z)
        1:
            try_pos = Vector3(current_location.x - wander_move_dist, current_location.y, current_location.z)
        2:
            try_pos = Vector3(current_location.x, current_location.y, current_location.z + wander_move_dist)
        3:
            try_pos = Vector3(current_location.x, current_location.y, current_location.z - wander_move_dist)
    
    update_target_location(try_pos)
    if nav_agent.is_target_reachable():
         state_timer.wait_time = wander_for_time;
    else:
        update_target_location(enemy.position)
        state_timer.wait_time = 0.0;
            
func move_to_attack():
    update_target_location(player.global_transform.origin)

func attack():
    pass
    
#helper funcs
func update_target_location(target_location):
    nav_agent.set_target_position(target_location)

func move_enemy(speed):
    var current_location = enemy.global_transform.origin
    var next_location = nav_agent.get_next_path_position()
    var new_velocity = (next_location - current_location).normalized() * speed
    
    nav_agent.set_velocity(new_velocity)

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
    enemy.velocity = enemy.velocity.move_toward(safe_velocity, .25)
    enemy.move_and_slide()
    
func try_attack():
    if can_attack():
        is_attacking = true
        state_timer.stop()
    else:
        is_attacking = false

func can_attack() -> bool:
    var enemies = get_tree().get_nodes_in_group("enemy")
    var check = 0
    for en in enemies:
        if en.get_ai().is_attacking:
            check += 1
    
    if check > 0:
        return false
    else:
        return true
    
