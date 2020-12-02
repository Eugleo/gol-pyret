include color

provide: hsv end

fun hsv(h :: Number, s :: Number, v :: Number) -> Color:
  if s == 0:
    color(v * 255, v * 255, v * 255, 1)
  else:
    var-h = if h == 1: 0 else: h * 6 end
    var-i = num-floor(var-h)
    var-1 = v * (1 - s)
    var-2 = v * (1 - (s * (var-h - var-i)))
    var-3 = v * (1 - (s * (1 - (var-h - var-i))))
    
    
    {r; g; b} = 
      if var-i == 0:
        {v; var-3; var-1}
      else if var-i == 1:
        {var-2; v; var-1}
      else if var-i == 2:
        {var-1; v; var-3}
      else if var-i == 3:
        {var-1; var-2; v}
      else if var-i == 4:
        {var-3; var-1; v}
      else:
        {v; var-1; var-2}
      end
    
    color(r * 255, g * 255, b * 255, 1)
  end
end


