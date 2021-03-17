include("types.jl")

##############################
## Vector Operator Overloading
##############################

## Vector_3D x Vector_3D operations
function Base.:+(a::Vector_3D, b::Vector_3D)
    return Vector_3D(a.x+b.x, a.y+b.y, a.z+b.z)
end

function Base.:-(a::Vector_3D, b::Vector_3D)
    return Vector_3D(a.x-b.x, a.y-b.y, a.z-b.z)
end

function Base.:*(a::Vector_3D, b::Vector_3D)
    return Vector_3D(a.x*b.x, a.y*b.y, a.z*b.z)
end

function Base.:/(a::Vector_3D, b::Vector_3D)
    return Vector_3D(a.x/b.x, a.y/b.y, a.z/b.z)
end

## Vector_3D x Number operations
function Base.:+(v::Vector_3D, r::Real)
    return Vector_3D(v.x+r, v.y+r, v.z+r)
end

function Base.:-(v::Vector_3D, r::Real)
    return Vector_3D(v.x-r, v.y-r, v.z-r)
end

function Base.:*(v::Vector_3D, r::Real)
    return Vector_3D(v.x*r, v.y*r, v.z*r)
end

function Base.:/(v::Vector_3D, r::Real)
    return Vector_3D(v.x/r, v.y/r, v.z/r)
end

## Number x Vector_3D operations
function Base.:+(r::Real, v::Vector_3D)
    return v+r
end

function Base.:*(r::Real, v::Vector_3D)
    return v*r
end

## Unary operators
function Base.:-(v::Vector_3D)
    return Vector_3D(-v.x, -v.y, -v.z)
end

## Comparison operators
function Base.:(==)(a::Vector_3D, b::Vector_3D)
    return (
        ( EPSILON > abs(a.x - b.x) ) &&
        ( EPSILON > abs(a.y - b.y) ) &&
        ( EPSILON > abs(a.z - b.z) )
    )
end

###################
## Vector Functions
###################

## Dot Product
function dot(a::Vector_3D, b::Vector_3D)
    return (
        a.x * b.x +
        a.y * b.y +
        a.z * b.z
    )
end

## Cross Product
function cross(a::Vector_3D, b::Vector_3D)
    return Vector_3D(
        ( a.y * b.z ) - ( a.z * b.y ),
        ( a.z * b.x ) - ( a.x * b.z ),
        ( a.x * b.y ) - ( a.y * b.x )
    )
end

## Magnitude of Vector
function magnitude(v::Vector_3D)
    return sqrt(
        v.x^2 +
        v.y^2 +
        v.z^2
    )
end

## Unit Vector
function unit_vector(v::Vector_3D)
    return v / magnitude(v)
end

## Reflect vector about another
function reflect(v::Vector_3D, axis::Vector_3D)   
    n = unit_vector(axis)
    return v - ( ( 2 * dot(v, n) ) * n )
end

## Normal to a sphere
function normal(sphere::Sphere, intersect_point::Vector_3D, ray::Ray)
    n = unit_vector( intersect_point - sphere.centre )
    return dot( n, unit_vector(ray.direction) ) < 0 ? n : -n 
end

## Normal to a plane
function normal(plane::Plane, ray::Ray)
    vec_1 = plane.upper_left - plane.lower_left
    vec_2 = plane.lower_right - plane.lower_left

    n = unit_vector( cross(vec_1, vec_2) )
    return dot( n, unit_vector(ray.direction) ) < 0 ? n : -n
end

##############################
## Colour Operator Overloading
##############################
function Base.:*(num::Real, colour::RGBA{T})  where T<:AbstractFloat
    return RGBA(num * colour.r, num * colour.g, num * colour.b, colour.alpha)
end

function Base.:*(colour::RGBA{T}, num::Real) where T<:AbstractFloat
    return num*colour
end

function Base.:*(colour::RGBA{T}, colour2::RGBA{T}) where T<:AbstractFloat
    return RGBA(colour.r * colour2.r, colour.g * colour2.g, colour.b * colour2.b, colour.alpha)
end

function Base.:+(colour::RGBA{T}, colour2::RGBA{T}) where T<:AbstractFloat
    return RGBA(colour.r + colour2.r, colour.g + colour2.g, colour.b + colour2.b, colour.alpha)
end

function Base.:/(colour::RGBA{T}, num::Real)  where T<:AbstractFloat
    return RGBA(colour.r / num, colour.g / num, colour.b / num, colour.alpha)
end

##################
## Scene Functions
##################

function set_shapes(scene::Scene, shape_array::Array{<:Shape,1})
    scene.shapes = shape_array
end

function clear_shapes(scene::Scene)
    empty!(scene.shapes)
end

function Base.append!(scene::Scene, shape_array::Array{<:Shape,1})
    append!(scene.shapes, shape_array)
end

function Base.push!(scene::Scene, shape::Shape)
    push!(scene.shapes, shape)
end

function set_light(scene::Scene, light::Light)
    scene.light = light
end

function set_camera(scene::Scene, camera::Camera)
    scene.camera = camera
end

function set_boundary(scene::Scene, boundary::BoundingBox)
    scene.boundary = boundary
end

function clear_light(scene::Scene, light::Light)
    scene.light = nothing
end

function clear_camera(scene::Scene, camera::Camera)
    scene.camera = nothing
end

function clear_boundary(scene::Scene, boundary::BoundingBox)
    scene.boundary = nothing
end

function scene_details(scene::Scene)   
    if length(scene.shapes) == 0
        return "No shapes added to scene."
    end

    s = ""
    for i in 1:length(scene.shapes)
        s *= @sprintf("%d. %s\n", i,  shape_details( scene.shapes[i] ) )
    end
    return s
end

function shape_details(sphere::Sphere)
    s = "SPHERE:\n"
    s *= @sprintf( "Centre @ <%f,%f,%f>, Radius: %f\n", sphere.centre.x, sphere.centre.y, sphere.centre.z, sphere.radius )
    s *= @sprintf( "Colour: RGB(%f,%f,%f), Diffuse Value(MAX=1.0): %f, Specular Value(MAX=1.0): %f \n", sphere.colour.r, sphere.colour.g, sphere.colour.g, sphere.diffuse, sphere.specular )
    s *= @sprintf( "Reflectivity Value(MAX=1.0): %f", sphere.reflection )
    return s
end

function shape_details(cuboid::Cuboid)
    s = "CUBOID:\n"
    s *= "TODO: Complete this function"
    return s
end

####################
## Texture Functions
####################

function height(texture::Texture)
    return size(texture.map)[1]
end

function width(texture::Texture)
    return size(texture.map)[2]
end


#####################
## Rotation Functions
#####################

function rotate_on_axis(point::Vector_3D, angle::Real, axis_id::Int)
    
    if axis_id < 1 || axis_id > 3 throw( DomainError(axis_id, "argument \"axis_id\" must be between 1 and 3") ) end

    theta = deg2rad( angle % 360 )
    cos_theta = cos(theta)
    sin_theta = sin(theta)

    if axis_id == X_AXIS
        y_ = cos_theta * point.y - sin_theta * point.z
        z_ = sin_theta * point.y + cos_theta * point.z
        return Vector_3D(point.x, y_, z_)
    end
    if axis_id == Y_AXIS
        x_ = cos_theta * point.x + sin_theta * point.z
        z_ = -sin_theta * point.x + cos_theta * point.z
        return Vector_3D(x_, point.y, z_)
    end
    if axis_id == Z_AXIS
        x_ = cos_theta * point.x - sin_theta * point.y
        y_ = sin_theta * point.x + cos_theta * point.y
        return Vector_3D(x_, y_, point.z)
    end

end