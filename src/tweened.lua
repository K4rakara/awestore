local gears = require("gears")

local posix = require("posix")

local core = require("awestore.core")
local easing = require("awestore.easing")
local utils = require("awestore.utils")

local get_time, get_interpolator, tweened

get_time = (function()
  local sec, nsec = posix.clock_gettime(0)
  return (sec * 1000) + (nsec * 1e-6)
end)

get_interpolator = (function(a, b)
  if a == b or a ~= a then return (function(_) return a; end); end
  
  if type(a) ~= type(b) or utils.is_sequence(a) ~= utils.is_sequence(b) then
    error("Cannot interpolate values of different types.")
  end
  
  if utils.is_sequence(a) then
    local interpolators = { }
    for i, b in ipairs(b) do
      interpolators[#interpolators + 1] = get_interpolator(a[i], b)
    end
    return (function(t) 
      local interpolated = { }
      for _, interpolator in ipairs(interpolators) do
        interpolated[#interpolated + 1] = interpolator(t)
      end
      return interpolated
    end)
  end
  
  if type(a) == "object" then
    local interpolators = { }
    for key, _ in pairs(b) do
      interpolators[key] = get_interpolator(a[key], b[key])
    end
    
    return (function(t)
      local interpolated = { }
      for key, _ in pairs(b) do
        interpolated[key] = interpolators[key](t)
      end
      return interpolated
    end)
  end
  
  if type(a) == "number" then
    local delta = b - a
    return (function(t) return a + t * delta; end)
  end
  
  error("Cannot interpolate values of type "..type(a)..".")
end)

tweened = setmetatable({
  __index = false,
  __tostring = (function(self) return "tweened: "..tostring(self:get()); end),
}, {
  __index = core.readable,
  __call = (function(self, value, options)
    local value, options = value, options or { }
    local store, target, timer
    local set
    
    options.delay = options.delay or 0
    options.duration = options.duration or 400
    options.step = options.step or 16
    options.easing = options.easing or easing.linear
    options.interpolate = options.interpolate or get_interpolator
    
    store = core.writable(value)
    
    set = (function(self, new_value, new_options)
      for key, value in pairs(new_options or { }) do options[key] = value; end
      
      local started = false
      local fn
      
      target = new_value
      
      if timer ~= nil then timer:stop() end
      
      local now = get_time()
      local step = options.step
      local start = now + options.delay
      local stop = now + options.delay + options.duration
      
      timer = gears.timer {
        timeout = step / 1000,
        autostart = true,
        callback = (function()
          local now = get_time()
          
          if now < start then return end
          
          if not started then
            fn = options.interpolate(value, new_value)
            started = true
          end
          
          local elapsed = now - start
          
          if elapsed > options.duration then
            value = new_value
            store:set(new_value)
            timer:stop()
            timer = nil
            return
          end
          
          value = fn(options.easing(elapsed / options.duration))
          store:set(value)
        end),
      }
    end)
    
    return setmetatable({
      [core.store] = true,
      [core.readable] = true,
      [core.writable] = true,
      [tweened] = true,
      set = set,
      subscribe = (function(self, fn) store:subscribe(fn) end),
    }, self)
  end),
  __name = "tweened",
  __tostring = (function(self) return "tweened" end),
})

tweened.__index = tweened

return tweened

