import lists as L
import median from statistics

provide *

fun time<T, U>(f :: (T -> U), arg :: T) -> Number:
  original = time-now()
  result = f(arg)
  final = time-now()
  final - original
end

fun time-avg<T, U>(f :: (T -> U), arg :: T, count :: Number) -> Number:
  results = range(0, count).map(lam(n): time(f, arg) end)
  median(results)
end
