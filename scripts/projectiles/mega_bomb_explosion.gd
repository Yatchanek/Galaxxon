extends Node3D
class_name MegaBombExplosion

@export var hurtbox_scene : PackedScene
@export var laser_curve : CurveTexture

@onready var hurtboxes : Node3D = $Hurtboxes

var elapsed_time : float = 0.0

var mat : ShaderMaterial = preload("res://resources/materials/laser_shader_material.tres")

var targets : Array = []

func _ready() -> void:
    set_process(false)
    explode()


func _process(delta: float) -> void:
    elapsed_time += delta
    if elapsed_time >= 1.0:
        queue_free()

    for i in targets.size():
        if is_instance_valid(targets[i]):
            hurtboxes.get_child(i).position = to_local(targets[i].global_position)

func explode():
    set_process(true)
    var shape : SphereShape3D = SphereShape3D.new()
    shape.radius = 90.0

    var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

    var shape_query : PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
    shape_query.collide_with_areas = true
    shape_query.shape = shape
    shape_query.collision_mask = 8
    shape_query.transform = transform

    var results : Array[Dictionary] = space_state.intersect_shape(shape_query)


    if results.size() > 0:
        for result_dict : Dictionary in results:
            if result_dict.collider is HitBox:
                var ray_query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(global_position, result_dict.collider.global_position, 1)
                var ray_result : Dictionary = space_state.intersect_ray(ray_query)

                if !ray_result:
                    targets.append(result_dict.collider.actor)
    else:
        queue_free()

    if targets.is_empty():
        queue_free()
  
    elif targets.size() > 1:
        targets.sort_custom(func(a, b): return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position))

    #targets.resize(5)

    for target in targets:
        var h_b : HurtBox = hurtbox_scene.instantiate()
        h_b.position = to_local(target.global_position)
        h_b.collision_layer = 32
        h_b.damage = 10
        h_b.damage_type = h_b.DamageType.CONTINUOUS
        h_b.damage_interval = 0.05
        hurtboxes.add_child.call_deferred(h_b)


        var mesh_instance : MeshInstance3D = MeshInstance3D.new()
        var mesh : TubeTrailMesh = TubeTrailMesh.new()
        
        var dist : float = global_position.distance_to(target.global_position)
        var dir : Vector3 = global_position.direction_to(target.global_position)

        mesh.radius = 0.5
        mesh.section_length = dist / mesh.sections
        mesh_instance.mesh = mesh
        mesh.curve = laser_curve.curve
        mesh_instance.basis = global_transform.looking_at(target.global_position).basis
        mesh_instance.position = dir * dist * 0.5
        mesh_instance.rotation.x += PI / 2
        mesh_instance.material_override = mat
        mesh_instance.set_instance_shader_parameter("laser_color", Color.RED)

        add_child(mesh_instance)