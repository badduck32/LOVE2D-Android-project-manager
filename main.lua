local loveZip = require("love-zip")
local urfs = require("urfs")
require("gui")
require("gooi")

xoffs = 0
yoffs = 0
w = 384
h = 814

projectlist = {}
curprojectpath = ""
curprojectname = ""

function love.load()
	xoffs, yoffs, w, h = love.window.getSafeArea()
    loadSavedData()
    loadGUI()
end

function loadSavedData()
    --creates a savedata.txt file in case it doesn't exist yet
    love.filesystem.setIdentity("love2d-android-project-manager")
    info = love.filesystem.getInfo("savedata.txt", "file")
    if (info == nil) then
        love.filesystem.write("savedata.txt", "")
    end

    local datastring = love.filesystem.read("savedata.txt")
    if (datastring == "") then
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
    local datastring = ""
    for i, v in ipairs(projectlist) do
        datastring = datastring .. v .. "\n"
    end
    print(datastring)
    love.filesystem.write("savedata.txt", datastring)
end

function addNewProject()
    local newprojectpath = newprojpathfield:getText()
    if newprojectpath:match("/$") then parent = newprojectpath:sub(1, -2) end
    if pathIsLegal(newprojectpath, locationToProjectName(newprojectpath)) then
        --update UI project list
        table.insert(projectlist, 1, newprojectpath)
        openProject(1, newprojectpath)
        gooi.setGroupVisible("add-project", false)
        gooi.setGroupVisible("editor", true)
    end
end

function openProject(index, path)
    curprojectname = locationToProjectName(path)
    curprojectpath = path
    table.insert(projectlist, 1, table.remove(projectlist, index))
    saveData()
end

function zipAndRunCurProject()
    local info = love.filesystem.getInfo("builds", "directory")
    if (info == nil) then
        love.filesystem.createDirectory("builds")
    end
    
    local parent = curprojectpath:sub(1, -string.len(curprojectname) - 2)
    print(parent)
    print(urfs.mount(parent))
    print(loveZip.writeZip(curprojectname, "builds/"..curprojectname..".love"))
    print(urfs.unmount(parent))
    
    gooi.alert({text = "Project built at:\n".. love.filesystem.getSaveDirectory() .. "\n/builds/" .. curprojectname .. ".love"})
    love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/builds/"..curprojectname..".love")
end

function pathIsLegal(path, name)
    print("path = "..path)
    print("name = "..name)
    local parent = path:sub(1, -string.len(name) - 2)
    print("parent = "..parent)
    if (urfs.mount(parent) == false) then
        gooi.alert({text = "Illegal path:\nCould not find parent directory."})
        urfs.unmount(parent)
        return false
    end
    local info = love.filesystem.getInfo(name, "directory")
    if (info == nil) then
        gooi.alert({text = "Illegal path:\nCould not find project directory"})
        urfs.unmount(parent)
        return false
    end
    info = love.filesystem.getInfo(name.."/main.lua", "file")
    if (info == nil) then
        gooi.alert({text = "illegal path:\nCould not find main.lua in root"})
        urfs.unmount(parent)
        return false
    end
    urfs.unmount(parent)
    return true
end

function love.mousepressed(x, y, button)     gooi.pressed() end
function love.mousereleased(x, y, button)    gooi.released() end
function love.textinput(text)                gooi.textinput(text) end
function love.keypressed(k, code, isrepeat)  gooi.keypressed(k, code) end
function love.keyreleased(k, code, isrepeat) gooi.keyreleased(k, code) end

function love.update(dt)
	gooi.update(dt)
end

function love.resize()
	xoffs, yoffs, w, h = love.window.getSafeArea()
end

function love.draw()
    --w, h = select(3, love.window.getSafeArea())
	--love.graphics.print(xoffs, 100, 100)
    --love.graphics.print(yoffs, 100, 200)
    --love.graphics.print(w, 200, 100)
    --love.graphics.print(h, 200, 200)
    gooi.draw("main-menu")
    gooi.draw("add-project")
    gooi.draw("editor")
end