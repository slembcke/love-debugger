local gfx = love.graphics;
love.window.setMode(800, 600, {highdpi = true})

dbg = require 'debugger'
dbg.auto_where = 2
function dbg.exit() love.event.quit() end
-- function love.errorhandler(err) dbg.error(err, 3) end

local dbg_cursor = {x = 0, y = 0}
local dbg_color = {1, 1, 1, 1}
local dbg_font = gfx.newFont("VeraMono.ttf", 12)
local dbg_canvas = gfx.newCanvas(gfx.getDimensions())
dbg_canvas:renderTo(function() gfx.clear(0, 0, 0, 1) end)

local function newline()
	dbg_cursor.x = 0
	
	local line_height = dbg_font:getHeight()
	dbg_cursor.y = dbg_cursor.y + line_height
	
	if dbg_cursor.y > dbg_canvas:getHeight() - line_height then
		local canvas = gfx.newCanvas(dbg_canvas:getDimensions())
		gfx.setCanvas(canvas)
		gfx.clear(0, 0, 0, 1)
		gfx.setColor(1, 1, 1, 1)
		gfx.draw(dbg_canvas, 0, -line_height)
		dbg_canvas:release()
		
		dbg_canvas = canvas
		dbg_cursor.y = dbg_cursor.y - line_height
	end
end

local function dbg_putc(char)
	if char == "\n" then
		newline()
	else
		local width = dbg_font:getWidth(char)
		if dbg_cursor.x + width > dbg_canvas:getWidth() then
			newline()
		end
		
		gfx.print(char, dbg_cursor.x, dbg_cursor.y)
		dbg_cursor.x = dbg_cursor.x + width
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
			dbg.write(char)
			
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
	
	gfx.setCanvas(dbg_canvas)
	gfx.setFont(dbg_font)
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
	
	gfx.setCanvas(_canvas)
	gfx.setFont(_font)
	gfx.setColor(unpack(_color))
	gfx.pop()
end

function love.draw()
	local var = "" + 1
	gfx.draw(dbg_canvas)
end

function love.errorhandler(msg)
	-- Call the builtin handler to reset state, but don't execute it's loop function.
	love.errhand(msg)
	
	-- Jump to the debugger.
	dbg.error(msg, 3)
end
