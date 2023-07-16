class_name Bluud extends Decal

var timer

# Called when the node enters the scene tree for the first time.
func _ready():
    pass
    
func init(_texture, posi, rot, life):
    timer = Timer.new()
    timer.one_shot = true
    timer.wait_time = life

    position = posi
    rotation = rot
    set_texture(0, _texture)
    timer.timeout.connect(_on_timer_timeout)
    timer.start()

func _on_timer_timeout():
    queue_free()
