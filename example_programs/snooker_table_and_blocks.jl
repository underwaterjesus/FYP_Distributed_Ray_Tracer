include("../src/trace.jl")
using .Trace
using FileIO

table_length = 22
table_width = 17
table_height = 0.5
table_centre = Vector_3D(0, -0.75, -2.5)
table_colour = RGBA(0.387, 0.668, 0.105, 1)
table_reflection = 0.1

ball_radius = 0.5
ball_diffuse = 0.85
ball_specular = 0
ball_shine = 750
ball_reflection = 0

table = make_cuboid(table_centre, table_length, table_width, table_height, colour=table_colour, reflection=table_reflection)

white_ball = make_sphere( Vector_3D(-2.5, 0, 6), ball_radius, colour=WHITE, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
yellow_ball = make_sphere( Vector_3D(5, 0, 5.5), ball_radius, colour=YELLOW, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
green_ball = make_sphere( Vector_3D(-5, 0, 5.5), ball_radius, colour=GREEN, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
brown_ball = make_sphere( Vector_3D(0, 0, 5.5), ball_radius, colour=BROWN, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
blue_ball = make_sphere( ORIGIN, ball_radius, colour=BLUE, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
pink_ball = make_sphere( Vector_3D(0, 0, -5.5), ball_radius, colour=PINK, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=0.65 )
black_ball = make_sphere( Vector_3D(0, 0, -11.5), ball_radius, colour=BLACK, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )

red_ball_1 = make_sphere( Vector_3D(0, 0, -6.5), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_2 = make_sphere( Vector_3D(-0.5, 0, -7.366), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_3 = make_sphere( Vector_3D(0.5, 0, -7.366), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_4 = make_sphere( Vector_3D(-1, 0, -8.232), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_5 = make_sphere( Vector_3D(0, 0, -8.232), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_6 = make_sphere( Vector_3D(1, 0, -8.232), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_7 = make_sphere( Vector_3D(-1.5, 0, -9.098), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_8 = make_sphere( Vector_3D(-0.5, 0, -9.098), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_9 = make_sphere( Vector_3D(0.5, 0, -9.098), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_10 = make_sphere( Vector_3D(1.5, 0, -9.098), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_11 = make_sphere( Vector_3D(-2, 0, -9.964), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_12 = make_sphere( Vector_3D(-1, 0, -9.964), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_13 = make_sphere( Vector_3D(0, 0, -9.964), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_14 = make_sphere( Vector_3D(1, 0, -9.964), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )
red_ball_15 = make_sphere( Vector_3D(2, 0, -9.964), ball_radius, colour=RED, diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, reflection=ball_reflection )

block_reflection = 0
bottom_left_block = make_cuboid( Vector_3D(-6.5, 0.1666, -2.375), 0.75, 4, 1.333, colour=RGBA(0.945, 0.801, 0.399), diffuse=0.95, shine=200, reflection=block_reflection )
bottom_mid_block = make_cuboid( Vector_3D(0, 0.1666, -2.375), 0.75, 4, 1.333, colour=RED, y_rot=45, diffuse=0.95, shine=200, reflection=0.5, sides=( FRONT, BACK ), transparency=0.75 )
top_mid_block = make_cuboid( Vector_3D(0, ( 0.1666+1.333 ), -2.375), 0.75, 4, 1.333, colour=RGBA(0.371, 0.332, 0.899), y_rot=-45, diffuse=0.95, shine=200 )
bottom_right_block = make_cuboid(Vector_3D(6.5, 0.1666, -2.375), 0.75, 4, 1.333, colour=RGBA(0.945, 0.801, 0.399), diffuse=0.95, shine=200, reflection=block_reflection )
#top_left_block = make_cuboid(Vector_3D(-3.25, 1.499, -2.375), 0.75, 3.5, 1.333, colour=RGBA(0.371, 0.332, 0.899), diffuse=0.95, shine=200, reflection=block_reflection)
#top_right_block = make_cuboid(Vector_3D(3.25, 1.499, -2.375), 0.75, 3.5, 1.333, colour=RGBA(0.371, 0.332, 0.899), diffuse=0.95, shine=200, reflection=block_reflection)

light_position = Vector_3D(0, 7.5, -2.25)
light = make_light(light_position, 0.9, 0.75)
light2 = make_light(Vector_3D(5, 5, 6.5), 0.5, 0.25)
light3 = make_light(Vector_3D(5, 5, 6.5), 0.85, 0.45)

camera_1 = make_camera( Vector_3D(9.5, 7, 0.5), Vector_3D(0, 0, -2.5), VERTICAL )
camera_2 = make_camera( Vector_3D(9.5, 7, 0.5), Vector_3D(0, 0, -2.5), Vector_3D(0.125, 1, 0) )
camera_3 = make_camera( Vector_3D(-11, -0.5, -6.5), Vector_3D(0, 0, -6.5), VERTICAL )
camera_4 = make_camera( Vector_3D(-10, 7, -7), Vector_3D(0, 0.5, -4.5), VERTICAL )
camera_5 = make_camera( Vector_3D(-10, 7, -7), Vector_3D(0, 0.5, -4.5), VERTICAL )
camera_6 = make_camera( Vector_3D(0, 2.25, -9), Vector_3D(0, 0.5, -2.5), VERTICAL )
camera_7 = make_camera( Vector_3D(-3.5, 0.1665, -2.375), Vector_3D(0, 0.1665, -2.375), VERTICAL )
camera_8 = make_camera( bottom_mid_block.centre, ORIGIN, VERTICAL )

shapes = [ table, white_ball, yellow_ball, green_ball, brown_ball, blue_ball, pink_ball, black_ball,
            red_ball_1, red_ball_2, red_ball_3, red_ball_4, red_ball_5, red_ball_6, red_ball_7, red_ball_8,
            red_ball_9, red_ball_10, red_ball_11, red_ball_12, red_ball_13, red_ball_14, red_ball_15,
            bottom_left_block, bottom_mid_block, bottom_right_block, top_mid_block #=top_left_block, top_right_block=# ]

scene = make_scene( light=light3, camera=camera_1, shapes=shapes )

#img1 = render_scene(camera_1, shapes, light, nothing)
#img2 = render_scene(camera_2, shapes, light, nothing)
#img3 = render_scene(camera_3, shapes, light, nothing)
img4 = render_scene(scene, 1080, 720, 60, 20)
#save( File(format"PNG", "example_image_1.png"), img1 )
#save( File(format"PNG", "example_image_2.png"), img2 )
#save( File(format"PNG", "example_image_3.png"), img3 )
save( File(format"PNG", "example_image_4.png"), img4 )