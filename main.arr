# stejný jako image, ale barvy, fill-mode atp nejsou stringy

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



