extends Node3D
class_name Block

func initialize(height : float):
    #prints("Initializing block with height", height)
    $Body.mesh.size.y = height
    $Body.get_surface_override_material(0).uv1_scale.y = height * 0.03
    $Body.position.y = height * 0.5
    $StaticBody3D/CollisionShape.shape.size.y = height
    $StaticBody3D/CollisionShape.position.y = height * 0.5
    #prints("Mesh size", $Body.mesh.size)
