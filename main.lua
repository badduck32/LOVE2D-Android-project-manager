local urfs = require("urfs")

love.filesystem.setIdentity("love2d-android-project-manager")
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

running = false
if datastring:sub(1, 1) == "G" then running = true end

if running then
	location = split(datastring:sub(3,-1), "\n")[1]
	--projectname = locationToProjectName(location)
	urfs.mount(location, "game")
	love.filesystem.setRequirePath("game/?.lua;game/?/init.lua")
	require("main")
	
	urfs.unmount(location)
else
	require("manager")
end

function love.keypressed(k, code, isrepeat)
	if k == "escape" and running then
		--back to editor
		local datastring = "M\n"..love.filesystem.read("savedata.txt"):sub(3,-1)
		print(datastring)
		love.filesystem.write("savedata.txt", datastring)
		love.event.quit("restart")
	end
end