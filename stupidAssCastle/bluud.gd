class_name Bluud extends Node3D

var _timer
var _decal
var _particles

var _life
var texture


func _ready():
    # timer
    _timer = Timer.new()
    add_child(_timer)
    _timer.timeout.connect(_on_timer_timeout)
    _timer.start(10)
    
    # decal
    _decal = Decal.new()
    add_child(_decal)
    _decal.set_texture(0, texture)
    # pariticles
    
    _particles = GPUParticles3D.new()
    add_child(_particles)
    _particles.one_shot = true
    _particles.explosiveness = 1
    # note: these are preloaded and instanced at compile so there's not a bunch of loading here
    _particles.process_material = preload("res://art/particles/bluud_process_mat.tres")
    var mesh = preload("res://art/particles/bluud_particle_mesh.tres")
    mesh.material = preload("res://art/particles/bluud_particle_mat.tres")
    _particles.draw_pass_1 = mesh
    
    
func init(_texture, posi, rot, life):
    _life = life
    position = posi
    rotation = rot
    texture = _texture
    
func _on_timer_timeout():
    queue_free()
