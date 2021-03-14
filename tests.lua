local awestore = require("awestore")

local test = (function(name, fn)
  print("\x1b[1;38;5;2m       Testing \x1b[0m"..name.."...")
  local results = { pcall(fn) }
  local ok = table.remove(results, 1)
  if not ok then
    print("\x1b[1A\r\x1b[K\x1b[1;38;5;1m        Failed \x1b[0m"..name)
    local pl = (function()
      local ok, pl = pcall(require, "pl.pretty")
      if not ok then pl = (function(value) print(value) end) end
      return pl
    end)()
    for _, value in ipairs(results) do pl(value) end
  else
    print("\x1b[1A\r\x1b[K\x1b[1;38;5;2m        Passed \x1b[0m"..name)
  end
end)

test("subscribe,set", function()
  local i = 0
  local store = awestore.writable(0)
  assert(i == 0)
  store:subscribe(function(_) i = i + 1 end)
  assert(i == 1)
  store:set(1)
  assert(i == 2)
  local got
  store:subscribe(function(v) got = v end)
  assert(i == 2)
  assert(got == 1)
  store:set(2)
  assert(i == 3)
  assert(got == 2)
end)

test("get", function()
  local store = awestore.writable(0)
  assert(store:get() == 0)
  store:set(1)
  assert(store:get() == 1)
end)

test("update", function()
  local got
  local store = awestore.writable(0) 
  store:subscribe(function(v) got = v end)
  assert(got == 0)
  store:update(function(v) return v + 1 end)
  assert(got == 1)
end)

test("derive", function()
  local store = awestore.writable(0)
  local derive = store:derive(function(v) return v ^ v end)
  local got
  derive:subscribe(function(v) got = v end)
  assert(got == 1)
  store:set(1)
  assert(got == 1)
  store:set(2)
  assert(got == 4)
  store:set(3)
  assert(got == 27)
end)

test("monitor", function()
  local store = awestore.writable(0)
  local monitor = store:monitor()
  local got
  monitor:subscribe(function(v) got = v end)
  assert(got == 0)
  store:set(1)
  assert(got == 1)
  store:set(2)
  assert(got == 2)
  store:set(3)
  assert(got == 3)
end)

