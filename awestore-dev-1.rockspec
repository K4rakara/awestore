package = "awestore"
version = "dev-1"

description = {
  summary = "Sveltes store API for AwesomeWM.",
  homepage = "https://github.com/K4rakara/awestore",
  license = "MIT",
  detailed = [[
    This library is built off the concept of stores from Svelte. A store is a
    simple table that can be subscribed to, notifying interested parties
    whenever the stored value changes. For more info, see
    https://github.com/K4rakara/awestore.
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

