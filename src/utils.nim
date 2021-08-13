import nico/backends/common
import std/[math, fenv, strutils]

type 
  Position* = tuple[x, y: int]
  Direction* = tuple[x, y: float]
  Figure* = object
    color*: int
    pos*: Position
    radius*: int
    velocity*: float
  HunterMode = enum
    hunt, flee

func radToDirection(rad: float): Direction
func `+`*(p: Position, d: Direction): Position
func `+`*(d: Direction, p: Position): Position
func `+`*(d1, d2: Direction, normalize=false): Direction
func `-`*(a, b: Position): Position
func `-`*(a, b: Direction): Direction
func `*`*(s: float, d: Direction): Direction
func `*`*(d: Direction, s: float): Direction
func `*`*(d1, d2: Direction): float
func dotp*(d1, d2: Direction): float
func toDirection*(p: Position): Direction
func norm*(d: Direction): float
func normalize*(d: Direction, scale: float = 1.0): Direction
proc normalize_inplace*(d: var Direction, scale: float = 1.0)
proc round*(d: Direction): Direction
proc round_inplace*(d: var Direction)
func distance*(f1, f2: Figure): float
proc MyColors*(s: string): int


func radToDirection(rad: float): Direction =
  ## rad in [0, 2*PI)
  ## rad = 0 is middle-right and circle is walked counter-clockwise
  result.x = cos(rad)
  result.y = sin(rad)
  if abs(result.x) <= float32.epsilon():
    result.x = 0.0
  if abs(result.y) <= float32.epsilon():
    result.y = 0.0

func `+`*(p: Position, d: Direction): Position =
  result.x = p.x + d.x.int
  result.y = p.y + d.y.int

func `+`*(d: Direction, p: Position): Position =
  return `+`(p, d)

func `+`*(d1, d2: Direction, normalize=false): Direction =
  if normalize:
    let
      d1 = d1.normalize()
      d2 = d2.normalize()
  result.x = d1.x + d2.x
  result.y = d1.y + d2.y

func `*`*(s: float, d: Direction): Direction =
  result.x = s * d.x
  result.y = s * d.y

func `*`*(d: Direction, s: float): Direction =
  return `*`(s, d)

func `*`*(d1, d2: Direction): float =
  return dotp(d1, d2)

func dotp*(d1, d2: Direction): float =
  return d1.x*d2.x + d1.y*d2.y

func `-`*(a, b: Position): Position =
  result.x = a.x - b.x
  result.y = a.y - b.y

func `-`*(a, b: Direction): Direction =
  result.x = a.x - b.x
  result.y = a.y - b.y

func norm*(d: Direction): float =
  return sqrt(d.x*d.x + d.y*d.y)

func toDirection*(p: Position): Direction =
  result.x = p.x.float
  result.y = p.y.float

func distance*(f1, f2: Figure): float =
  return (f1.pos - f2.pos).toDirection.norm

func normalize*(d: Direction, scale: float = 1.0): Direction =
  result = (0.0, 0.0)
  let d_norm = d.norm()
  if d_norm > float32.epsilon():
    result.x = d.x * scale / d_norm
    result.y = d.y * scale / d_norm

proc normalize_inplace*(d: var Direction, scale: float = 1.0) =
  let d_norm = d.norm()
  if d_norm > float32.epsilon():
    d.x = d.x * scale / d_norm
    d.y = d.y * scale / d_norm

proc round*(d: Direction): Direction =
  result.x = d.x.round()
  result.y = d.y.round()

proc round_inplace*(d: var Direction) =
  d.x = d.x.round()
  d.y = d.y.round()

proc MyColors*(s: string): int =
  case s.toLowerAscii:
    of "white"        :  return mapRGB(0xff, 0xff, 0xff)
    of "black"        :  return mapRGB(0x00, 0x00, 0x00)
    of "red"          :  return mapRGB(0xff, 0x00, 0x00)
    of "green"        :  return mapRGB(0x00, 0xff, 0x00)
    of "blue"         :  return mapRGB(0x00, 0x00, 0xff)
    of "magenta"      :  return mapRGB(0xff, 0x00, 0xff)
    of "cyan"         :  return mapRGB(0x00, 0xff, 0xff)
    of "yellow"       :  return mapRGB(0xff, 0xff, 0x00)

    of "gray"         :  return mapRGB(0x7f, 0x7f, 0x7f)
    of "darker-gray"  :  return mapRGB(0x5f, 0x5f, 0x5f)
    of "darkest-gray" :  return mapRGB(0x30, 0x30, 0x30)
    else              :  return mapRGB(0xff, 0xff, 0xff)


