local awestore = require("awestore")

local num_assertions_passed = 0

local test = (function(name, fn)
  num_assertions_passed = 0
  print("\x1b[1;38;5;2m       Testing \x1b[0m"..name.."...")
  local results = { pcall(fn) }
  local ok = table.remove(results, 1)
  if not ok then
    print("\x1b[1A\r\x1b[K\x1b[1;38;5;1m        Failed \x1b[0m"..name.." ( "..tostring(num_assertions_passed).." assertions passed )") 
    for _, value in ipairs(results) do print(value) end
  else
    print("\x1b[1A\r\x1b[K\x1b[1;38;5;2m        Passed \x1b[0m"..name.." ( "..tostring(num_assertions_passed).." assertions passed )")
  end
end)

local function assert_eq(a, b)
  if a ~= b then
    error("Assertion failed: "..tostring(a).." != "..tostring(b).."\n"..debug.traceback())
  else
    num_assertions_passed = num_assertions_passed + 1
  end
end

test("writable", function()
  local i = 0
  local store = awestore.writable(0)
  assert_eq(i, 0)
  store:subscribe(function(_) i = i + 1 end)
  assert_eq(i, 1)
  store:set(1)
  assert_eq(i, 2)
  local got
  store:subscribe(function(v) got = v; end)
  assert_eq(i, 2)
  assert_eq(got, 1)
  store:set(2)
  assert_eq(i, 3)
  assert_eq(got, 2)
  assert_eq(got, store:get())
  store:set(store:get() + 1)
  assert_eq(got, 3)
  assert_eq(got, store:get())
  store:update(function(v) return v + 1; end)
  assert_eq(got, 4)
end)

-- readable is tested by testing derived, monitored, tweened, etc
test("readable", function()
  assert_eq()
end)

test("derived", function()
  local store = awestore.writable(0)
  local derive = store:derive(function(v) return v ^ v end)
  local got
  derive:subscribe(function(v) got = v end)
  assert_eq(got, 1)
  store:set(1)
  assert_eq(got, 1)
  store:set(2)
  assert_eq(got, 4)
  store:set(3)
  assert_eq(got, 27)
end)

test("monitored", function()
  local store = awestore.writable(0)
  local monitor = store:monitor()
  local got
  monitor:subscribe(function(v) got = v end)
  assert_eq(got, 0)
  store:set(1)
  assert_eq(got, 1)
  store:set(2)
  assert_eq(got, 2)
  store:set(3)
  assert_eq(got, 3)
end)

os.exit()

