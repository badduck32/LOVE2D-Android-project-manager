local urfs = require("urfs")

love.filesystem.setIdentity("LAMP")
info = love.filesystem.getInfo("savedata.txt", "file")
if info == nil then
	love.filesystem.write("savedata.txt", "M")
end

local datastring = love.filesystem.read("savedata.txt")

function split(inputstr, sep)
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function locationToProjectName(locationstr)
	local tbl = split(locationstr, "/")
	return tbl[#tbl]
end

--the first letter of the file can be 3 things:
--P: play mode
--E: editor mode
--M: manager mode (no project selected yet)
playmode = false
if datastring:sub(1, 1) == "P" then playmode = true end

if playmode then
	location = split(datastring:sub(3,-1), "\n")[1]
	--projectname = locationToProjectName(location)
	urfs.mount(location, "game")
	package.loaded["main"] = nil
	love.filesystem.setRequirePath("game/?.lua;game/?/init.lua")
	require("main")
	urfs.unmount(location)
else
	require("manager")
end

--support for the back key to return to the editor, but without "consuming" the love.keypressed callback
local press = love.keypressed

function backKeySupport(k, code, isrepeat)
	if k == "escape" and playmode then
		--back to editor
		local datastring = "E\n"..love.filesystem.read("savedata.txt"):sub(3,-1)
		print(datastring)
		love.filesystem.write("savedata.txt", datastring)
		love.event.quit("restart")
	end
	press(k, code, isrepeat)
end


if true then
	love.keypressed = backKeySupport
end