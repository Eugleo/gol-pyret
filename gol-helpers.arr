include image-typed
import lists as L
import arrays as A

provide: 
  draw-grid, 
  generate-grid,
  draw-grid-ar,
  generate-grid-ar
end

type Grid<T> = List<List<T>>

fun generate-grid<T>(
    gen :: (Number, Number -> T), 
    w :: Number, 
    h :: Number) -> List<List<T>>:

  range(0, h).map(
    lam(y): 
      range(0, w).map(
        lam(x): 
          gen(x, y)
        end)
    end)
end

fun draw-grid<T>(
    grid :: Grid<T>, 
    draw-cell :: (T -> Image)) -> Image:
  
  grid
    .map(lam(c): draw-row(c, draw-cell) end)
    .foldr(
    lam(acc, img): above-align(x-center, acc, img) end, 
    empty-image)
end

fun draw-row<T>(cells :: List<T>, draw-cell :: (T -> Image)) -> Image:
  cells
    .map(draw-cell)
    .foldr(
    lam(acc, img): beside-align(y-center, acc, img) end, 
    empty-image)
end

type GridAr<T> = Array<T>

fun generate-grid-ar<T>(
    gen :: (Number -> T), 
    w :: Number, 
    h :: Number) -> GridAr<T>:
  
  A.build-array(gen, w * h)
end

fun draw-grid-ar<T>(
    grid :: GridAr<T>,
    width :: Number,
    size :: Number,
    should-draw :: (T -> Boolean),
    draw-cell :: (T -> Image)) -> Image:

  height = (grid.length() / width)  
  range(0, grid.length())
    .foldr(
    lam(ix, acc): 
      cell = grid.get-now(ix)
      if should-draw(cell):
        x = num-modulo(ix, width)
        y = num-truncate(ix / width)
        underlay-xy(
          acc,
          x * size,
          y * size,
          draw-cell(cell))
      else:
        acc
      end
    end,
    rectangle(width * size, height * size, mode-solid, gray))
end
