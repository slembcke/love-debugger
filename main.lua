local gfx = love.graphics;

dbg = require 'debugger'
dbg.auto_where = 2
function dbg.exit() love.event.quit() end
-- function love.errorhandler(err) dbg.error(err, 3) end

local dbg_cursor = {x = 0, y = 0}
local dbg_color = {1, 1, 1, 1}
local dbg_font = gfx.newFont(14)
local dbg_canvas = gfx.newCanvas(gfx.getDimensions())
dbg_canvas:renderTo(function() gfx.clear() end)

local function dbg_putc(char)
	if char == "\n" then
		dbg_cursor.x = 0
		dbg_cursor.y = dbg_cursor.y + dbg_font:getHeight()
	else
		gfx.print(char, dbg_cursor.x, dbg_cursor.y)
		dbg_cursor.x = dbg_cursor.x + dbg_font:getWidth(char)
	end
end

local CHARMAP = {
	["space"] = " ",
	["return"] = "\n",
	["tab"] = "\t",
}

function dbg.read(prompt)
	dbg.write(prompt)
	
	local str = ""
	while true do
		gfx.clear()
		gfx.draw(dbg_canvas)
		gfx.present()
		
		local event, a, b, c = love.event.wait()
		if event == "quit" or (event == "keypressed" and a == "escape") then
			return nil
		elseif event == "keypressed" then
			local char = CHARMAP[a] or a
			dbg_canvas:renderTo(function() dbg_putc(char) end)
			
			if char == "\n" then
				return str
			else
				str = str..char
			end
		end
	end
end

local ESCAPE = string.char(27)
local COLORS = {["31"] = {1, 0.5, 0.5}, ["34"] = {0.5, 0.5, 1}, ["0"] = {1, 1, 1}}

local function escape_seq(str, i)
	local ctrl, j = str:match("%[(%d+)m()", i + 1)
	local color = COLORS[ctrl]
	if color then
		dbg_color = color
		gfx.setColor(unpack(color))
		return j
	else
		return i + 1
	end
end

function dbg.write(str)
	io.write(str)
	io.flush()
	
	gfx.push()
	local _canvas = gfx.getCanvas()
	local _font = gfx.getFont()
	local _color = {gfx.getColor()}
	
	dbg_canvas:renderTo(function()
		gfx.setColor(unpack(dbg_color))
		local i = 1; while i <= #str do
			local char = str:sub(i, i)
			
			-- Handle escape sequences for colors.
			if char == ESCAPE then
				i = escape_seq(str, i)
			else
				dbg_putc(char)
				i = i + 1
			end
		end
	end)
	
	gfx.setCanvas(_canvas)
	gfx.setFont(_font)
	gfx.setColor(unpack(_color))
	gfx.pop()
end

dbg()

function love.draw()
	gfx.draw(dbg_canvas)
end

function love.errorhandler(msg)
	if not love.window or not love.graphics or not love.event then return end
	if not love.graphics.isCreated() or not love.window.isOpen() then return love.errhand(msg) end
	
	if love.audio then love.audio.stop() end
	if love.joystick then for _, v in ipairs(love.joystick.getJoysticks()) do v:setVibration() end end
	
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then love.mouse.setCursor() end
	end
	
	gfx.reset()
	gfx.origin()
	gfx.setColor(1, 1, 1, 1)
	
	local keymap = {
		["space"] = " ",
		["return"] = "\n",
		["tab"] = "\t",
	}
	
	while true do
		gfx.clear()
		gfx.draw(dbg_canvas)
		gfx.present()
		
		local event, a, b, c = love.event.wait()
		
		if event == "quit" or (event == "keypressed" and a == "escape") then
			return
		elseif event == "keypressed" then
			local char = keymap[a] or a
			dbg_canvas:renderTo(function() dbg_putc(char) end)
		end
	end
end
