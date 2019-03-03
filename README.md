An effective but lightweight interactive debugger for the Löve game engine.

![example](http://files.slembcke.net/upshot/upshot_FSOJncIH.png)

The debugger screen will appear whenever you call the debugger object or crash. (More info on that [here](https://github.com/slembcke/debugger.lua)) It then gives you the chance to inspect your variables, modify them, call functions, evaluate expressions, step through the code, etc. It even has support for displaying the code as you step through it to help you pinpoint bugs faster.

Install:
-

* Drop `debugger.lua`, `love-debugger.lua`, and `VeraMono.ttf` into your project.
* Somwhere in your main file call `dbg = require 'love-debugger'`
* Profit!

Vanilla debugger.lua usage:
-

If you run Löve from the command line, you can also use the vanilla debugger.lua. `love-debugger.lua` just provides a an in-engine console to use to make it a little friendlier. Power users might prefer the vanilla debugger since it lets them use the more powerful features of a regular terminal. While it would work as-is, you'll probably want to set Löve's debug hook to invoke the debugger, and set the right stack depth.

```
dbg = require 'debugger'
function love.errorhandler(msg) dbg.error(msg, 3) end
```

Known Issues:
-

* Löve uses Luajit and there is a known issue where assigning to local variables does not work. (globals,  upvalues, and table fields work fine though. /shrug) It works fine with vanilla Lua 5.1 to 5.3. It's unclear if this is a bug in debugger.lua or Luajit's `debug` library implementation.
* Drawing in Löve uses a _ton_ of graphics states. I'm _sure_ there will be bugs with the console showing up weird in some cases. I'd löve to make this more robust if people want to give me feedback.

Bitsteam Vera Font License here:
https://www.gnome.org/fonts/#Final_Bitstream_Vera_Fonts
