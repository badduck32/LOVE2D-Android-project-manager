local loveZip = require("love-zip")
local urfs = require "urfs"
require("gooi")

local xoffs = 0
local yoffs = 0
local w = 384
local h = 813

projectlist = {}
curprojectpath = ""
curprojectname = ""

function love.load()
    love.window.setMode(w, h)
	xoffs, yoffs, w, h = love.window.getSafeArea()
    loadSavedData()
    loadUI()
end

function loadUI()
    gooi.newLabel({
        text = "Choose a project to load",
        x = 0 + xoffs,
        y = 25 + yoffs,
        w = w,
        h = 25,
        group = "main-menu"
    })
    for i, v in ipairs(projectlist) do
        gooi.newButton({
            text = locationToProjectName(v),
            x = 10 + xoffs,
            y = 25 + 60*i + yoffs,
            w = w - 20,
            h = 50,
            group = "main-menu"
        })
        :bg({0.05, 0.05, 0.05})
        :onRelease(function()
            curprojectname = locationToProjectName(v)
            curprojectpath = v
            table.insert(projectlist, 1, table.remove(projectlist, i))
            saveData()
            gooi.setGroupVisible("main-menu", false)
            gooi.setGroupVisible("editor", true)
        end)
    end
    gooi.newButton({
        text = "Load new project",
        x = 10 + xoffs,
        y = h - 50 + yoffs,
        w = w - 20,
        h = 40,
        group = "main-menu"
    }):onRelease(function()
        gooi.setGroupVisible("main-menu", false)
        gooi.setGroupVisible("add-project", true)
    end)
    newprojpathfield = gooi.newText({
        text = "",
        x = 10 + xoffs,
        y = h/2 - 40 + yoffs,
        w = w-20,
        h = 40,
        group = "add-project",
    })
    gooi.newButton({
        text = "Cancel",
        x = 10 + xoffs,
        y = h/2 + yoffs,
        w = w/2 - 10,
        h = 40,
        group = "add-project"
    }):onRelease(function()
        gooi.setGroupVisible("add-project", false)
        gooi.setGroupVisible("main-menu", true)
    end)
    gooi.newButton({
        text = "Confirm",
        x = w/2 + xoffs,
        y = h/2 + yoffs,
        w = w/2 - 10,
        h = 40,
        group = "add-project"
    }):onRelease(function()
        local newprojectpath = newprojpathfield.getText()
        table.insert(projectlist, 1, newprojectpath)
        --TODO: check if this is a correct path: if not, don't add it
        saveData()
        curprojectname = locationToProjectName(newprojectpath)
        curprojectpath = newprojectpath
        gooi.setGroupVisible("add-project", false)
        gooi.setGroupVisible("editor", true)
    end)
    --TODO: make this label work
    gooi.newLabel({
        text = curprojectname,
        x = 10 + xoffs,
        y = 10 + yoffs,
        w = w - 60,
        h = 50,
        group = "editor"
    })
    gooi.newButton({
        text = "Build and run",
        x = 10 + xoffs,
        y = h - 50 + yoffs,
        w = w - 20,
        h = 40,
        group = "editor"
    }):onRelease(function()
        zipAndRunCurProject(curprojectpath)
    end)
    gooi.newButton({
        text = "",
        x = w - 50 + xoffs,
        y = 10 + yoffs,
        w = 40,
        h = 40,
        icon = "assets/trashcan.png",
        group = "editor"
    }):bg({1, 0.05, 0.05})
    :onRelease(function()
        gooi.confirm({
            text = "Are you sure you want to\nremove " .. curprojectname .. "\nfrom the project list?\n \n(note: this will not remove\nit from your hard drive)",
            ok = function()
                table.remove(projectlist, 1)
                saveData()
                gooi.setGroupVisible("editor", false)
                gooi.setGroupVisible("main-menu", true)
            end
        })
    end)
    gooi.setGroupVisible("add-project", false)
    gooi.setGroupVisible("editor", false)
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

function zipAndRunCurProject()
    local info = love.filesystem.getInfo("builds", "directory")
    if (info == nil) then
        love.filesystem.createDirectory("builds")
    end
    
    local parent = curprojectpath:sub(1, -string.len(curprojectname) - 2)
    if parent:match("/$") then parent = parent:sub(1, -2) end
    print(parent)
    print(urfs.mount(parent))
    print(loveZip.writeZip(curprojectname, "builds/"..curprojectname..".love"))
    print(urfs.unmount(parent))
    

    gooi.alert({text = "Project built at:\n".. love.filesystem.getSaveDirectory() .. "\n/builds/" .. curprojectname .. ".love"})
    love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/builds/"..curprojectname..".love")
end

function love.mousepressed(x, y, button)     gooi.pressed() end
function love.mousereleased(x, y, button)    gooi.released() end
function love.textinput(text)                gooi.textinput(text) end
function love.keypressed(k, code, isrepeat)  gooi.keypressed(k, code) end
function love.keyreleased(k, code, isrepeat) gooi.keyreleased(k, code) end

function love.update(dt)
	gooi.update(dt)
end

function love.displayrotated(id, orientation)
	w, h = select(3, love.window.getSafeArea())
end

function love.draw()
    --w, h = select(3, love.window.getSafeArea())
	love.graphics.print(w, 100, 100)
    love.graphics.print(h, 100, 200)
    love.graphics.print(love.graphics.getWidth(), 200, 100)
    love.graphics.print(love.graphics.getHeight(), 200, 200)
    gooi.draw("main-menu")
    gooi.draw("add-project")
    gooi.draw("editor")
end