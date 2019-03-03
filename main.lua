love.window.setMode(800, 600, {highdpi = true})

dbg = require 'love-debugger'

function love.draw()
	love.graphics.print("Press any key to crash!")
end

function love.keypressed()
	dbg.writeln("Hey look! A breakpoint!")
	dbg()
	
	local a_string = "five"
	local a_number = 5
	local crash = a_string + a_number
end
