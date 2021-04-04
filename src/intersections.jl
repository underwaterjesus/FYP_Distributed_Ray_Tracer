include("types.jl")
include("operations.jl")
include("constants.jl")

#########################
## Intersection Functions
#########################

function intersect_values(sphere::Sphere, ray::Ray)
    
    sphere_to_ray_origin = ray.origin - sphere.centre

    a = dot( ray.direction, ray.direction )
    b = 2.0 * dot( sphere_to_ray_origin, ray.direction )
    c = dot( sphere_to_ray_origin, sphere_to_ray_origin ) - ( sphere.radius * sphere.radius )
    discriminant = ( b * b ) - 4( a * c )

    if discriminant < 0
        return nothing
    end

    t1 = ( -b - sqrt(discriminant) ) / ( 2 * a )
    t2 = ( -b + sqrt(discriminant) ) / ( 2 * a )

    return IntersectionValues(t1, t2, nothing, nothing, sphere.transparency, sphere.transparency)

end

function intersect_values(plane::Plane, ray::Ray)
    
    n = normal(plane, ray)
    dot_prod = dot(ray.direction, n)

    if abs(dot_prod) > 0

        w = ray.origin - plane.upper_left
        t = -( ( dot(n, w) ) / dot_prod )

        if abs(t) < eps(Float64)
            return nothing
        end

        bounds_test_vector = ray.origin + ( t * ray.direction )
        
        a = dot(plane.lower_left - plane.upper_left, bounds_test_vector - plane.upper_left)
        b = dot(plane.lower_left - plane.upper_left, plane.lower_left - plane.upper_left)

        x = dot(plane.lower_right - plane.lower_left, bounds_test_vector - plane.lower_left)
        y = dot(plane.lower_right - plane.lower_left, plane.lower_right - plane.lower_left)
        
        if ( a >= -EPSILON && (b - a) > 0 ) && ( x >= -EPSILON && (y - x) > 0 )
            return t
        end

        return nothing

    end

    return nothing
end

function intersect_values(cuboid::Cuboid, ray::Ray)
    
    t1 = intersect_values(cuboid.left, ray)
    t2 = intersect_values(cuboid.right, ray)
    s1 = LEFT
    s2 = RIGHT
    trans1 = cuboid.left.transparency
    trans2 = cuboid.right.transparency

    if t1 != nothing && t2 != nothing
        return IntersectionValues(t1, t2, s1, s2, trans1, trans2)
    end

    front = intersect_values(cuboid.front, ray)
    if front != nothing
        if t1 == nothing
            t1 = front
            s1 = FRONT
            trans1 = cuboid.front.transparency
        elseif t2 == nothing
            t2 = front
            s2 = FRONT
            trans2 = cuboid.front.transparency
        end
    end

    if t1 != nothing && t2 != nothing
        if EPSILON > abs(t1 - t2)
            t2 = nothing
        else
            return IntersectionValues(t1, t2, s1, s2, trans1, trans2)
        end
    end

    back = intersect_values(cuboid.back, ray)
    if back != nothing
        if t1 == nothing
            t1 = back
            s1 = BACK
            trans1 = cuboid.back.transparency
        elseif t2 == nothing
            t2 = back
            s2 = BACK
            trans2 = cuboid.back.transparency
        end
    end

    if t1 != nothing && t2 != nothing
        if EPSILON > abs(t1 - t2)
            t2 = nothing
        else
            return IntersectionValues(t1, t2, s1, s2, trans1, trans2)
        end
    end

    top = intersect_values(cuboid.top, ray)
    if top != nothing
        if t1 == nothing
            t1 = top
            s1 = TOP
            trans1 = cuboid.top.transparency
        elseif t2 == nothing
            t2 = top
            s2 = TOP
            trans2 = cuboid.top.transparency
        end
    end

    if t1 != nothing && t2 != nothing
        if EPSILON > abs(t1 - t2)
            t2 = nothing
        else
            return IntersectionValues(t1, t2, s1, s2, trans1, trans2)
        end
    end

    bottom = intersect_values(cuboid.bottom, ray)
    if bottom != nothing
        if t1 == nothing
            t1 = bottom
            s1 = BOTTOM
            trans1 = cuboid.bottom.transparency
        elseif t2 == nothing
            t2 = bottom
            s2 = BOTTOM
            trans2 = cuboid.bottom.transparency
        end
    end

    if t1 == nothing || t2 == nothing
        return nothing
    end

    return IntersectionValues(t1, t2, s1, s2, trans1, trans2)

end

function intersect_values(box::BoundingBox, ray::Ray)

    t1 = intersect_values(box.left, ray)
    t2 = intersect_values(box.right, ray)
    s1 = LEFT
    s2 = RIGHT

    if t1 != nothing && t2 != nothing
        return IntersectionValues(t1, t2, s1, s2)
    end

    front = intersect_values(box.front, ray)
    if front != nothing
        if t1 == nothing
            t1 = front
            s1 = FRONT
        elseif t2 == nothing
            t2 = front
            s2 = FRONT
        end
    end

    if t1 != nothing && t2 != nothing
        if EPSILON > abs(t1 - t2)
            t2 = nothing
        else
            return IntersectionValues(t1, t2, s1, s2, nothing, nothing)
        end
    end

    back = intersect_values(box.back, ray)
    if back != nothing
        if t1 == nothing
            t1 = back
            s1 = BACK
        elseif t2 == nothing
            t2 = back
            s2 = BACK
        end
    end

    if t1 != nothing && t2 != nothing
        if EPSILON > abs(t1 - t2)
            t2 = nothing
        else
            return IntersectionValues(t1, t2, s1, s2, nothing, nothing)
        end
    end

    top = intersect_values(box.top, ray)
    if top != nothing
        if t1 == nothing
            t1 = top
            s1 = TOP
        elseif t2 == nothing
            t2 = top
            s2 = TOP
        end
    end

    if t1 != nothing && t2 != nothing
        if EPSILON > abs(t1 - t2)
            t2 = nothing
        else
            return IntersectionValues(t1, t2, s1, s2, nothing, nothing)
        end
    end

    bottom = intersect_values(box.bottom, ray)
    if bottom != nothing
        if t1 == nothing
            t1 = bottom
            s1 = BOTTOM
        elseif t2 == nothing
            t2 = bottom
            s2 = BOTTOM
        end
    end

    if t1 == nothing || t2 == nothing
        return nothing
    end

    return IntersectionValues(t1, t2, s1, s2, nothing, nothing)

end

function closest_intersection(scene::Scene, ray::Ray, ignore::Int=0)
    
    closest_intersection_value = Inf32
    closest_index = nothing
    side = nothing

    for i in 1:length(scene.shapes)

        if i == ignore
            continue
        end

        intersection = intersect_values(scene.shapes[i], ray)

        if intersection == nothing
            continue
        end

        if intersection.t1 >=0 && intersection.t1 < closest_intersection_value
            closest_intersection_value = intersection.t1
            closest_index = i
            side = intersection.side1
        end

        if intersection.t2 >=0 && intersection.t2 < closest_intersection_value
            closest_intersection_value = intersection.t2
            closest_index = i
            side = intersection.side2
        end

    end

    if closest_index == nothing
        if scene.boundary == nothing
            return nothing, nothing, nothing
        end

        boundary_intersection = intersect_values(scene.boundary, ray)
        t = max(0, intersection.t1)
        t = max(t, intersection.t2)
        side = EPSILON > t - boundary_intersection.t1 ? boundary_intersection.side1 : boundary_intersection.side2

        return t, 0, side
    end

    return closest_intersection_value, closest_index, side

end

function coords_to_lat_lng(sphere::Sphere, intersection_point::Vector_3D)
    
    point_translated_scaled = (intersection_point - sphere.centre) / sphere.radius

    if abs(sphere.x_rot) > EPSILON
        point_translated_scaled = rotate_on_axis( point_translated_scaled, -sphere.x_rot, X_AXIS )
    end
    if abs(sphere.y_rot) > EPSILON
        point_translated_scaled = rotate_on_axis( point_translated_scaled, -sphere.y_rot, Y_AXIS )
    end
    if abs(sphere.z_rot) > EPSILON
        point_translated_scaled = rotate_on_axis( point_translated_scaled, -sphere.z_rot, Z_AXIS )
    end

    ϕ = atan( point_translated_scaled.z, point_translated_scaled.x )
    θ = asin( point_translated_scaled.y )
    lat = ( θ + π/2 ) / π
    lng = 1 - (ϕ + π) / (2π)

    return (lat, lng)

end

function coords_to_x_y(cuboid::Cuboid, face::Int, intersection_point::Vector_3D)
    
    if face == LEFT
        plane = cuboid.left
    elseif face == RIGHT
        plane = cuboid.right
    elseif face == FRONT
        plane = cuboid.front
    elseif face == BACK
        plane = cuboid.back
    elseif face == TOP
        plane = cuboid.top
    elseif face == BOTTOM
        plane = cuboid.bottom
    else
        return nothing, nothing
    end

    x_axis = plane.lower_right - plane.lower_left
    y_axis = plane.upper_left - plane.lower_left
    axes_intersection = intersection_point - plane.lower_left

    x_projection = ( dot(axes_intersection , x_axis) / dot(x_axis , x_axis) ) * x_axis
    y_projection = ( dot(axes_intersection , y_axis) / dot(y_axis , y_axis) ) * y_axis

    x_idx = magnitude(x_projection) / magnitude(x_axis)
    y_idx = magnitude(y_projection) / magnitude(y_axis)

    return (x_idx, y_idx)

end