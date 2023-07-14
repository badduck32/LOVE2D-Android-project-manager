local urfs = require("urfs")
require("gooi")

require("gui")

local xoffs, yoffs, w, h = 0, 0, 0, 0

local projectlist = {}
local curprojectpath = ""
local curprojectname = ""

function love.load()
	loadSavedData()
	love.resize()
end

function love.resize()
	xoffs, yoffs, w, h = love.window.getSafeArea()
	updateGUI(xoffs, yoffs, w, h)
end

function loadSavedData()
	local datastring = love.filesystem.read("savedata.txt"):sub(3,-1)
	if datastring == "" then
		projectlist = {}
		--gooi.alert({text = "Welcome!\n \nPress the button at the bottom\nto load in your first project!"})
	else
		local tbl = split(datastring, "\n")
		projectlist = tbl
	end
end

function locationToProjectName(locationstr)
	local tbl = split(locationstr, "/")
	return tbl[#tbl]
end

function split(inputstr, sep)
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function saveData()
	local datastring = "M\n"
	for i, v in ipairs(projectlist) do
		datastring = datastring .. v .. "\n"
	end
	print(datastring)
	love.filesystem.write("savedata.txt", datastring)
end

function addNewProject(path)
	if path:match("/$") then path = path:sub(1, -2) end
	if pathIsLegal(path, locationToProjectName(path)) then
		table.insert(projectlist, 1, path)
		openProject(1, path)
	end
end

function openProject(index, path)
	curprojectname = locationToProjectName(path)
	curprojectpath = path
	table.insert(projectlist, 1, table.remove(projectlist, index))
	saveData()
	loadEditor()
end

function runCurProject()
	local datastring = "P\n"..love.filesystem.read("savedata.txt"):sub(3,-1)
	print(datastring)
	love.filesystem.write("savedata.txt", datastring)
	love.event.quit("restart")
end

function pathIsLegal(path, name)
	if not urfs.mount(path, "game") then
		gooi.alert({text = "Couldn't find project path"})
		return false
	end
	local info = love.filesystem.getInfo("game/main.lua", "file")
	if info == nil then
		urfs.unmount(path)
		gooi.alert({text = "Project doesn't contain main.lua file"})
		return false
	end
	urfs.unmount(path)
	return true
end

function love.mousepressed(x, y, button)     gooi.pressed() end
function love.mousereleased(x, y, button)    gooi.released() end
function love.textinput(text)                gooi.textinput(text) end
function love.keypressed(k, code, isrepeat)
	gooi.keypressed(k, code)
end
function love.keyreleased(k, code, isrepeat) gooi.keyreleased(k, code) end

function love.update(dt)
	gooi.update(dt)
end

function love.draw()
	love.graphics.print("xoffs: "..xoffs.."\nyoffs: "..yoffs.."\nw: "..w.."\nh: "..h, xoffs, yoffs)
	gooi.draw(curgroup)
end

return m