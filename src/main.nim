import nico
import nico/backends/common
import std/[fenv, os, strformat, tables]
import utils

#[
colors: 
        0 : black
        1 : teal-blue
        2 : deep magenta
        3 : lime
        4 : flesh
        5 : beige
        6 : gray-white
        7 : white
        8 : magenta
        9 : sun
        10: yellow
        11: bright-lime
]#

const
  orgName = "ykitten"
  appName = "hunter"

const
  player_radius = 28
  hunter_radius = 30
  player_velocity = 5
  hunter_velocity = 4
  gui_w = 800
  gui_h = 500
  win_w = 800
  win_h = 450
  win_hw = win_w div 2
  win_hh = win_h div 2
  #win_r = win_w / win_h   # ==1: square, >1: rectangle (lying), <1: rectangle (standing)

discard fenv.fesetround(FE_TONEAREST)



proc createPlayer(pos = (x: win_hw, y: win_hh)): Figure =
  Figure(color: MyColors("blue"), pos: pos, radius: player_radius, velocity: player_velocity)

proc createHunter(pos: Position): Figure =
  Figure(color: MyColors("red"), pos: pos, radius: hunter_radius, velocity: hunter_velocity)

proc createHunters(n: int): seq[Figure] =
  result = @[]
  if n >= 1:
    result.add createHunter((win_w, win_hh))
  if n >= 2:
    result.add createHunter((0, win_hh))
  if n >= 3:
    result.add createHunter((win_hw, 0))
  if n >= 4:
    result.add createHunter((win_hw, win_h))

proc move(f: var Figure, d: Direction) =
  var dn = d
  dn.normalize(f.velocity)
  dn.round()
  var
    pos: Position = f.pos + dn
    r: int = f.radius
  if pos.x - r < 0:
    pos.x = r
  elif pos.x + r >= win_w:
    pos.x = win_w-r-1
  if pos.y - r < 0:
    pos.y = r
  elif pos.y + r >= win_h:
    pos.y = win_h-r-1
  f.pos = pos

proc hunt(h: var Figure, p: Figure) =
  let dir = toDirection(p.pos - h.pos)
  h.move(dir)

proc flee(h: var Figure, p: Figure) =
  let dir = toDirection(h.pos - p.pos)
  if (h.pos + dir * h.velocity).x < 0:
    discard

proc draw(f: Figure) =
  setColor(f.color)
  circfill(f.pos.x, f.pos.y, f.radius)

proc keysToDirection(): Direction =
  result = (0.0, 0.0)
  if key(K_LEFT) or key(K_A):
    result.x -= 1
  if key(K_RIGHT) or key(K_D):
    result.x += 1
  if key(K_UP) or key(K_W):
    result.y -= 1
  if key(K_DOWN) or key(K_S):
    result.y += 1

var
  caught = false
  startscreen = true
  player: Figure
  hunters: seq[Figure] = @[]
  hunter_num: int = 1


proc gameInit() =
  loadFont(0, "font.png")
  player = createPlayer()
  hunters = createHunters(hunter_num)

proc gameUpdate(dt: float32) =
  if key(K_ESCAPE):
    nico.shutdown()
  if caught or startscreen:
    if key(K_1):
      hunter_num = 1
    if key(K_2):
      hunter_num = 2
    if key(K_3):
      hunter_num = 3
    if key(K_4):
      hunter_num = 4
    if key(K_RETURN):
      gameInit()
      startscreen = false
      caught = false
  if not caught and not startscreen:
    for hunter in hunters:
      if distance(player, hunter) < player.radius + hunter.radius:
        caught = true
        return
    player.move(keysToDirection())
    for hunter in hunters.mitems:
      #hunter.move(toDirection(player.pos - hunter.pos))
      hunter.hunt(player)

proc gameDraw() =
  cls()
  if startscreen:
    #setColor(7)
    #setColor(mapRGB(0xff, 0xff, 0xff))
    setColor(MyColors("white"))
    printc("Press Enter To Start", win_hw, win_hh-5)
    printc(fmt"Hunters: {hunter_num}", win_hw, win_hh+5)
    return

  player.draw()
  for hunter in hunters:
    hunter.draw
  #setColor(5)
  #setColor(mapRGB(0x30, 0x30, 0x30))
  setColor(MyColors("darkest-gray"))
  nico.boxfill(0, win_h, gui_w, gui_h-win_h)
  #setColor(5)
  #setColor(mapRGB(0x5f, 0x5f, 0x5f))
  setColor(MyColors("darker-gray"))
  nico.hline(0, win_h, gui_w)

  if caught:
    #setColor(7)
    #setColor(mapRGB(0xff, 0xff, 0xff))
    setColor(MyColors("white"))
    printc("You Lost! Press Enter To Replay", win_hw, win_hh-5)
    printc(fmt"Hunters: {hunter_num}", win_hw, win_hh+5)


nico.init(orgName, appName)
nico.createWindow(appName, gui_w, gui_h, 2, false)
nico.run(gameInit, gameUpdate, gameDraw)

