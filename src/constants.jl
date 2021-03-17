include("types.jl")

################################
## Module globals and constants
################################

const EPSILON = eps(Float32)
const SAMPLES = 5
const DEFAULT_IMAGE_WIDTH = 1920
const DEFAULT_IMAGE_HEIGHT = 1080
const DEFAULT_FOV = 90

const DEFAULT_REFLECT_LIMIT = 10
const DEFAULT_REFRACT_LIMIT = 10
REFLECT_LIMIT = 0
REFRACT_LIMIT = 0

const ORIGIN = Vector_3D(0, 0, 0)
const VERTICAL = Vector_3D(0, 1, 0)
const HORIZONTAL = Vector_3D(0, 0, -1)
const HORIZONTAL_UP = Vector_3D(0, 0, 1)

const X_AXIS = 1
const Y_AXIS = 2
const Z_AXIS = 3

const LEFT = 1
const RIGHT= 2
const FRONT = 3
const BACK = 4
const TOP = 5
const BOTTOM = 6

const WHITE = RGBA(0.957, 0.957, 0.957, 1)
const RED = RGBA(0.832, 0.004, 0, 1)
const YELLOW = RGBA(0.953, 0.719, 0.031, 1)
const GREEN = RGBA(0.008, 0.316, 0.094, 1)
const BROWN = RGBA(0.563, 0.227, 0, 1)
const BLUE= RGBA(0, 0.414, 0.813, 1)
const PINK = RGBA(0.996, 0.57, 0.551, 1)
const BLACK = RGBA(0, 0, 0, 1)
const TRANSPARENT = RGBA(0, 0, 0, 1)

const CUBE_MAP = 1
const TILE = 2