extends Node3D

@export var num_enemies_min = 3
@export var num_enemies_max = 5

@export var enemy_pool: Array[PackedScene] = []

@onready var spawn_shapes = $SpawnShapes.get_children() as Array[CollisionShape3D]

var enemies_alive = 0


func spawn_enemies():
    for i in range(0, randi_range(num_enemies_min, num_enemies_max)):
        spawn_random_enemy()


func spawn_random_enemy():
    if not enemy_pool or enemy_pool.size() == 0:
        return
    
    var shape = spawn_shapes[randi_range(0, spawn_shapes.size() - 1)]
    var shape_pos = shape.global_position
    var shape_size: Vector3 = shape.shape.size
    var pos = Vector3(
        shape_pos.x + randf_range(-shape_size.x, shape_size.x),
        shape_pos.y - shape_size.y,
        shape_pos.z + randf_range(-shape_size.z, shape_size.z),
    )
    
    var enemy: CharacterBody3D = enemy_pool[randi_range(0, enemy_pool.size() - 1)].instantiate()
    add_child(enemy)
    
    enemy.global_position = pos
    enemy.died.connect(enemy_died)
    
    enemies_alive += 1


func enemy_died():
    enemies_alive -= 1
    if enemies_alive == 0:
        for door in get_node("Doors").get_children():
            door.open()
