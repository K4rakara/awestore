# AweStore
### Sveltes store API for AwesomeWM.

<img src="./demo.gif" height="240"/> 

> Huge thanks to [JavaCafe](https://github.com/JavaCafe01) for the demo GIF :)

Installation:

```sh
sudo luarocks --lua-version 5.3 install awestore
```

### Documentation

This library is built off the concept of _stores_ from
[Svelte](https://svelte.dev). A store is a simple table that can be subscribed
to, notifying intrested parties whenever the _stored_ value changes. Heres
simple example:

```lua
local awestore = require "awestore"

local my_store = awestore.writable(1)

my_store:subscribe(function(v) print(v); end) -- prints "1"

my_store:set(2) -- prints "2"
```

`subscribe` returns an unsubscriber function, which when called, unregisters
the function registered using `subscribe`. **This is necessary for garbage
collection of upvalues captured by the registered functions.**

```lua
local awestore = require "awestore"

local my_store = awestore.writable(1)

local unsubscriber = my_store:subscribe(function(v) print(v); end) -- prints "1"

my_store:set(2) -- prints "2"

unsubscriber()

my_store:set(3) -- prints nothing
```

To create a read-only version of a `writable` store, you can use a `monitor`
store:

```lua
local awestore = require "awestore"

local my_writable_store = awestore.writable(1)

local my_monitor_store = awestore.monitor(my_writable_store) -- or my_writable_store:monitor()

my_monitor_store:subscribe(function(v) print(v); end) -- prints "1"

my_store:set(2) -- prints "2"

assert(type(my_writable_store.set) == "function")
assert(type(my_monitor_store.set) == "nil")
```

To alter the output of a store and forward it on, you can use a `derived`
store:

```lua
local awestore = require "awestore"

local my_writable_store = awestore.writable(1)

local my_derived_store = awestore.derived(my_writable_store, function(v)
  return v ^ v
end) -- or my_writable_store:derive(fn)

my_derived_store:subscribe(function(v) print(v); end) -- prints "1"

my_store:set(2) -- prints "4"
my_store:set(3) -- prints "27"

assert(type(my_writable_store.set) == "function")
assert(type(my_monitor_store.set) == "nil")
```

The final, and arguably most exciting type of store is `tweened`. It allows you
to smoothly translate between one value and another asynchronously.

The tweened function takes between one and two values, with the first being the
initial value, anhd the second being a table of options to control how the
store behaves.

```lua
local awestore = require "awestore"

local my_tweened = awestore.tweened(0, {
  duration = 100,
  easing = awestore.easing.back_in_out,
})

my_tweened:subscribe(function(v) print(v); end) -- prints "1"

my_tweened:set(1) -- prints "-0.027..."
                  -- prints "-0.076..."
                  -- prints "-0.099..."
                  -- prints "-0.051..."
                  -- prints " 0.113..."
                  -- prints " 0.441..."
                  -- prints " 0.817..."
                  -- prints " 1.020..."
                  -- prints " 1.095..."
                  -- prints " 1.087..."
                  -- prints " 1.041..."
                  -- prints " 1.003..."
                  -- prints " 1"
```


