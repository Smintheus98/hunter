import std/[math, fenv, tables, strutils]
import nico/backends/common

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


type 
  Position* = tuple[x, y: int]
  Direction* = tuple[x, y: float]
  Figure* = object
    color*: int
    pos*: Position
    radius*: int
    velocity*: float

func radToDirection(rad: float): Direction =
  ## rad in [0, 2*PI)
  ## rad = 0 is middle-right and circle is walked counter-clockwise
  result.x = cos(rad)
  result.y = sin(rad)
  if abs(result.x) <= float32.epsilon():
    result.x = 0.0
  if abs(result.y) <= float32.epsilon():
    result.y = 0.0

func `+`*(p: Position, q: Direction): Position =
  result.x = p.x + q.x.int
  result.y = p.y + q.y.int

func `*`*(s: float, d: Direction): Direction =
  result.x = s * d.x
  result.y = s * d.y

func `*`*(d: Direction, s: float): Direction =
  return `*`(s, d)

func `-`*(a, b: Position): Position =
  result.x = a.x - b.x
  result.y = a.y - b.y

func distance*(f1, f2: Figure): float =
  let d = f1.pos - f2.pos
  return sqrt(float(d.x*d.x + d.y*d.y))

func toDirection*(p: Position): Direction =
  result.x = p.x.float
  result.y = p.y.float

proc normalize*(d: var Direction, scale: float = 1.0) =
  let norm = sqrt(d.x*d.x + d.y*d.y)
  if norm > float32.epsilon():
    d.x = d.x * scale / norm
    d.y = d.y * scale / norm

proc round*(d: var Direction) =
  d.x = d.x.round()
  d.y = d.y.round()
