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
to, notifying interested parties whenever the _stored_ value changes. Heres
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

To create a read-only version of a `writable` store, you can use a `monitored`
store:

```lua
local awestore = require "awestore"

local my_writable_store = awestore.writable(1)

local my_monitored_store = awestore.monitored(my_writable_store) -- or my_writable_store:monitor()

my_monitored_store:subscribe(function(v) print(v); end) -- prints "1"

my_store:set(2) -- prints "2"

assert(type(my_writable_store.set) == "function")
assert(type(my_monitored_store.set) == "nil")
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

Similarly, to only pass forward select outputs of a store, you can use a
`filtered` store:

```lua
local awestore = require "awestore"

local my_writable_store = awestore.writable(1)

local my_filtered_store = awestore.filtered(my_writable_store, function(v)
  return v % 2 == 0
end) -- or my_writable_store:filter(fn)

my_filtered_store:subscribe(function(v) print(v); end) -- prints "nil"

for i = 2, 10 do my_writable_store:set(i) end -- prints "2", "4", "6", "8", "10"
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

## Animations

There are a variety of animations available.

### linear

A linear animation

https://user-images.githubusercontent.com/74227209/115179817-3d388000-a0e5-11eb-80e1-00fad225c7dd.mov

### back_in_out

An animation that goes above the target location, then snaps back

https://user-images.githubusercontent.com/74227209/115179928-7d97fe00-a0e5-11eb-8c5b-c03eb0bdfe6a.mov

### bounce_in_out

This animations has a small bounce effect

https://user-images.githubusercontent.com/74227209/115180122-e5e6df80-a0e5-11eb-9c02-b1b7ae773500.mov

### circ_in_out

A smooth, unintrusive animation

https://user-images.githubusercontent.com/74227209/115180222-29d9e480-a0e6-11eb-9539-d3ad6d521eaf.mov

## cubic_in_out

An animation similar to circ_in_out

https://user-images.githubusercontent.com/74227209/115180390-81785000-a0e6-11eb-82c3-b32605c4dfb0.mov
