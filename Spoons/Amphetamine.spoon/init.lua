-- https://gist.github.com/heptal/50998f66de5aba955c00
-- caffeine replacement

local M = {}
M.__index = M

local ampOnIcon = [[ASCII:
.....1a..........AC..........E
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
.....5c.......................
]]

local ampOffIcon = [[ASCII:
.....1a.....x....AC.y.......zE
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
...x.5c....y.......z..........
]]


local function setIcon(state)
  M.menu:setIcon(state and ampOnIcon or ampOffIcon)
end

function M:init()
	self.menu = hs.menubar.new()
	self.menu:setClickCallback(function() setIcon(hs.caffeinate.toggle("displayIdle")) end)
	setIcon(hs.caffeinate.get("displayIdle"))
end

return M
