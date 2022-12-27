newprojpathfield = nil
titleLabel = nil

function loadGUI()
    gooi.newLabel({
        text = "Choose a project to load",
        x = 0 + xoffs,
        y = 25 + yoffs,
        w = w,
        h = 25,
        group = "main-menu"
    }):center()
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
            openProject(i, v)
            gooi.setGroupVisible("main-menu", false)
            gooi.setGroupVisible("editor", true)
        end)
    end
    gooi.newButton({
        text = "Add new project",
        x = 10 + xoffs,
        y = h - 50 + yoffs,
        w = w - 20,
        h = 40,
        group = "main-menu"
    }):onRelease(function()
        newprojpathfield:setText("")
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
        addNewProject()
    end)
    --TODO: make this label work
    titleLabel = gooi.newLabel({
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
                --update UI project list
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