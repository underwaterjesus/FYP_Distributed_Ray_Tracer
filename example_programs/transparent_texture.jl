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
globe_ball = make_sphere( ORIGIN, ball_radius, colour=BLUE, "./example_program_textures/globe_texture.png", diffuse=ball_diffuse, specular=ball_specular, shine=ball_shine, transparency=0.5 )
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

light = make_light(Vector_3D(5, 5, 6.5), 0.85, 0.45)

camera = make_camera( Vector_3D(0, 0, 2.5), ORIGIN, VERTICAL )

shapes = [ table, white_ball, yellow_ball, green_ball, brown_ball, globe_ball, pink_ball, black_ball,
            red_ball_1, red_ball_2, red_ball_3, red_ball_4, red_ball_5, red_ball_6, red_ball_7, red_ball_8,
            red_ball_9, red_ball_10, red_ball_11, red_ball_12, red_ball_13, red_ball_14, red_ball_15 ]

scene = make_scene( light=light, camera=camera, shapes=shapes )

img = render_scene(scene, 1080, 720, 60, 10)

save( File(format"PNG", "example_image.png"), img )