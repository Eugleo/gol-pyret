# stejný jako image, ale barvy, fill-mode atp nejsou stringy

include image-typed
import lists as L
import interact from reactors  # nic jiného z reactors nepotřebujeme

import shared-gdrive("gol-helpers", "1husISXaN1FiZy8S7RJrdX5lt_XVAoxuW") 
  as H

import shared-gdrive("color-utils", "1mpw4clgkijjYJGrMGvAIrQG7m_Vv_Xx3")
  as C


## PRAVIDLA

# Pokud je teď ALIVE
# 1. Pokud má 2 nebo 3 ALIVE sousedy -> zůstane ALIVE
# 2. Pokud má <2 nebo >3 -> DEAD
#
# Pokud je teď DEAD
# 1. Pokud má přesně 3 ALIVE sousedy -> ALIVE
# 2. Jinak -> zůstane DEAD


## Základní datové typy

data Cell:
  | alive(born :: Number)
  | dead
end

# Grid je pouze alias pro List<List<Cell>>
# Fungují na něj tím pádem všechny seznamové funkce
type Grid = List<List<Cell>>

data State:
  | state(grid :: Grid, tick :: Number) 
end

# Funkce, které úzce souvisí s gridem,
# máme v rámci souboru blízko něj
fun get-width(g :: Grid) -> Number:
  if L.length(g) > 0: 
    L.length(g.get(0)) 
  else:
    0
  end
end

fun get-height(g :: Grid) -> Number:
  L.length(g) 
end

fun set-cell(g :: Grid, x :: Number, y :: Number, val :: Cell) -> Grid:
  g.set(y, g.get(y).set(x, val))
end

## Počáteční stav

fun generate-cell(x :: Number, y :: Number) -> Cell:
  r = num-random(100)
  if r <= 50:
    alive(0)
  else:
    dead
  end
end

GRID = H.generate-grid(generate-cell, 35, 35)


## Funkce on-tick, tedy (Stav -> Stav)
fun step(current-state :: State) -> State:  
  current-grid = current-state.grid
  current-tick = current-state.tick
  
  fun go(acc :: Grid, x :: Number, y :: Number):
    if y >= get-height(current-grid):
      acc
    else:
      n-count = count-alive-neighbours(current-grid, x, y)
      
      new-acc = 
        if is-alive-at(current-grid, x, y): 
          if (n-count == 2) or (n-count == 3):
            acc
          else:
            set-cell(acc, x, y, dead)
          end
        else:
          if (n-count == 3):
            set-cell(acc, x, y, alive(current-tick))
          else:
            acc
          end
        end
      
      new-x = num-modulo(x + 1, get-width(current-grid))
      new-y = if new-x == 0: y + 1 else: y end
      go(new-acc, new-x, new-y)
    end
  end
  
  new-grid = go(current-grid, 0, 0)
  state(new-grid, current-tick + 1)
end

fun is-alive-at(g :: Grid, x :: Number, y :: Number) -> Boolean:
  if (y >= get-height(g)) or (y < 0) or (x >= get-width(g)) or (x < 0):
    false
  else:
    is-alive(g.get(y).get(x))
  end
end

fun count-alive-neighbours(g :: Grid, x :: Number, y :: Number) -> Number:
  neighbours = 
    [list: 
      {x - 1; y - 1}, {x; y - 1}, {x + 1; y - 1}, 
      {x - 1; y}, {x + 1; y}, 
      {x - 1; y + 1}, {x; y + 1}, {x + 1; y + 1}]

  neighbours
    .map(lam({n-x; n-y}): is-alive-at(g, n-x, n-y) end)
    .foldr(lam(c, acc): if c: acc + 1 else: acc end end, 0)
end


## Funkce to-draw, tedy (Stav -> Image)

fun draw-grid(s :: State) -> Image:
  size = 10
    
  fun draw-cell(cell :: Cell) -> Image:
    cases (Cell) cell:
      | alive(born) => 
        base = num-modulo(born, 30)
        c = C.hsv(base / 30, 1, 1)
        frame(square(size, mode-solid, c))
      | dead => 
        square(size, mode-outline, gray)
    end
  end

  H.draw-grid(s.grid, draw-cell)
end


## Základ: naše hra je reactor (případně viz dokumentace)

game = 
  reactor:
    # počáteční stav
    # v našem konkrétním případě je Stav reprezentován jako Grid
    init: state(GRID, 0),
    # funkce, která bere současný stav a vrátí nový stav
    # neboli on-tick je funkce (Stav -> Stav)
    on-tick: step,
    # funkce, která umí stav nakreslit
    # neboli to-draw je funkce (Stav -> Image)
    to-draw: draw-grid,
    # jak často se volá funkce on-tick
    seconds-per-tick: 0.001
  end

interact(game)  # toto spustí reactor

## step
# Tiky postupně zvětšujeme OK
# Tiky počítáme bokem OK
# Tiky ukládáme do nových buněk OK

## v draw-grid
# barva tiku = num-modulo(cislo tiku, počet barev)
# Každý tik má svou barv# stejný jako image, ale barvy, fill-mode atp nejsou stringy

import image-typed as IT
include from IT:
  square, gray, mode-outline, frame, mode-solid,
  type Image
end

import lists as L
import interact from reactors  # nic jiného z reactors nepotřebujeme

import shared-gdrive("gol-helpers", "1husISXaN1FiZy8S7RJrdX5lt_XVAoxuW") 
  as H

import shared-gdrive("color-utils", "1mpw4clgkijjYJGrMGvAIrQG7m_Vv_Xx3")
  as C

import
  shared-gdrive("timing", "1hcSxH1zW9wxRu1IgcLVmFstMg1oqoi4q")
  as T


## PRAVIDLA

# Pokud je teď ALIVE
# 1. Pokud má 2 nebo 3 ALIVE sousedy -> zůstane ALIVE
# 2. Pokud má <2 nebo >3 -> DEAD
#
# Pokud je teď DEAD
# 1. Pokud má přesně 3 ALIVE sousedy -> ALIVE
# 2. Jinak -> zůstane DEAD


## Základní datové typy

data Cell:
  | alive(born :: Number)
  | dead
end

fun num(c :: Cell) -> Number: if is-alive(c): 1 else: 0 end end

# Grid je pouze alias pro List<List<Cell>>
# Fungují na něj tím pádem všechny seznamové funkce
type Grid = List<List<Cell>>

data State:
  | state(grid :: Grid, tick :: Number) 
end

# Funkce, které úzce souvisí s gridem,
# máme v rámci souboru blízko něj
fun get-width(g :: Grid) -> Number:
  if L.length(g) > 0: 
    L.length(g.get(0)) 
  else:
    0
  end
end

fun get-height(g :: Grid) -> Number:
  L.length(g) 
end

## Počáteční stav

fun generate-cell(x :: Number, y :: Number) -> Cell:
  r = num-random(100)
  if r <= 50:
    alive(0)
  else:
    dead
  end
end

GRID = H.generate-grid(generate-cell, 30, 30)


## Generally useful functions

fun alive-n<T>(ts :: List<T>, n :: Number) -> Number:
  if (n == 0):
    0
  else:
    cases (List) ts:
      | empty => 0
      | link(t, rest) => num(t) + alive-n(rest, n - 1)
    end
  end
end

fun zip<T, U>(lx :: List<T>, ly :: List<U>) -> List<{T; U}>:
  cases (List) lx:
    | empty => empty
    | link(x, xs) => 
      cases (List) ly:
        | empty => empty
        | link(y, ys) => link({x; y}, zip(xs, ys))
      end
  end
end


## Neighbour counting

fun step(current-state :: State) -> State:
  current-grid = current-state.grid
  current-tick = current-state.tick
  
  x-max = get-width(current-grid) - 1
  y-max = get-height(current-grid) - 1
  new-grid = count-neigbours-v(current-tick, current-grid, x-max, {0; y-max})
  
  state(new-grid, current-tick + 1)
end

fun count-neigbours-v(current-tick :: Number, g :: Grid, x-max, {y; y-max}):
  if (y > y-max):
    empty
  else if y-max == 0:
    [list: count-neighbours-h(empty, g.get(0), empty, {0; x-max})]
  else:
    
    {above; here; below} =
      if y == 0:
        {empty; g.get(0); g.get(1)}
      else if y == y-max:
        {g.get(0); g.get(1); empty}
      else:
        {g.get(0); g.get(1); g.get(2)}
      end
    
    rest = if (y == 0) or (y == y-max): g else: g.rest end
        
    link(
      count-neighbours-h(current-tick, above, here, below, {0; x-max}),
      count-neigbours-v(current-tick, rest, x-max, {y + 1; y-max}))
  end

end

fun move-right-deleted(cells :: List<Cell>, x :: Number, x-max :: Number) -> List<Cell>:
  if x == 0: 
    cells
  else if (x == x-max) or is-empty(cells): 
    empty
  else:
    cells.rest
  end
end

fun count-neighbours-h(
    current-tick :: Number,
    above :: List<Cell>, 
    here :: List<Cell>, 
    below :: List<Cell>,
    {x :: Number; x-max :: Number}) -> List<Cell>:
  if x > x-max:
    empty
  else:    
    current-cell = here.get(if x == 0: 0 else: 1 end)
    t = if x == 0: 2 else: 3 end
    n-count = 
      alive-n(above, t) + (alive-n(here, t) - num(current-cell)) + alive-n(below, t)
    
    new-cell = 
      if is-alive(current-cell): 
        if (n-count == 2) or (n-count == 3):
          current-cell
        else:
          dead
        end
      else:
        if (n-count == 3):
          alive(current-tick)
        else:
          current-cell
        end
      end
    
    new-above = 
      if x == 0: 
        above
      else if (x == x-max) or is-empty(above): 
        empty
      else:
        above.rest
      end
    
    new-here = 
      if x == 0: 
        here
      else if (x == x-max) or is-empty(here): 
        empty
      else:
        here.rest
      end
    
    new-below = 
      if x == 0: 
        below
      else if (x == x-max) or is-empty(below): 
        empty
      else:
        below.rest
      end
    
    link(
      new-cell, 
      count-neighbours-h(
        current-tick,
        new-above,
        new-here,
        new-below,
        {x + 1; x-max}))
  end
end


## Funkce to-draw, tedy (Stav -> Image)

fun draw-grid(s :: State) -> Image:
  size = 10
    
  fun draw-cell(cell :: Cell) -> Image:
    cases (Cell) cell:
      | alive(born) => 
        base = num-modulo(born, 30)
        c = C.hsv(base / 30, 1, 1)
        frame(square(size, mode-solid, c))
      | dead => 
        square(size, mode-outline, gray)
    end
  end

  H.draw-grid(s.grid, draw-cell)
end


## Základ: naše hra je reactor (případně viz dokumentace)

game = 
  reactor:
    # počáteční stav
    # v našem konkrétním případě je Stav reprezentován jako Grid
    init: state(GRID, 0),
    # funkce, která bere současný stav a vrátí nový stav
    # neboli on-tick je funkce (Stav -> Stav)
    on-tick: step,
    # funkce, která umí stav nakreslit
    # neboli to-draw je funkce (Stav -> Image)
    to-draw: draw-grid,
    # jak často se volá funkce on-tick
    seconds-per-tick: 0.001
  end

interact(game)  # toto spustí reactor

#### TIMIMG

g10 = H.generate-grid(generate-cell, 10, 10)
g20 = H.generate-grid(generate-cell, 20, 20)
g40 = H.generate-grid(generate-cell, 40, 40)
g80 = H.generate-grid(generate-cell, 80, 80)

g160 = H.generate-grid(generate-cell, 160, 160)
g320 = H.generate-grid(generate-cell, 320, 320)
g640 = H.generate-grid(generate-cell, 640, 640)

states = [list: g10, g20, g40, g80].map(lam(g): state(g, 0) end)
medium-states = [list: g10, g20, g40, g80, g160].map(lam(g): state(g, 0) end)
bigger-states = [list: g10, g20, g40, g80, g160, g320, g640].map(lam(g): state(g, 0) end)

# draw-times = states.map(
##  lam(s): 
#    k = T.time-avg(draw-grid, s, 25) 
#    spy: k end
##    k
# end)
# spy: draw-times end
# [list: 9.9, 41.4, 177.2, 864]
# [list: 9.36, 36.56, 172.12, 776.8]

# draw-grid
[list: 8, 41, 187, 844]
[list: 9, 33, 152, 642]

step-times = medium-states.map(
  lam(s): 
    k = T.time-avg(step, s, 25) 
    spy: k end 
    k
  end)
spy: step-times end
# [list: 56.8, 228.5, 1187.5, 9605.7]
# [list: 30.08, 169.88, 1080.36, 7814.64, 60727.36]

# step

# Starý step
[list: 27, 159, 875, 6510, 50127]

# Step s hledáčkovými předpočítanými neighbours (HPN)
[list: 8,  33,  190, 1296, 8087,  61311]

# Step s HPN a s go, který vůbec neindexuje do current-grid ani to acc
[list: 3,  14,   54,  214,  858]

# Step se vším v jednom
[list: 3, 34, 61, 215, 864]

# Step bez getů
[list: 4, 17, 70, 198, 787]

# Step bez foldu
[list: 3, 8, 33, 148, 517]

# step bez funkcí 
[list: 2, 9, 38, 151, 511]

# step bez move-right
[list: 2, 8, 31, 128, 449]


# count-alive-neighbours
[list: 0, 0, 1, 1, 2, 3, 7, 15, 34]

# is-alive-at
[list: 0, 0, 0, 0, 0, 0, 1, 2, 4]


u# stejný jako image, ale barvy, fill-mode atp nejsou stringy

include image-typed
import lists as L
import interact from reactors  # nic jiného z reactors nepotřebujeme

import shared-gdrive("gol-helpers", "1husISXaN1FiZy8S7RJrdX5lt_XVAoxuW") 
  as H

import shared-gdrive("color-utils", "1mpw4clgkijjYJGrMGvAIrQG7m_Vv_Xx3")
  as C


## PRAVIDLA

# Pokud je teď ALIVE
# 1. Pokud má 2 nebo 3 ALIVE sousedy -> zůstane ALIVE
# 2. Pokud má <2 nebo >3 -> DEAD
#
# Pokud je teď DEAD
# 1. Pokud má přesně 3 ALIVE sousedy -> ALIVE
# 2. Jinak -> zůstane DEAD


## Základní datové typy

data Cell:
  | alive(born :: Number)
  | dead
end

# Grid je pouze alias pro List<List<Cell>>
# Fungují na něj tím pádem všechny seznamové funkce
type Grid = List<List<Cell>>

data State:
  | state(grid :: Grid, tick :: Number) 
end

# Funkce, které úzce souvisí s gridem,
# máme v rámci souboru blízko něj
fun get-width(g :: Grid) -> Number:
  if L.length(g) > 0: 
    L.length(g.get(0)) 
  else:
    0
  end
end

fun get-height(g :: Grid) -> Number:
  L.length(g) 
end

fun set-cell(g :: Grid, x :: Number, y :: Number, val :: Cell) -> Grid:
  g.set(y, g.get(y).set(x, val))
end

## Počáteční stav

fun generate-cell(x :: Number, y :: Number) -> Cell:
  r = num-random(100)
  if r <= 50:
    alive(0)
  else:
    dead
  end
end

GRID = H.generate-grid(generate-cell, 35, 35)


## Funkce on-tick, tedy (Stav -> Stav)
fun step(current-state :: State) -> State:  
  current-grid = current-state.grid
  current-tick = current-state.tick
  
  fun go(acc :: Grid, x :: Number, y :: Number):
    if y >= get-height(current-grid):
      acc
    else:
      n-count = count-alive-neighbours(current-grid, x, y)
      
      new-acc = 
        if is-alive-at(current-grid, x, y): 
          if (n-count == 2) or (n-count == 3):
            acc
          else:
            set-cell(acc, x, y, dead)
          end
        else:
          if (n-count == 3):
            set-cell(acc, x, y, alive(current-tick))
          else:
            acc
          end
        end
      
      new-x = num-modulo(x + 1, get-width(current-grid))
      new-y = if new-x == 0: y + 1 else: y end
      go(new-acc, new-x, new-y)
    end
  end
  
  new-grid = go(current-grid, 0, 0)
  state(new-grid, current-tick + 1)
end

fun is-alive-at(g :: Grid, x :: Number, y :: Number) -> Boolean:
  if (y >= get-height(g)) or (y < 0) or (x >= get-width(g)) or (x < 0):
    false
  else:
    is-alive(g.get(y).get(x))
  end
end

fun count-alive-neighbours(g :: Grid, x :: Number, y :: Number) -> Number:
  neighbours = 
    [list: 
      {x - 1; y - 1}, {x; y - 1}, {x + 1; y - 1}, 
      {x - 1; y}, {x + 1; y}, 
      {x - 1; y + 1}, {x; y + 1}, {x + 1; y + 1}]

  neighbours
    .map(lam({n-x; n-y}): is-alive-at(g, n-x, n-y) end)
    .foldr(lam(c, acc): if c: acc + 1 else: acc end end, 0)
end


## Funkce to-draw, tedy (Stav -> Image)

fun draw-grid(s :: State) -> Image:
  size = 10
    
  fun draw-cell(cell :: Cell) -> Image:
    cases (Cell) cell:
      | alive(born) => 
        base = num-modulo(born, 30)
        c = C.hsv(base / 30, 1, 1)
        frame(square(size, mode-solid, c))
      | dead => 
        square(size, mode-outline, gray)
    end
  end

  H.draw-grid(s.grid, draw-cell)
end


## Základ: naše hra je reactor (případně viz dokumentace)

game = 
  reactor:
    # počáteční stav
    # v našem konkrétním případě je Stav reprezentován jako Grid
    init: state(GRID, 0),
    # funkce, která bere současný stav a vrátí nový stav
    # neboli on-tick je funkce (Stav -> Stav)
    on-tick: step,
    # funkce, která umí stav nakreslit
    # neboli to-draw je funkce (Stav -> Image)
    to-draw: draw-grid,
    # jak často se volá funkce on-tick
    seconds-per-tick: 0.001
  end

interact(game)  # toto spustí reactor

## step
# Tiky postupně zvětšujeme OK
# Tiky počítáme bokem OK
# Tiky ukládáme do nových buněk OK

## v draw-grid
# barva tiku = num-modulo(cislo tiku, počet barev)
# Každý tik má svou barvu# stejný jako image, ale barvy, fill-mode atp nejsou stringy

import image-typed as IT
include from IT:
  square, gray, mode-outline, frame, mode-solid,
  type Image
end

import arrays as A
import interact from reactors  # nic jiného z reactors nepotřebujeme

import shared-gdrive("gol-helpers", "1husISXaN1FiZy8S7RJrdX5lt_XVAoxuW") 
  as H

import shared-gdrive("color-utils", "1mpw4clgkijjYJGrMGvAIrQG7m_Vv_Xx3")
  as C

import
  shared-gdrive("timing", "1hcSxH1zW9wxRu1IgcLVmFstMg1oqoi4q")
  as T


## PRAVIDLA

# Pokud je teď ALIVE
# 1. Pokud má 2 nebo 3 ALIVE sousedy -> zůstane ALIVE
# 2. Pokud má <2 nebo >3 -> DEAD
#
# Pokud je teď DEAD
# 1. Pokud má přesně 3 ALIVE sousedy -> ALIVE
# 2. Jinak -> zůstane DEAD


## Základní datové typy

data Cell:
  | alive(born :: Number)
  | dead
end

fun num(c :: Cell) -> Number: if is-alive(c): 1 else: 0 end end

# Grid je pouze alias pro List<List<Cell>>
# Fungují na něj tím pádem všechny seznamové funkce
data Grid:
  | mk-grid(width :: Number, height :: Number, cells :: Array<Cell>)
end

data State:
  | state(grid :: Grid, tick :: Number) 
end


## Počáteční stav

fun generate-cell(ix :: Number) -> Cell:
  r = num-random(100)
  if r <= 50:
    alive(0)
  else:
    dead
  end
end

GRID = mk-grid(200, 200, H.generate-grid-ar(generate-cell, 200, 200))


## Step

fun step(current-state :: State) -> State:
  current-grid = current-state.grid
  current-tick = current-state.tick
  
  len = current-grid.cells.length()
  
  fun get-new-cell-at(ix :: Number) -> Cell:
    w = current-grid.width
    cs = current-grid.cells

    n-count = 
      if is-valid(ix - w - 1, len): num(cs.get-now(ix - w - 1)) else: 0 end + 
    if is-valid(ix - w, len): num(cs.get-now(ix - w)) else: 0 end + 
    if is-valid((ix - w) + 1, len): num(cs.get-now((ix - w) + 1)) else: 0 end + 
    if is-valid(ix - 1, len): num(cs.get-now(ix - 1)) else: 0 end + 
    if is-valid(ix + 1, len): num(cs.get-now(ix + 1)) else: 0 end + 
    if is-valid((ix + w) - 1, len): num(cs.get-now((ix + w) - 1)) else: 0 end + 
    if is-valid(ix + w, len): num(cs.get-now(ix + w)) else: 0 end + 
    if is-valid(ix + w + 1, len): num(cs.get-now(ix + w + 1)) else: 0 end 

    current-cell = cs.get-now(ix)

    if is-alive(current-cell): 
      if (n-count == 2) or (n-count == 3):
        current-cell
      else:
        dead
      end
    else:
      if (n-count == 3):
        alive(current-tick)
      else:
        current-cell
      end
    end
  end
  
  new-cells = A.build-array(get-new-cell-at, len)
  state(mk-grid(current-grid.width, current-grid.height, new-cells), current-tick + 1)
end

fun is-valid(ix, len): (ix >= 0) and (ix < len) end

## Funkce to-draw, tedy (Stav -> Image)

fun draw-grid(s :: State) -> Image:
  size = 10
    
  fun draw-cell(cell :: Cell) -> Image:
    cases (Cell) cell:
      | alive(born) => 
        base = num-modulo(born, 30)
        c = C.hsv(base / 30, 1, 1)
        frame(square(size, mode-solid, c))
      | dead => 
        square(size, mode-outline, gray)
    end
  end

  H.draw-grid-ar(s.grid.cells, s.grid.width, size, is-alive, draw-cell)
end


## Základ: naše hra je reactor (případně viz dokumentace)

game = 
  reactor:
    # počáteční stav
    # v našem konkrétním případě je Stav reprezentován jako Grid
    init: state(GRID, 0),
    # funkce, která bere současný stav a vrátí nový stav
    # neboli on-tick je funkce (Stav -> Stav)
    on-tick: step,
    # funkce, která umí stav nakreslit
    # neboli to-draw je funkce (Stav -> Image)
    to-draw: draw-grid,
    # jak často se volá funkce on-tick
    seconds-per-tick: 0.001
  end

interact(game)  # toto spustí reactor

#### TIMIMG

g10 = mk-grid(10, 10, H.generate-grid-ar(generate-cell, 10, 10))
g20 = mk-grid(20, 20, H.generate-grid-ar(generate-cell, 20, 20))
g40 = mk-grid(40, 40, H.generate-grid-ar(generate-cell, 40, 40))
g80 = mk-grid(80, 80, H.generate-grid-ar(generate-cell, 80, 80))

g160 = mk-grid(160, 160, H.generate-grid-ar(generate-cell, 160, 160))
g320 = mk-grid(320, 320, H.generate-grid-ar(generate-cell, 320, 320))
g640 = mk-grid(640, 640, H.generate-grid-ar(generate-cell, 640, 640))

states = [list: g10, g20, g40, g80].map(lam(g): state(g, 0) end)
medium-states = [list: g10, g20, g40, g80, g160].map(lam(g): state(g, 0) end)
bigger-states = [list: g10, g20, g40, g80, g160, g320, g640].map(lam(g): state(g, 0) end)

#draw-times = states.map(
#  lam(s): 
#    k = T.time-avg(draw-grid, s, 25) 
#    spy: k end
#    k
#  end)
# spy: draw-times end
# [list: 9.9, 41.4, 177.2, 864]
# [list: 9.36, 36.56, 172.12, 776.8]

# draw-grid
# [list: 8, 41, 187, 844]
# [list: 9, 33, 152, 642]
# [list: 5, 29, 255, 1462]

step-times = medium-states.map(
  lam(s): 
    k = T.time-avg(step, s, 25) 
    spy: k end 
    k
  end)
spy: step-times end
# [list: 56.8, 228.5, 1187.5, 9605.7]
# [list: 30.08, 169.88, 1080.36, 7814.64, 60727.36]

# step

# Starý step
[list: 27, 159, 875, 6510, 50127]

# Step s hledáčkovými předpočítanými neighbours (HPN)
[list: 8,  33,  190, 1296, 8087,  61311]

# Step s HPN a s go, který vůbec neindexuje do current-grid ani to acc
[list: 3,  14,   54,  214,  858]

# Step se vším v jednom
[list: 3, 34, 61, 215, 864]

# Step bez getů
[list: 4, 17, 70, 198, 787]

# Step bez foldu
[list: 3, 8, 33, 148, 517]

# step bez funkcí 
[list: 2, 9, 38, 151, 511]

# step bez move-right
[list: 2, 8, 31, 128, 449]

# step array
[list: 5, 19, 73, 289, 1164]

# step flat array
[list: 4, 13, 52, 164, 708]

# step flat array count-alive
[list: 2, 12, 46, 171, 569]

# step flat array manual ifs
[list: 1, 5, 27, 92, 312]

# step flat array manual ifs inline
[list: 1, 5, 19, 76, 290]


# count-alive-neighbours
[list: 0, 0, 1, 1, 2, 3, 7, 15, 34]

# is-alive-at
[list: 0, 0, 0, 0, 0, 0, 1, 2, 4]



