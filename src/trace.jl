module Trace

include("render.jl")

export RGBA
export Vector_3D
export Shape
export ORIGIN, VERTICAL, HORIZONTAL, HORIZONTAL_UP
export LEFT, RIGHT, FRONT, BACK, TOP, BOTTOM
export WHITE, RED, YELLOW, GREEN, BROWN, BLUE, PINK, BLACK, TRANSPARENT

export set_shapes, set_light, set_camera, set_boundary
export clear_shapes, clear_light, clear_camera, clear_boundary
export append!, push!, shape_details, scene_details
export make_scene, make_cuboid, make_sphere, make_camera
export make_vector, make_light, render_scene

end