@tool
extends Path3D

@export var speed = 100
@export var distance_between_planks = 1.5:
    set(value):
        distance_between_planks = value
        is_dirty = true


@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()
@onready var path_follow = $PathFollow3D

var is_dirty = false
var ziping = false

var init_pos

func toogle_grab_player():
    if not (player.get_parent() == path_follow):
        ziping = true
        init_pos = player.position
    else:
        ziping = false
        


# Called when the node enters the scene tree for the first time.
func _ready():
    _update_multimesh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if Input.is_action_just_pressed("ui_down"):
        toogle_grab_player()
    
    if ziping:
        if path_follow.progress_ratio >= 1:
            ziping = false
        else:    
            path_follow.progress += speed * delta
            print(path_follow.progress_ratio)
            player.position = init_pos + path_follow.position
    if is_dirty:
        _update_multimesh()
        is_dirty = false
    pass



func _update_multimesh():
    var path_length: float = curve.get_baked_length()
    var count = floor(path_length / distance_between_planks)

    var mm: MultiMesh = $MultiMeshInstance3D.multimesh
    mm.instance_count = count
    var offset = distance_between_planks/2.0

    for i in range(0, count):
        var curve_distance = offset + distance_between_planks * i
        var position = curve.sample_baked(curve_distance, true)

        var basis = Basis()
        
        var up = curve.sample_baked_up_vector(curve_distance, true)
        var forward = position.direction_to(curve.sample_baked(curve_distance + 0.1, true))

        basis.y = up
        basis.x = forward.cross(up).normalized()
        basis.z = -forward
        
        var transform = Transform3D(basis, position)
        mm.set_instance_transform(i, transform)


func _on_curve_changed():
    is_dirty = true
