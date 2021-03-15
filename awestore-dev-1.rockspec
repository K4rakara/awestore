package = "awestore"
version = "dev-1"

description = {
  summary = "Sveltes store API for AwesomeWM.",
  homepage = "https://github.com/K4rakara/awestore",
  license = "MIT",
  detailed = [[
    # AweStore
    ### Sveltes store API for AwesomeWM.
    
    -- TODO
  ]],
}

source = {
  url = "git://github.com/K4rakara/awestore.git",
  branch = "trunk",
}

dependencies = { "lua >= 5.3", "luaposix >= 35.0" }

build = {
  type = "make",
  build_variables = { ["LUA"] = "$(LUA)", },
  install = { lua = { ["awestore"] = "bin/awestore.lua", }, },
}

