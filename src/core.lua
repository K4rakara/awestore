local utils = require "awestore.utils"

local derived, filtered, monitored, readable, signal, store, writable

store = setmetatable({ }, {
  __name = "store",
  __tostring = function(self) return "store"; end,
  __newindex = function(self, key, value) return; end,
})

function writable(value, start)
  local self = { [store] = true, [readable] = true, [writable] = true, }
  local value = value
  local subscribers = { }
  local start, stop = start or utils.noop, nil
  
  function self:set(new_value)
    if value ~= new_value then
      value = new_value
      if stop ~= nil then
        for _, subscriber in ipairs(subscribers) do
          subscriber(value)
        end
      end
    end
  end
  
  function self:subscribe(fn)
    subscribers[#subscribers + 1] = fn
    if #subscribers == 1 then
      stop = (start(function(value) self:set(value); end)) or utils.noop
    end
    fn(value)
    return function()
      for i, fn_ in ipairs(subscribers) do
        if fn_ == fn then
          table.remove(subscribers, i)
          break
        end
      end
      if #subscribers == 0 then stop(); stop = nil; end
    end
  end
  
  function self:subscribe_next(fn)
    subscribers[#subscribers + 1] = fn
    if #subscribers == 1 then
      stop = (start(function(value) self:set(value); end)) or utils.noop
    end
    return function()
      for i, fn_ in ipairs(subscribers) do
        if fn_ == fn then
          table.remove(subscribers, i)
          break
        end
      end
      if #subscribers == 0 then stop(); stop = nil; end
    end
  end
  
  function self:subscribe_once(fn)
    local unsubscriber
    local unsubscriber = self:subscribe_next(function(value)
      unsubscriber()
      fn(value)
    end)
    return unsubscriber
  end
  
  function self:update(fn) self:set(fn(value)); end
  
  function self:derive(fn) return derived(self, fn); end
  
  function self:get()
    local a
    self:subscribe(function(b) a = b end)()
    return a
  end
  
  function self:monitor() return monitored(self); end 
  
  function self:filter(fn) return filtered(self, fn); end
  
  return self
end

function signal()
  local function signal_monitored(signal)
    local self = { [store] = true, [readable] = true, [monitored] = true, }
    
    function self:subscribe(fn)
      return signal:subscribe(fn)
    end
    
    return self
  end
  
  local self = { [store] = true, [readable] = true, [signal] = true, }
  local subscribers = { }
  
  function self:fire()
    for _, subscriber in ipairs(subscribers) do subscriber(); end
  end
  
  function self:subscribe(fn)
    subscribers[#subscribers + 1] = fn
    return function()
      for i, fn_ in ipairs(subscribers) do
        if fn_ == fn then
          table.remove(subscribers, i)
          break
        end
      end
    end
  end
  
  function self:subscribe_once(fn)
    local unsubscriber
    unsubscriber = self:subscribe(function(value)
      unsubscriber()
      fn(value)
    end)
    return unsubscriber
  end
  
  function self:monitor() return signal_monitored(self); end
  
  return self
end

function readable(value, start)
  local self = { [store] = true, [readable] = true, }
  local inner = writable(value, start)
  
  function self:subscribe(fn) return inner:subscribe(fn); end
  
  function self:subscribe_next(fn) return inner:subscribe_next(fn); end
  
  function self:subscribe_once(fn) return inner:subscribe_once(fn); end
  
  function self:derive(fn) return derived(self, fn); end
  
  function self:get()
    local a
    self:subscribe(function(b) a = b end)()
    return a
  end
  
  function self:monitor() return monitored(self); end
  
  function self:filter(fn) return filtered(self, fn); end
  
  return self
end

function monitored(store_)
  if store_[signal] == true then return store_:monitor(); end
  
  local self = readable(nil, function(set)
    return store_:subscribe(function(value) set(value); end)
  end)
  
  self[monitored] = true
  
  return self
end

function derived(store_, fn)
  local self = readable(nil, function(set)
    return store_:subscribe(function(value) set(fn(value)); end)
  end)
  
  self[derived] = true
  
  return self
end

function filtered(store_, fn)
  local self = readable(nil, function(set)
    return store_:subscribe(function(value)
      if fn(value) then set(value); end
    end)
  end)
  
  self[filtered] = true
  
  return self
end

return {
  derived = derived,
  filtered = filtered,
  monitored = monitored,
  readable = readable,
  signal = signal,
  store = store,
  writable = writable,
}

