extends Node3D

@export var num_enemies_min = 3
@export var num_enemies_max = 5

@export var spawn_paths: Array[Path3D] = []
@export var enemy_pool: Array[PackedScene] = []

var enemies_alive = 0


func _ready():
    for i in range(0, 5):
        spawn_random_enemy()


func spawn_random_enemy():
    if not spawn_paths or spawn_paths.size() == 0 or not enemy_pool or enemy_pool.size() == 0:
        return
        
    var path = spawn_paths[randi_range(0, spawn_paths.size() - 1)]
    var enemy: CharacterBody3D = enemy_pool[randi_range(0, enemy_pool.size() - 1)].instantiate()
    add_child(enemy)
    
    enemy.global_position = path.curve.samplef(randf() * (path.curve.point_count - 1)) + path.global_position
    enemy.died.connect(enemy_died)
    
    enemies_alive += 1


func enemy_died():
    enemies_alive -= 1
    if enemies_alive == 0:
        for door in get_node("Doors").get_children():
            door.open()
