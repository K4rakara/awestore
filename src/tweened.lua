local gears = require("gears")

local posix = require("posix")

local core = require("awestore.core")
local easing = require("awestore.easing")
local utils = require("awestore.utils")

local get_time, get_interpolator, tweened

function get_time()
  local sec, nsec = posix.clock_gettime(0)
  return (sec * 1000) + (nsec * 1e-6)
end

function get_interpolator(a, b)
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
  
  if type(a) == "table" then
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
end

function tweened(value, options)
  local self = {
    [core.store] = true,
    [core.readable] = true,
    [core.writable] = true,
  }
  local value, options = value, options or { }
  local initial, last = value, value
  local store, started, ended, target, timer
  
  options.delay = options.delay or 0
  options.duration = options.duration or 400
  options.step = options.step or 32
  options.easing = options.easing or easing.linear
  options.interpolate = options.interpolate or get_interpolator
  
  store = core.writable(value)
  started = core.signal()
  ended = core.signal()
  
  self.started = started:monitor()
  self.ended = ended:monitor()
  
  function self:set(new_value, new_options)
    for key, value in pairs(new_options or { }) do options[key] = value; end
    
    local started_ = false
    local fn
    
    last = target
    target = new_value
    
    if timer ~= nil then timer:stop() end
    
    local now = get_time()
    local step = options.step
    local start = now + options.delay
    local stop = now + options.delay + options.duration
    
    timer = gears.timer {
      timeout = step / 1000,
      autostart = true,
      callback = function()
        local now = get_time()
        
        if now < start then return; end
        
        if not started_ then
          fn = options.interpolate(value, new_value)
          started:fire()
          started_ = true
        end
        
        local elapsed = now - start
        
        if elapsed > options.duration then
          value = new_value
          store:set(new_value)
          ended:fire()
          timer:stop()
          timer = nil
          return
        end
        
        value = fn(options.easing(elapsed / options.duration))
        store:set(value)
      end,
    }
  end
  
  function self:subscribe(fn) return store:subscribe(fn); end
  
  function self:subscribe_next(fn) return store:subscribe_next(fn); end
  
  function self:subscribe_once(fn) return store:subscribe_once(fn); end
  
  function self:get() return store:get(); end
  
  function self:initial() return initial; end
  
  function self:last() return last; end
  
  function self:monitor(fn) return core.monitor(self, fn); end
  
  function self:derive(fn) return core.derived(self, fn); end
  
  function self:filter(fn) return core.filtered(self, fn); end
  
  return self
end

return tweened

