local core = require("awestore.core")
local easing = require("awestore.easing")
local tweened = require("awestore.tweened").tweened

return {
  derived = core.derived,
  easing = easing,
  monitor = core.monitor,
  readable = core.readable,
  store = core.store,
  subscribe = core.subscribe,
  tweened = tweened,
  writable = core.writable,
}

