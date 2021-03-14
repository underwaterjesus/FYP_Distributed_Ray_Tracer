using Images: RGBA, load
using Printf

struct Vector_3D

    x::Float64
    y::Float64
    z::Float64

end

struct Ray

    origin::Vector_3D
    direction::Vector_3D

end

struct IntersectionValues

    t1::Float64
    t2::Union{Float64, Nothing}
    side1::Union{Int, Nothing}
    side2::Union{Int, Nothing}
    transparency1::Union{Float64, Nothing}
    transparency2::Union{Float64, Nothing}

end

struct Light 

    position::Vector_3D
    brightness::Float32
    ambient::Float32

end

struct Camera

    origin::Vector_3D
    focus::Vector_3D
    up_vector::Vector_3D

end

struct Texture

    map::Union{Array{RGBA{Float64}}, Array{RGBA{Float64}, 2}}

end

abstract type Shape end

struct Sphere <: Shape

    centre::Vector_3D
    radius::Float64
    colour::RGBA
    diffuse::Float64
    specular::Float64
    shine::Float64
    reflection::Float64
    transparency::Float64
    refraction::Float64
    texture::Union{Texture, Nothing}

end

struct Plane <: Shape

    upper_left::Vector_3D
    lower_left::Vector_3D
    upper_right::Vector_3D
    lower_right::Vector_3D
    reflection::Float64
    transparency::Float64
    refraction::Float64

end

struct Cuboid <: Shape

    centre::Vector_3D
    left::Plane
    right::Plane
    front::Plane
    back::Plane
    top::Plane
    bottom::Plane
    colour::RGBA
    diffuse::Float32
    specular::Float32
    shine::Float32

end

struct BoundingBox

    left::Plane
    right::Plane
    front::Plane
    back::Plane
    top::Plane
    bottom::Plane
    diffuse::Float32
    specular::Float32
    shine::Float32

end

mutable struct Scene

    boundary::Union{ BoundingBox, Nothing }
    shapes::Array{ <:Shape }
    light::Union{ Light, Nothing }
    camera::Union{ Camera, Nothing }

end

########################
## Constructor Functions
########################

function make_scene( len::Real=0, width::Real=0, height::Real=0 ;
    light::Union{Light, Nothing}=nothing, camera::Union{Camera, Nothing}=nothing, shapes::Array{<:Shape}=Shape[],
    diffuse::Real=0.5, specular::Real=0.5, shine::Real=250 )

    if shine < 0 throw( DomainError(shine, "argument \"shine\" must be nonnegative") ) end
    if specular < 0 || specular > 1 throw( DomainError(specular, "argument \"specular\" must be between 0 and 1 inclusive") ) end
    if diffuse < 0 || diffuse > 1 throw( DomainError(diffuse, "argument \"diffuse\" must be between 0 and 1 inclusive") ) end

    if len <= 0 || width <= 0 || height <= 0
        box = nothing
    else
        a = Vector_3D( -width/2, height/2, len/2 )
        b = Vector_3D( width/2, height/2, len/2 )
        c = Vector_3D( -width/2, height/2, -len/2 )
        d = Vector_3D( width/2, height/2, -len/2 )
            
        w_ = Vector_3D( -width/2, -height/2, len/2 )
        x = Vector_3D( width/2, -height/2, len/2 )
        y = Vector_3D( -width/2, -height/2, -len/2 )
        z = Vector_3D( width/2, -height/2, -len/2 )
            
        left = Plane( c, y, a, w_, 0 )
        right = Plane( b, x, d, z, 0 )
        front = Plane( a, w_, b, x, 0 )
        back = Plane( c, y, d, z, 0 )
        top = Plane( c, a, d, b, 0 )
        bottom = Plane( w_, y, x, z, 0 )
            
        box = BoundingBox(left, right, front, back, top, bottom, diffuse, specular, shine)
    end

    return Scene( box, shapes, light, camera )

end

function make_cuboid( centre::Vector_3D, len::Real, width::Real, height::Real ;
    x_rot::Real=0, y_rot::Real=0, z_rot::Real=0, colour::RGBA=GREEN,
    diffuse::Real=0.5, specular::Real=0, shine::Real=500, transparency::Real=0, refraction::Real=0,
    reflection::Real=0, sides::Union{ Int, Tuple{Int, Vararg{Int}} }=( LEFT, RIGHT, FRONT, BACK, TOP, BOTTOM ) )

    if len <= 0 throw( DomainError(len, "argument \"len\" must be greater than zero") ) end
    if width <= 0 throw( DomainError(width, "argument \"width\" must be greater than zero") ) end
    if height <= 0 throw( DomainError(height, "argument \"height\" must be greater than zero") ) end
    if refraction < 0 throw( DomainError(refraction, "argument \"refraction\" must be nonnegative") ) end
    if shine < 0 throw( DomainError(shine, "argument \"shine\" must be nonnegative") ) end
    if specular < 0 || specular > 1 throw( DomainError(specular, "argument \"specular\" must be between 0 and 1 inclusive") ) end
    if diffuse < 0 || diffuse > 1 throw( DomainError(diffuse, "argument \"diffuse\" must be between 0 and 1 inclusive") ) end
    if reflection < 0 || reflection > 1 throw( DomainError(reflection, "argument \"reflection\" must be between 0 and 1 inclusive") ) end
    if transparency < 0 || transparency > 1 throw( DomainError(transparency, "argument \"transparency\" must be between 0 and 1 inclusive") ) end

    a = Vector_3D( -width/2, height/2, len/2 )
    b = Vector_3D( width/2, height/2, len/2 )
    c = Vector_3D( -width/2, height/2, -len/2 )
    d = Vector_3D( width/2, height/2, -len/2 )

    w_ = Vector_3D( -width/2, -height/2, len/2 )
    x = Vector_3D( width/2, -height/2, len/2 )
    y = Vector_3D( -width/2, -height/2, -len/2 )
    z = Vector_3D( width/2, -height/2, -len/2 )

    if abs(x_rot) > 0
        a = rotate_on_axis(a, x_rot, X_AXIS)
        b = rotate_on_axis(b, x_rot, X_AXIS)
        c = rotate_on_axis(c, x_rot, X_AXIS)
        d = rotate_on_axis(d, x_rot, X_AXIS)
        w_ = rotate_on_axis(w_, x_rot, X_AXIS)
        x = rotate_on_axis(x, x_rot, X_AXIS)
        y = rotate_on_axis(y, x_rot, X_AXIS)
        z = rotate_on_axis(z, x_rot, X_AXIS)
    end
    if abs(y_rot) > 0
        a = rotate_on_axis(a, y_rot, Y_AXIS)
        b = rotate_on_axis(b, y_rot, Y_AXIS)
        c = rotate_on_axis(c, y_rot, Y_AXIS)
        d = rotate_on_axis(d, y_rot, Y_AXIS)
        w_ = rotate_on_axis(w_, y_rot, Y_AXIS)
        x = rotate_on_axis(x, y_rot, Y_AXIS)
        y = rotate_on_axis(y, y_rot, Y_AXIS)
        z = rotate_on_axis(z, y_rot, Y_AXIS)
    end
    if abs(z_rot) > 0
        a = rotate_on_axis(a, z_rot, Z_AXIS)
        b = rotate_on_axis(b, z_rot, Z_AXIS)
        c = rotate_on_axis(c, z_rot, Z_AXIS)
        d = rotate_on_axis(d, z_rot, Z_AXIS)
        w_ = rotate_on_axis(w_, z_rot, Z_AXIS)
        x = rotate_on_axis(x, z_rot, Z_AXIS)
        y = rotate_on_axis(y, z_rot, Z_AXIS)
        z = rotate_on_axis(z, z_rot, Z_AXIS)
    end

    a = a + centre
    b = b + centre
    c = c + centre
    d = d + centre
    w_ = w_ + centre
    x = x + centre
    y = y + centre
    z = z + centre

    reflection_values = zeros(6)
    for i in 1:length(sides)
        if sides[i] > 0 && sides[i] <= 6
            reflection_values[ sides[i] ] = reflection
        end
    end

    left = Plane( c, y, a, w_, reflection_values[LEFT], transparency, refraction )
    right = Plane( b, x, d, z, reflection_values[RIGHT], transparency, refraction )
    front = Plane( a, w_, b, x, reflection_values[FRONT], transparency, refraction )
    back = Plane( c, y, d, z, reflection_values[BACK], transparency, refraction )
    top = Plane( c, a, d, b, reflection_values[TOP], transparency, refraction )
    bottom = Plane( w_, y, x, z, reflection_values[BOTTOM], transparency, refraction )

    return Cuboid( centre, left, right, front, back, top, bottom,
        colour, diffuse, specular, shine )

end

function make_sphere( centre::Vector_3D, radius::Real, filename::String ; colour::RGBA=RED, diffuse::Real=0.5, specular::Real=0,
    shine::Real=250, reflection::Real=0, transparency::Real=0, refraction::Real=0 )

    return make_sphere( centre, radius, colour=colour, diffuse=diffuse, specular=specular, shine=shine, reflection=reflection, transparency=transparency, refraction=refraction, texture=make_texture(filename) )

end

function make_sphere( centre::Vector_3D, radius::Real, img::Union{ Array{RGBA{Float64}}, Array{RGBA{Float64}, 2} } ; colour::RGBA=RED, diffuse::Real=0.5, specular::Real=0,
    shine::Real=250, reflection::Real=0, transparency::Real=0, refraction::Real=0 )

    return make_sphere( centre, radius, colour=colour, diffuse=diffuse, specular=specular, shine=shine, reflection=reflection, transparency=transparency, refraction=refraction, texture=make_texture(img) )

end

function make_sphere( centre::Vector_3D, radius::Real ; colour::RGBA=RED, texture::Union{Texture, Nothing}=nothing, diffuse::Real=0.5, specular::Real=0,
        shine::Real=250, reflection::Real=0, transparency::Real=0, refraction::Real=0, )

    if radius < 0 throw( DomainError(radius, "argument \"radius\" must be nonnegative") ) end
    if shine < 0 throw( DomainError(shine, "argument \"shine\" must be nonnegative") ) end
    if refraction < 0 throw( DomainError(refraction, "argument \"refraction\" must be nonnegative") ) end
    if specular < 0 || specular > 1 throw( DomainError(specular, "argument \"specular\" must be between 0 and 1 inclusive") ) end
    if diffuse < 0 || diffuse > 1 throw( DomainError(diffuse, "argument \"diffuse\" must be between 0 and 1 inclusive") ) end
    if reflection < 0 || reflection > 1 throw( DomainError(reflection, "argument \"reflection\" must be between 0 and 1 inclusive") ) end
    if transparency < 0 || transparency > 1 throw( DomainError(transparency, "argument \"transparency\" must be between 0 and 1 inclusive") ) end

    return Sphere( centre, radius, colour, diffuse, specular, shine, reflection, transparency, refraction, texture )

end

function make_vector(x::Real=0, y::Real=0, z::Real=0)
    return Vector_3D(x, y, z)
end

function make_light(position::Vector_3D, brightness::Real, ambient::Real)   
    if brightness < ambient throw( DomainError(ambient, "argument \"ambient\" cannot be greater than brightness") ) end
    return Light(position, brightness, ambient) 
end

function make_light(x::Real, y::Real, z::Real, brightness::Real, ambient::Real)
    if brightness < ambient throw( DomainError(ambient, "argument \"ambient\" cannot be greater than brightness") ) end
    return Light( Vector_3D(x, y, z), brightness, ambient ) 
    end

function make_camera(origin::Vector_3D, focus::Vector_3D, up_vector::Vector_3D)
    if ( origin === focus ) || ( abs( origin.x - focus.x ) < eps(Float64) && abs( origin.y - focus.y ) < eps(Float64) && abs( origin.z - focus.z ) < eps(Float64) )
    throw( ArgumentError("a camera's focus cannot be the same as its origin") )
    end

    return Camera(origin, focus, up_vector)
end

function make_texture(filename::String)
    return Texture( convert.( RGBA{Float64}, load(filename) ) )
end

function make_texture(img::Union{Array{RGBA{Float64}}, Array{RGBA{Float64}, 2}})
    return Texture( convert.( RGBA{Float64}, img ) )
end