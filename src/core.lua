local utils = require("awestore.utils")

local subscribe, store, readable, writable, monitor, derived

subscribe = (function(store, ...)
  if store == nil then return utils.noop end
  local unsub = store:subscribe(...)
  return unsub.unsubscribe
    and (function() return unsub:unsubscribe(); end)
     or unsub
end)

store = setmetatable({ }, {
  __name = "store",
  __tostring = (function(self)
    return "store"
  end),
  __newindex = (function(self, key, value) end),
})

readable = setmetatable({
  __index = false,
  __tostring = (function(self)
    return "readable: "..tostring(self:get())
  end),
  derive = (function(self, fn)
    return derived(self, fn)
  end),
  get = (function(self)
    local a
    self:subscribe(function(b) a = b end)()
    return a
  end),
  monitor = (function(self)
    return monitor(self)
  end),
}, {
  __index = store,
  __call = (function(self, value, start)
    return setmetatable({
      [store] = true,
      [readable] = true,
      subscribe = writable(value, start).subscribe,
    }, self)
  end),
  __name = "readable",
  __tostring = (function(self)
    return "readable"
  end),
})

readable.__index = readable

writable = setmetatable({
  __index = false,
  __tostring = (function(self)
    return "writable: "..tostring(self:get())
  end),
}, {
  __index = readable,
  __call = (function(self, value, start)
    local value = value
    local start, stop = start or utils.noop, nil
    local subscribers = { }
    local update, set, subscribe
    update = (function(self, fn) set(self, fn(value)) end)
    set = (function(self, new_value)
      if value ~= new_value then
        value = new_value
        if stop ~= nil then
          for _, subscriber in ipairs(subscribers) do
            subscriber(value)
          end
        end
      end
    end)
    subscribe = (function(self, fn)
      subscribers[#subscribers + 1] = fn
      if #subscribers == 1 then stop = (start(set)) or utils.noop end
      fn(value)
      return (function()
        for i, fn_ in ipairs(subscribers) do
          if fn_ == fn then
            table.remove(subscribers, i)
            break
          end
        end
        if #subscribers == 0 then stop(); stop = nil; end
      end)
    end)
    return setmetatable({
      [store] = true,
      [readable] = true,
      [writable] = true,
      set = set,
      update = update,
      subscribe = subscribe,
    }, self)
  end),
  __name = "writable",
  __tostring = (function(self)
    return "writable"
  end),
})

writable.__index = writable

monitor = setmetatable({  
  __index = false,
  __tostring = (function(self) return "monitor: "..tostring(self:get()) end),
}, {
  __index = readable,
  __call = (function(self, readable)
    return setmetatable({
      [store] = true,
      [readable] = true,
      [monitor] = true,
      subscribe = (function(self, fn) readable:subscribe(fn) end),
    }, self)
  end),
  __name = "monitor",
  __tostring = (function(self) return "monitor" end),
})

monitor.__index = monitor

derived = setmetatable({
  __index = false,
  __tostring = (function(self) return "derived: "..tostring(self:get()) end),
}, {
  __index = readable,
  __call = (function(self, store, fn)
    local derived = writable(nil)
    store:subscribe(function(value) derived:set(fn(value)) end)
    return setmetatable({
      [derived] = true,
      [store] = true,
      [readable] = true,
      [monitor] = true,
      subscribe = (function(self, fn) derived:subscribe(fn) end),
    }, self)
  end),
  __name = "derived",
  __tostring = (function(self) return "derived" end),
})

derived.__index = derived

return {
  derived = derived,
  monitor = monitor,
  readable = readable,
  store = store,
  subscribe = subscribe,
  writable = writable,
}

