love.window.setMode(800, 600, {highdpi = true})

dbg = require 'love-debugger'

dbg.writeln("Type 'h <return>' to list the commands you can use.")

function love.draw()
	love.graphics.clear(128/255, 191/255, 242/255)
	love.graphics.print("Click to trigger a breakpoint or press any key to crash!")
end

function love.mousepressed()
	dbg.writeln("Hey look! A breakpoint!")
	dbg()
end

function love.keypressed()
	local a_string = "five"
	local a_number = 5
	local crash = a_string + a_number
end
