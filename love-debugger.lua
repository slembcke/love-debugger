local gfx = love.graphics;

local dbg = require 'debugger'
dbg.auto_where = 2
-- dbg.enable_color()

local dbg_cursor = {x = 0, y = 0}
local dbg_color = {1, 1, 1, 1}
local dbg_font = gfx.newFont("VeraMono.ttf", 12)
local dbg_canvas = gfx.newCanvas(gfx.getDimensions())
dbg_canvas:renderTo(function() gfx.clear(0, 0, 0, 1) end)

function dbg_render_to(canvas, func)
	gfx.push(); gfx.origin()
	local _canvas = gfx.getCanvas()
	local _font = gfx.getFont()
	local _color = {gfx.getColor()}
	
	gfx.setCanvas(canvas)
	gfx.setFont(dbg_font)
	gfx.setColor(unpack(dbg_color))
	
	func()
	
	gfx.setCanvas(_canvas)
	gfx.setFont(_font)
	gfx.setColor(unpack(_color))
	gfx.pop()
end

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

function dbg.read(prompt)
	dbg.write(prompt)
	
	local str = ""
	while true do
		dbg_render_to(nil, function()
			gfx.clear()
			gfx.draw(dbg_canvas)
			gfx.present()
		end)
		
		local event, a = love.event.wait()
		if event == "quit" then
			return "q"
		elseif event == "keypressed" and a == "return" then
			dbg.write("\n")
			return str
		elseif event == "keypressed" and a == "backspace" and #str > 0 then
			local char = str:sub(-1, -1)
			local w, h = dbg_font:getWidth(char), dbg_font:getHeight(char)
			dbg_cursor.x = dbg_cursor.x - w
			dbg_render_to(dbg_canvas, function()
				gfx.setColor(0, 0, 0)
				gfx.rectangle("fill", dbg_cursor.x, dbg_cursor.y, w, h)
			end)
			
			str = str:sub(1, -2)
		elseif event == "textinput" then
			dbg.write(a)
			str = str..a
		end
	end
end

local ESCAPE = string.char(27)
	-- COLOR_GRAY = string.char(27) .. "[90m"
	-- COLOR_RED = string.char(27) .. "[91m"
	-- COLOR_BLUE = string.char(27) .. "[94m"
	-- COLOR_YELLOW = string.char(27) .. "[33m"
	-- COLOR_RESET = string.char(27) .. "[0m"
	-- GREEN_CARET = string.char(27) .. "[92m => "..COLOR_RESET
local COLORS = {
	["0"] = {1, 1, 1},
	["33"] = {0.75, 0.75, 0.25},
	["90"] = {0.5, 0.5, 0.5},
	["91"] = {1, 0.25, 0.25},
	["92"] = {0.5, 1, 0.5},
	["94"] = {0.25, 0.25, 1},
}

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
	dbg_render_to(dbg_canvas, function()
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
end

function love.errorhandler(msg)
	-- Call the builtin handler to reset state, but don't execute it's loop function.
	love.errhand(msg)
	
	-- Jump to the debugger.
	dbg.error(msg, 3)
end

return dbg
