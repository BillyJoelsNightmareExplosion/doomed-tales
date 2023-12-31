@tool
class_name Zipline extends Path3D

@export var FOLLOW_RATE = 1
@export var DROOP_Y = 10
@export var INSTANCE_DISTANCE = 1.5

@onready var END = $END
@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

var path_follow
var mm

var direction = 0

var has_player = false

var init_player_pos
var abs_progress = 0

var start_col

var last_pos
var end_pos_local

var is_initialized = false

func new_collider(pos=null):
    var new_area = Area3D.new()
    add_child(new_area)
        
    var new_col = CollisionShape3D.new()
    new_area.add_child(new_col)
    new_col.shape = preload("res://Zipline/zipline_collision_shape.tres")
    return new_area

func init():
    is_initialized = true
    curve.clear_points()
    curve.add_point(Vector3.ZERO)
    curve.add_point(Vector3.ONE)
    
    path_follow = PathFollow3D.new()
    add_child(path_follow)
    
    var multi_mesh = MultiMeshInstance3D.new()
    add_child(multi_mesh)
    multi_mesh.multimesh = MultiMesh.new()
    multi_mesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multi_mesh.multimesh.set_mesh(preload("res://art/particles/zip_mesh.tres"))
    mm = multi_mesh.multimesh
    
    var csg_poly = CSGPolygon3D.new()
    add_child(csg_poly)
    csg_poly.polygon = PackedVector2Array([Vector2(0,0), Vector2(0,0.1), Vector2(0.1,0.1)])
    csg_poly.mode = CSGPolygon3D.MODE_PATH
    csg_poly.set_path_node("..")
    csg_poly.path_local = true
    csg_poly.material = preload("res://Zipline/M_zipline.tres")

    update_curve()

# Called when the node enters the scene tree for the first time.
func _ready():
    init()
    
func update_curve():    
    if END.position != Vector3.ZERO:
        end_pos_local = END.position
    else:
        end_pos_local = Vector3(1,1,1)
    last_pos = position
    curve.set_point_position(1, end_pos_local)
    var end_in = ( end_pos_local - end_pos_local/2 ) * -1
    end_in.y = end_pos_local.y - DROOP_Y
    curve.set_point_in(1, end_in)
    
    start_col = new_collider()
    
    _update_multimesh()

func toggle_grab_player():
    has_player = true
    init_player_pos = player.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    
    if Engine.is_editor_hint():
        if position != last_pos or end_pos_local != END.position:
            update_curve()
    else:
        if Input.is_action_just_pressed("jump"):
            if start_col.overlaps_body(player):
                direction = 1
                toggle_grab_player()
        
        if has_player:
            if not abs_progress:
                path_follow.progress_ratio = 0 if direction > 0 else 1
            
            if abs_progress >= 1:
                has_player = false
                abs_progress = 0
            else:
                abs_progress = min(abs_progress + FOLLOW_RATE * delta, 1.0)
                path_follow.progress_ratio = abs_progress
                #print(path_follow.progress)
                player.position = init_player_pos + path_follow.position
    pass

func _update_multimesh():
    curve.set_point_position(1, end_pos_local)
    
    var path_length: float = curve.get_baked_length()
    var count = floor(path_length / INSTANCE_DISTANCE)

    mm.instance_count = count
    var offset = INSTANCE_DISTANCE/2.0

    for i in range(0, count):
        var curve_distance = offset + INSTANCE_DISTANCE * i
        var position = curve.sample_baked(curve_distance, true)

        var basis = Basis()
        
        var up = curve.sample_baked_up_vector(curve_distance, true)
        var forward = position.direction_to(curve.sample_baked(curve_distance + 0.1, true))

        basis.y = up
        basis.x = forward.cross(up).normalized()
        basis.z = -forward
        
        var transform = Transform3D(basis, position)
        mm.set_instance_transform(i, transform)

