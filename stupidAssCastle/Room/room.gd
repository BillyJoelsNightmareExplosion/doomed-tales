extends Node3D

@export var num_enemies_min = 3
@export var num_enemies_max = 5

@export var enemy_pool: Array[PackedScene] = []

@export var is_final_boss = false

var enemy_count = 0

signal game_end

func  _ready():
    $CanvasLayer/EndScreen.visible = false

func spawn_enemies():
    enemy_count = randi_range(num_enemies_min, num_enemies_max)
    print(enemy_count)
    for i in range(0, enemy_count):
        spawn_random_enemy()


func spawn_random_enemy():
    var spawn_shapes = $SpawnShapes.get_children() as Array[CollisionShape3D]
    if not enemy_pool or enemy_pool.size() == 0 or not spawn_shapes or spawn_shapes.size() == 0:
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


func enemy_died():
    enemy_count -= 1
    if enemy_count <= 0:
        for door in get_node("Doors").get_children():
            door.open()
        if is_final_boss:
            await get_tree().create_timer(2.5).timeout
            end_game()

func end_game():
    $CanvasLayer/EndScreen.visible = true
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
