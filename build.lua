os.execute("rm -rf ./bin/")
os.execute("mkdir ./bin/")

local bundled = (function()
  local bundled = ""
  
  for file in io.popen("find ./src/ -type f -name '*.lua'"):lines() do
    if file == "" then break end
    local rel_file = file
      :gsub(
        ("./src")
          :gsub("%%", "%%")
          :gsub("%.", "%%.")
          :gsub("%+", "%%+")
          :gsub("%-", "%%-"),
        "awestore")
      :gsub(".lua", "")
      :gsub("/", ".")
    if rel_file ~= "awestore.init" then
      bundled = bundled..[[
package.preload["]]..rel_file..[["] = (function()
  ]]..(function()
    local read = ""
    local file = io.open(file, "r")
    for line in file:lines() do read = read.."\n  "..line end
    file:close()
    read = read.."\n"
    return read
  end)()..[[
end)
]]
      print("Bundled "..rel_file..".")
    end
  end
  
  do
    local file = io.open("./src/init.lua", "r")
    for line in file:lines() do bundled = bundled.."\n"..line end
    file:flush()
    file:close()
    print("Bundled awestore.init.")
  end
  
  return bundled
end)()

local minified = (function()
  local cmd = "sh -c '[[ -e /usr/bin/luamin ]] && printf \"YES\"'"
  if io.popen(cmd):read("*a"):sub(1, 3) == "YES" then
    local pipe = io.popen("sh -c 'luamin -c > /tmp/.awestore.luamin.out'", "w")
    pipe:write(bundled)
    pipe:flush()
    pipe:close()
    local out = io.open("/tmp/.awestore.luamin.out", "r"):read("*a")
    os.execute("rm /tmp/.awestore.luamin.out")
    return out
  else
    return bundled
  end
end)()

local compiled = (function()
  local ver = _VERSION:gsub("Lua ", "")
  local pipe = io.popen("luac"..ver.." -o /tmp/.awestore.luac.out -", "w")
  pipe:write(minified)
  pipe:flush()
  pipe:close()
  local out = io.open("/tmp/.awestore.luac.out", "r"):read("*a")
  os.execute("rm /tmp/.awestore.luac.out")
  return out
end)()

io.open("./bin/awestore.lua", "w"):write(compiled)

