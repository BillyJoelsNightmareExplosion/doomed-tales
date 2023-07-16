extends Node3D

@export var bluud_texture = Texture2D
@export var life = 0.1

@onready var player: CharacterBody3D = get_tree().root.get_children()[0].get_player()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#    add_bluud(Vector3(0,5,0), Vector3(0,-5,0))
    pass

func add_bluud(posi, rot):
    var bluud_node = Bluud.new()
    bluud_node.init(bluud_texture, posi, rot, life)
    add_child(bluud_node)
