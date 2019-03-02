dbg = require 'debugger'
dbg.auto_where = 3
function dbg.exit() love.event.quit() end
-- function love.errorhandler(err) dbg.error(err, 3) end

function love.draw()
	error("foobar")
	love.graphics.print("Hello World", 400, 300)
end

function love.errorhandler(msg)
	if not love.window or not love.graphics or not love.event then return end
	if not love.graphics.isCreated() or not love.window.isOpen() then return love.errhand(msg) end
	
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then love.mouse.setCursor() end
	end
	
	if love.joystick then for i,v in ipairs(love.joystick.getJoysticks()) do v:setVibration() end end
	
	if love.audio then love.audio.stop() end
	
	love.graphics.reset()
	love.graphics.origin()
	love.graphics.clear(0, 0, 0)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setNewFont(12)
	love.graphics.present()
	
	while true do
		local e, a, b, c = love.event.wait()
		
		if e == "quit" or (e == "keypressed" and a == "escape") then return end
	end
end
