local awestore = require("awestore")

local test = (function(name, fn)
  print("\x1b[1;38;5;2m       Testing \x1b[0m"..name.."...")
  local results = { pcall(fn) }
  local ok = table.remove(results, 1)
  if not ok then
    print("\x1b[1A\r\x1b[K\x1b[1;38;5;1m        Failed \x1b[0m"..name)
    local pl = (function()
      local ok, pl = pcall(require("pl.pretty"))
      if not ok then pl = (function(value) print(value) end) end
      return pl
    end)()
    for _, value in ipairs(results) do pl(value) end
  else
    print("\x1b[1A\r\x1b[K\x1b[1;38;5;2m        Passed \x1b[0m"..name)
  end
end)

test("writable:subscribe,set", function()
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

