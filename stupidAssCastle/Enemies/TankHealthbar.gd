extends Sprite3D

@onready var enemy = get_parent()
@onready var initial_health = enemy.health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    region_rect.size.x = (float(enemy.health) / initial_health) * 100
