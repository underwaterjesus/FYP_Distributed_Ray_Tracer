include("intersections.jl")

######################
## Rendering Functions
######################

function ray_cast(ray::Ray, scene::Scene, reflect_limit::Int=REFLECT_LIMIT, refract_limit::Int=REFRACT_LIMIT)   
    closest_intersection_value, closest_index, side = closest_intersection(scene, ray)

    if closest_index != nothing
        return colour_pixel( scene, ray, closest_intersection_value, closest_index, side, 0 ) 
    end

    return background_colour(ray.direction)
end

function render_scene(scene::Scene, image_width::Int=DEFAULT_IMAGE_WIDTH, image_height::Int=DEFAULT_IMAGE_HEIGHT, vertical_fov::Real=DEFAULT_FOV, samples::Int=SAMPLES ; reflect_limit::Int=DEFAULT_REFLECT_LIMIT, refract_limit::Int=DEFAULT_REFRACT_LIMIT)
    
    if scene.camera == nothing throw( ArgumentError("render_scene: Scene cannot have Nothing as Camera value when passed") ) end
    if scene.light == nothing throw( ArgumentError("render_scene: Scene cannot have Nothing as Light value when passed") ) end
    if image_width <= 0 throw( DomainError(image_width, "argument \"image_width\" must be greater than zero") ) end
    if image_height <= 0 throw( DomainError(image_height, "argument \"image_height\" must be greater than zero") ) end
    if samples <= 0 throw( DomainError(samples, "argument \"samples\" must be greater than zero") ) end
    if vertical_fov <= 0 || vertical_fov >= 180 throw( DomainError(vertical_fov, "argument \"vertical_fov\" must be between 0 and 180 exclusive") ) end
    if reflect_limit < 0 throw( DomainError(reflect_limit, "argument \"reflect_limit\" must be nonnegative") ) end
    if refract_limit < 0 throw( DomainError(refract_limit, "argument \"refract_limit\" must be nonnegative") ) end

    aspect_ratio = image_width / image_height
    fov_rads = deg2rad(vertical_fov)
    h = tan( fov_rads / 2 )
    viewport_height = 2.0 * h
    viewport_width = aspect_ratio * viewport_height

    w = unit_vector( scene.camera.origin - scene.camera.focus )
    u = unit_vector( cross( scene.camera.up_vector, w ) )
    v = cross(w, u)

    horizontal = viewport_width * u
    vertical = viewport_height * v
    lower_left_corner = scene.camera.origin - horizontal / 2 - vertical / 2 - w

    global REFLECT_LIMIT = reflect_limit
    global REFRACT_LIMIT = refract_limit

    img = Array{RGBA, 2}(undef, image_height, image_width)

    for j in image_height:-1:1
        for i in 1:image_width

            if samples == 1

                hrzt_factor = ( i - 1 ) / ( image_width - 1 )
                vert_factor = ( j - 1 ) / ( image_height - 1 )
                ray = Ray( scene.camera.origin, ( lower_left_corner + (hrzt_factor * horizontal) + (vert_factor * vertical) - scene.camera.origin ) )
                pixel_colour = ray_cast(ray, scene)
                img[ ( image_height - j ) + 1, i ] = RGBA( pixel_colour.r, pixel_colour.g, pixel_colour.b, pixel_colour.alpha )

                continue

            end

            pixel_colour = RGBA(0, 0, 0, 1)

            for s in 1:samples

                hrzt_factor = ( (i - 1) + rand(Float32) ) / ( image_width - 1 )
                vert_factor = ( (j - 1) + rand(Float32) ) / ( image_height - 1 )
                ray = Ray( scene.camera.origin, ( lower_left_corner + (hrzt_factor * horizontal) + (vert_factor * vertical) - scene.camera.origin ) )
                pixel_colour = pixel_colour + ray_cast(ray, scene)

            end

            img[ ( image_height - j ) + 1, i ] = RGBA( pixel_colour.r / samples, pixel_colour.g / samples, pixel_colour.b / samples, pixel_colour.alpha )
        end
    end

    return img
    
end

##########################################
## Colouring, Shading & Lighting Functions
##########################################

function shadow_level(scene::Scene, point::Vector_3D)
    
    if length(scene.shapes) == 0
        return 0
    end

    light_ray = scene.light.position - point
    mag = magnitude(light_ray)
    dir = unit_vector(light_ray)
    shadow_ray = Ray(point, dir)
    shadow = 0

    for i in 1:length(scene.shapes)
        intersection = intersect_values( scene.shapes[i], shadow_ray )

        if intersection == nothing
            continue
        end
        if intersection.t1 >=0 && intersection.t1 < mag
            if intersection.transparency1 < eps(Float64)
                return 1
            end

            shadow += (1 - intersection.transparency1)
            if shadow >= 1 return 1 end
        end
        if intersection.t2 >=0 && intersection.t2 < mag
            if intersection.transparency2 < eps(Float64)
                return 1
            end

            shadow += (1 - intersection.transparency2)
            if shadow >= 1 return 1 end
        end
    end

    return shadow

end

function boundary_colour(intersection_point::Vector_3D)
    uv = unit_vector(intersect_point)
    t = 0.5 * (uv.y + 1.0)
    r = (1.0-t)*(1.0)
    g = (1.0-t)*(1.0)
    b = (1.0-t)*(1.0)
    r2 = t*(0.5)
    g2 = t*0.7
    b2 = t*1.0

    return RGBA( r+r2, g+g2, b+b2, 1.0 )
end

function schlick(index_a::Real, index_b::Real, angle_cos::Real)

    if index_a > index_b

        refractive_ratio = index_a / index_b
        sin2 = (refractive_ratio * refractive_ratio) * ( 1 - (angle_cos ^ 2) )
        if sin2 > 1.0
            return 1.0
        end

        angle_cos = √( 1.0 - sin2 )

    end

    r = ( (index_a - index_b) / (index_a + index_b) ) ^ 2
    return r + (1 -r) * ( ( 1 - abs(angle_cos) ) ^ 5 )

end

function reflection_colour(scene::Scene, ray::Ray, normal::Vector_3D, intersection_point::Vector_3D, idx::Int, refract_count::Int)

    reflect_vector = reflect( unit_vector(ray.direction), normal )
    reflect_ray = Ray( intersection_point, reflect_vector )

    closest_intersection_value, closest_index, side = closest_intersection(scene, reflect_ray, idx)

    if closest_index != nothing
        return colour_pixel(scene, reflect_ray, closest_intersection_value, closest_index, side, refract_count)
    end

    return background_colour(reflect_vector)

end

function refract_ray(ray::Ray, normal::Vector_3D, intersection_point::Vector_3D, refraction::Real)

    refractive_ratio = 1 / refraction
    cos_1 = dot( unit_vector(-ray.direction), normal )
    cos_1 = min( cos_1, 1.0 )
    cos_1 = max( cos_1, -1.0 )
    sin_ = (refractive_ratio * refractive_ratio) * ( 1 - (cos_1 ^ 2) )
    if sin_ > 1.0
        return ( nothing, cos_1 )
    else
        cos_2 = √( 1.0 - sin_ )
        direction = normal * ( refractive_ratio * cos_1 - cos_2 ) - unit_vector(-ray.direction) * refractive_ratio
        return ( Ray( intersection_point - ( normal * (10 * EPSILON) ), direction ), cos_1 )
    end
    
end

function transparency_colour(scene::Scene, ray::Ray, normal::Vector_3D, intersection_point::Vector_3D, idx::Int, side::Union{Plane, Nothing}, refract_count::Int)

    refraction = side == nothing ? scene.shapes[idx].refraction : side.refraction
    reflection_ray = nothing
    schlick_value = 0.0
    if refraction > 0 && refract_count < REFRACT_LIMIT
        transparency_ray, cos_ = refract_ray(ray, normal, intersection_point, refraction)
        schlick_value = schlick(1, refraction, cos_)
        refract_count = refract_count + 1
    else
        transparency_ray = Ray( intersection_point - ( normal * (10 * EPSILON) ), ray.direction )
    end

    if transparency_ray == nothing
        return ( BLACK, schlick_value )
    end
    closest_intersection_value, closest_index, side = closest_intersection(scene, transparency_ray)

    if closest_index != nothing
        return_colour = ( colour_pixel( scene, transparency_ray, closest_intersection_value, closest_index, side, refract_count ), schlick_value )
    else
        return_colour = ( background_colour( transparency_ray.direction ), schlick_value )
    end
    
    return return_colour

end

function colour_pixel(scene::Scene, ray::Ray, closest_intersection_value::Real, idx::Int, side_id::Union{Int, Nothing}, refract_count::Int)
    
    intersect_point = ray.origin + closest_intersection_value * ray.direction
    light_ray = unit_vector( scene.light.position - intersect_point )
    side = nothing

    if side_id == nothing
        n = normal(scene.shapes[idx], intersect_point, ray)
    else
        if side_id == LEFT
            n = idx > 0 ? normal(scene.shapes[idx].left, ray) : normal(scene.boundary.left, ray)
            side = idx > 0 ? scene.shapes[idx].left : scene.boundary.left
        elseif side_id == RIGHT
            n = idx > 0 ? normal(scene.shapes[idx].right, ray) : normal(scene.boundary.right, ray)
            side = idx > 0 ? scene.shapes[idx].right : scene.boundary.right
        elseif side_id == FRONT
            n = idx > 0 ? normal(scene.shapes[idx].front, ray) : normal(scene.boundary.front, ray)
            side = idx > 0 ? scene.shapes[idx].front : scene.boundary.front
        elseif side_id == BACK
            n = idx > 0 ? normal(scene.shapes[idx].back, ray) : normal(scene.boundary.back, ray)
            side = idx > 0 ? scene.shapes[idx].back : scene.boundary.back
        elseif side_id == TOP
            n = idx > 0 ? normal(scene.shapes[idx].top, ray) : normal(scene.boundary.top, ray)
            side = idx > 0 ? scene.shapes[idx].top : scene.boundary.top
        elseif side_id == BOTTOM
            n = idx > 0 ? normal(scene.shapes[idx].bottom, ray) : normal(scene.boundary.bottom, ray)
            side = idx > 0 ? scene.shapes[idx].bottom : scene.boundary.bottom
        end
    end

    light_side_n = dot(n, -light_ray) < 0 ? n : -n
    epsilon_point = idx > 0 ? intersect_point + ( light_side_n * (10 * EPSILON) ) : intersect_point
    
    if side_id == nothing && scene.shapes[idx].texture != nothing
        base_colour = idx > 0 ? scene.light.brightness * texture_colour(scene.shapes[idx], intersect_point) : scene.light.brightness * boundary_colour(intersect_point)
    else
        base_colour = idx > 0 ? scene.light.brightness * scene.shapes[idx].colour : scene.light.brightness * boundary_colour(intersect_point)
    end

    ambient_colour = base_colour * scene.light.ambient
    reflect_colour = BLACK
    reflection = side == nothing ? scene.shapes[idx].reflection : side.reflection
    transparency = side == nothing ? scene.shapes[idx].transparency : side.transparency
    refraction = side == nothing ? scene.shapes[idx].refraction : side.refraction
    transparent_colour = BLACK

    if transparency > 0 && idx > 0
        transparent_colour, schlick_value =  transparency_colour( scene, ray, n, intersect_point, idx, side, refract_count )
        transparent_colour = transparent_colour * ( transparency - (schlick_value > reflection ? schlick_value : 0) )
        reflection = max( reflection, schlick_value )
    end
    
    if reflection > 0 && idx > 0
        reflect_colour = reflection * reflection_colour( scene, ray, n, intersect_point, idx, refract_count )
    end

    if ( shadow = shadow_level(scene, epsilon_point) ) > 0
        return ( base_colour * max( (1 - shadow), scene.light.ambient ) ) + ( scene.light.ambient * reflect_colour ) + transparent_colour
    end

    distance = magnitude(light_ray)
    cos_light_ray_normal = dot(light_ray, n)

    if cos_light_ray_normal < 0
        diffuse_light = RGBA(0, 0, 0, 1)
        specular_light = RGBA(0, 0, 0, 1)
    else
        diffuse_light = ( base_colour * scene.shapes[idx].diffuse * cos_light_ray_normal ) / distance

        reflect_ray = reflect(-light_ray, n)
        cos_reflect_ray_cast_ray = dot( reflect_ray, -ray.direction )

        if cos_reflect_ray_cast_ray < 0
            specular_light = RGBA(0, 0, 0, 1)
        else
            specular_factor = cos_reflect_ray_cast_ray ^ scene.shapes[idx].shine
            specular_val = ( scene.light.brightness * scene.shapes[idx].specular * specular_factor ) / distance
            specular_light = RGBA(specular_val, specular_val, specular_val, 1)
        end
    end

    return ambient_colour + diffuse_light + specular_light + reflect_colour + transparent_colour

end

function background_colour(point::Vector_3D)
    uv = unit_vector(point)
    t = 0.5 * (uv.y + 1.0)
    r = 1.0-t
    g = 1.0-t
    b = 1.0-t
    r2 = t*(0.5)
    g2 = t*0.7
    b2 = t*1.0

    return RGBA( r+r2, g+g2, b+b2, 1 )
end

function texture_colour(sphere::Sphere, intersection_point::Vector_3D)
    
    if sphere.texture == nothing
        return TRANSPARENT
    end

    lat, lng = coords_to_lat_lng(sphere, intersection_point)
    width_idx = floor( Int, min( (width(sphere.texture) * lat), width(sphere.texture) ) )
    height_idx = floor( Int, min( (height(sphere.texture) * lng), height(sphere.texture) ) )
    width_idx = max(width_idx, 1)
    height_idx = max(height_idx, 1)

    return sphere.texture.map[ (height(sphere.texture) + 1) - height_idx , width_idx ]

end