using Distributed

machines = [("ubuntu@3.249.197.51",1),("ubuntu@34.248.8.28",1),("ubuntu@34.240.33.89",1)]
dir = "/home/ubuntu"
addprocs( machines; dir=dir, topology=:master_worker, tunnel=true )

@everywhere include("../src/trace.jl")
@everywhere using .Trace
using FileIO

table_length = 22
table_width = 17
table_height = 1
table_centre = ORIGIN
table_colour = RGBA(0.387, 0.668, 0.105, 1)
table_reflection = 0.1
table = make_cuboid(table_centre, table_length, table_width, table_height, colour=table_colour, reflection=table_reflection)

ball_radius = 0.7
ball_diffuse = 0.85
ball_specular = 0
ball_shine = 750
ball_reflection = 0.1
globe = make_sphere( Vector_3D(1, 1.2, 1.4), ball_radius, "example_program_textures/globe_texture.png", y_rot=-70, colour=TRANSPARENT, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )

block_reflection = 0
chest_texture = make_texture("example_program_textures/mc_chest_cube_map.png")
dirt_texture = make_texture("example_program_textures/mc_dirt_cube_map.png")
chest = make_cuboid( Vector_3D(0, 0.8125+eps(Float64), 0), 0.625, 1, 0.625, colour=TRANSPARENT, diffuse=0.95, shine=200, reflection=block_reflection, texture=chest_texture, map_mode=CUBE_MAP )
dirt = make_cuboid( Vector_3D(0.3, 1.325+eps(Float64), 0.078), 0.4, 0.4, 0.4, colour=RED, y_rot=45, diffuse=0.95, shine=200, texture=dirt_texture, map_mode=CUBE_MAP )

light_position = Vector_3D(-3, 7.5, 1.55)
light = make_light(light_position, 0.9, 0.7)

camera = make_camera( Vector_3D(-1.5, 1.2, 1), Vector_3D(0, 0.75, 0.65), VERTICAL )
shapes = [ table, globe, chest, dirt ]
scene = make_scene( light=light, camera=camera, shapes=shapes )

img = render_scene(scene, 3840, 2160, 60, 20, worker_list=workers())
save( File(format"PNG", "example_image_3.png"), img )