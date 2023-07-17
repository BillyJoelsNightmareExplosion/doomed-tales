extends Node

signal hit_player

@onready var enemy: CharacterBody3D = get_parent()
@onready var nav_agent = $"../NavigationAgent3D"
@onready var state_timer = $"../StateTimer"
@onready var try_attack_timer = $"../TryAttackTimer"
@onready var animator: AnimatedSprite3D = $"../AnimatedSprite3D"

@onready var s_player_hurt = preload("res://sound/p_hurt.ogg")
@onready var s_attack = preload("res://sound/punch.wav")

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

@export var state_update_time = 1.0 #how often the enemy should try update state

@export var wander_for_time = 5.0 #how long the enemy moves towards a wander point for, before getting a new wander point
@export var wander_move_speed = 2.0 #how fast the enemy moves while wandering
@export var wander_move_dist = 1.0 #how far the enemy looks for a new wander point

@export var move_closer_distance = 5.0

@export var attack_agro_max = 10 #how often the enemy attacks
@export var attack_move_speed = 3.0 #how fast the enemy moves towards the player to attack
@export var attack_stop_distance = 2.0 #how far away from the player the enemy stops to attack
@export var attack_range = 2.0 #how far from the enemy the player will take damage
@export var attack_damage = 10.0 #how much damage the attack does
@export var attack_startup_time = 0.5 #how long the attack animation takes to play
@export var attack_end_lag_time = 0.5 #how long the enemy will be stunned after attacking

var stream_player

var is_attacking = false
var attacking = false
var is_dead = false

enum States {
    Wander,
    MoveCloser,
    MoveToAttack, 
    Attack, 
    BackUp
}

var current_state = States.Wander

# Called when the node enters the scene tree for the first time.
func _ready():
    state_timer.wait_time = state_update_time
    state_timer.start()
    
    try_attack_timer.wait_time = randi_range(1, attack_agro_max)
    try_attack_timer.start()
    
    current_state = States.Wander
    
    stream_player = AudioStreamPlayer.new()
    add_child(stream_player)
    stream_player.autoplay = true

func update_state():
    #pick random state between wander and move closer
    if !is_attacking:
        var rand = randi_range(0, 1)
        if rand == 0: 
            current_state = States.Wander
            wander()
        elif rand == 1:
            current_state = States.MoveCloser

func _physics_process(delta):
    if current_state == States.Wander:
        move_enemy(wander_move_speed)
    elif current_state == States.MoveCloser:
        move_closer()
        move_enemy(wander_move_speed)
    elif current_state == States.MoveToAttack:
        move_to_attack()
        move_enemy(attack_move_speed)
    elif current_state == States.Attack:
        attack()

#States
func wander():
    #move in a random cardinal direction
    var rand = randi() % 4
    var current_location = enemy.global_position
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
        update_target_location(enemy.global_position)
        state_timer.wait_time = 0.001;
        
    #animator.play("idle")
            
func move_closer():
    update_target_location(player.global_transform.origin)
    animator.play("walk")
    if nav_agent.distance_to_target() < move_closer_distance:
        update_target_location(enemy.global_position)

func move_to_attack():
    update_target_location(player.global_transform.origin)
    animator.play("walk")
    if nav_agent.distance_to_target() < attack_stop_distance:
        update_target_location(enemy.global_position)
        attacking = true
        current_state = States.Attack

func attack():
    if attacking:
        attacking = false
        animator.play("attack")
        stream_player.stream = s_attack
        stream_player.play()
        await get_tree().create_timer(attack_startup_time).timeout
        if enemy.global_position.distance_to(player.global_position) < attack_range:
            if !is_dead:
                print("Hit!")
                player.health -= attack_damage
                stream_player.stream = s_player_hurt
                stream_player.play()
        else:
            print("Safe!")
            
        is_attacking = false
        await  get_tree().create_timer(attack_end_lag_time).timeout
        reset_enemy_to_wander()
    
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
        current_state = States.MoveToAttack
        state_timer.stop()
        try_attack_timer.stop()
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
    
func reset_enemy_to_wander():
    current_state = States.Wander
    state_timer.start()
    try_attack_timer.start()
    
func set_to_dead():
    is_dead = true
