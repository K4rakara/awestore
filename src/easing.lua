local linear
local back_in_out, back_in, back_out
local bounce_in_out, bounce_in, bounce_out
local circ_in_out, circ_in, circ_out
local cubic_in_out, cubic_in, cubic_out
local elastic_in_out, elastic_in, elastic_out
local expo_in_out, expo_in, expo_out
local quad_in_out, quad_in, quad_out
local quart_in_out, quart_in, quart_out
local quint_in_out, quint_in, quint_out
local sine_in_out, sine_in, sine_out

linear = (function(t) return t end)

back_in_out = (function(t)
  local s = 1.70158 * 1.525
  t = t * 2
  if t < 1 then return 0.5 * (t * t * ((s + 1) * t - s)); end
  t = t - 2
  return 0.5 * (t * t * ((s + 1) * t + s) + 2)
end)

back_in = (function(t)
  local s = 1.70158
  return t * t * ((s + 1) * t - s)
end)

back_out = (function(t)
  local s = 1.70158
  t = t - 1
  return t * t * ((s + 1) * t + s) + 1
end)

bounce_in_out = (function(t)
  return (t < 0.5)
    and (0.5 * (1.0 - bounce_out(1.0 - t * 2.0)))
    or  (0.5 * bounce_out(t * 2.0 - 1.0) + 0.5)
end)

bounce_in = (function(t) return 1.0 - bounce_out(1.0 - t); end)

bounce_out = (function(t)
  local a = 4.0 / 11.0
  local b = 8.0 / 11.0
  local c = 9.0 / 10.0
  
  local ca = 4356.0 / 361.0
  local cb = 35442.0 / 1805.0
  local cc = 16061.0 / 1805.0
  
  local t2 = t * t
  
  return ((t < a)
    and (7.5625 * t2)
    or  ((t < b)
      and (9.075 * t2 - 9.9 * t + 3.4)
      or  ((t < c)
        and (ca * t2 - cb * t + cc)
        or  (ca * t2 - cb * t + cc))))
end)

circ_in_out = (function(t)
  t = t * 2
  if t < 1 then return -0.5 * (math.sqrt(1 - t * t) - 1); end
  t = t - 2
  return 0.5 * (math.sqrt(1 - t * t) + 1)
end)

circ_in = (function(t) return 1.0 - math.sqrt(1.0 - t * t); end)

circ_out = (function(t)
  t = t - 1
  return math.sqrt(1 - t * t)
end)

cubic_in_out = (function(t)
  return (t < 0.5)
    and (4.0 * t * t * t)
    or  (0.5 * ((2.0 * t - 2.0) ^ 3.0) + 1.0)
end)

cubic_in = (function(t)
  return t * t * t
end)

cubic_out = (function(t)
  local f = t - 1.0
  return f * f * f + 1.0
end)

elastic_in_out = (function(t)
  return (t < 0.5)
    and (0.5
      * math.sin(((13.0 * math.pi) / 2) * 2.0 * t)
      * (2.0 ^ (10.0 * (2.0 * t - 1.0))))
    or  (0.5
      * math.sin(((-13.0 * math.pi) / 2) * (2.0 * t - 1.0 + 1.0))
      * (2.0 ^ (-10.0 * (2.0 * t - 1.0)))
      + 1.0)
end)

elastic_in = (function(t)
  return math.sin((13.0 * t * math.pi) / 2) * (2.0 ^ (10.0 * (t - 1.0)))
end)

elastic_out = (function(t)
  return math.sin((-13.0 * (t + 1.0) * math.pi) / 2) * (2.0 ^ (-10.0 * t)) + 1.0
end)

expo_in_out = (function(t)
  return (t == 0.0 or t == 1.0)
    and t
    or  ((t < 0.5)
      and ( 0.5 * (2.0 ^ (20.0 * t - 10.0)))
      or  (-0.5 * (2.0 ^ (10.0 - t * 20.0) + 1.0)))
end)

expo_in = (function(t)
  return (t == 0) and t or (2.0 ^ (10.0 * (t - 1.0)))
end)

expo_out = (function(t)
  return (t == 1) and t or (1.0 - (2.0 ^ (-10.0 * t)))
end)

quad_in_out = (function(t)
  t = t / 0.5
  if t < 1 then return 0.5 * t * t; end
  t = t - 1
  return -0.5 * (t * (t - 2) - 1)
end)

quad_in = (function(t) return t * t; end)

quad_out = (function(t) return -t * (t - 2.0); end)

quart_in_out = (function(t)
  return (t < 0.5)
    and ( 8.0 * (t ^ 4.0))
    or  (-8.0 * ((t - 1.0) ^ 4.0) + 1.0)
end)

quart_in = (function(t) return t ^ 4.0; end)

quart_out = (function(t) return ((t - 1.0) ^ 3.0) * (1.0 - t) + 1.0; end)

quint_in_out = (function(t)
  t = t * 2
  if t < 1 then return 0.5 * t * t * t * t * t; end
  t = t - 2
  return 0.5 * t * t * t * t * t + 2
end)

quint_in = (function(t) return t * t * t * t * t; end)

quint_out = (function(t)
  t = t - 1
  return t * t * t * t * t + 1
end)

sine_in_out = (function(t) return -0.5 * (math.cos(math.pi * t) - 1); end)

sine_in = (function(t)
  local v = math.cos(t * math.pi * 0.5)
  if math.abs(v) < 1e-14 then return 1; end
  return 1 - v
end)

sine_out = (function(t) return math.sin((t * math.pi) / 2); end)

return {
  linear = linear,
  back_in_out = back_in_out, back_in = back_in, back_out = back_out,
  bounce_in_out = bounce_in_out, bounce_in = bounce_in, bounce_out = bounce_out,
  circ_in_out = circ_in_out, circ_in = circ_in, circ_out = circ_out,
  cubic_in_out = cubic_in_out, cubic_in = cubic_in, cubic_out = cubic_out,
  elastic_in_out = elastic_in_out, elastic_in = elastic_in, elastic_out = elastic_out,
  expo_in_out = expo_in_out, expo_in = expo_in, expo_out = expo_out,
  quad_in_out = quad_in_out, quad_in = quad_in, quad_out = quad_out,
  quart_in_out = quart_in_out, quart_in = quart_in, quart_out = quart_out,
  quint_in_out = quint_in_out, quint_in = quint_in, quint_out = quint_out,
  sine_in_out = sine_in_out, sine_in = sine_in, sine_out = sine_out,
}

