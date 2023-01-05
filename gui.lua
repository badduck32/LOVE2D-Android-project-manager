curgroup = "main-menu"
components = {}

function updateGUI()
	if     curgroup == "main-menu"   then loadMainMenu()
	elseif curgroup == "add-project" then loadAddProject()
	elseif curgroup == "editor"      then loadEditor()
	end
end

function clearComponents()
	for i, v in ipairs(components) do
		gooi.removeComponent(v)
	end
	components = {}
end

function loadMainMenu()
	clearComponents()
	curgroup = "main-menu"
	components = {
		gooi.newLabel({
			text = "Choose a project to load",
			x = 0 + xoffs,
			y = 25 + yoffs,
			w = w,
			h = 25,
			group = "main-menu"
		})
		:center(),
		gooi.newButton({
			text = "Add new project",
			x = 10 + xoffs,
			y = h - 50 + yoffs,
			w = w - 20,
			h = 40,
			group = "main-menu"
		})
		:onRelease(function()
			loadAddProject()
		end)
	}
	for i, v in ipairs(projectlist) do
		table.insert(components, gooi.newButton({
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
		end))
	end
end

function loadAddProject()
	clearComponents()
	curgroup = "add-project"
	components = {
		gooi.newText({
			text = "",
			x = 10 + xoffs,
			y = h/2 - 40 + yoffs,
			w = w-20,
			h = 40,
			group = "add-project",
		}),
		gooi.newButton({
			text = "Cancel",
			x = 10 + xoffs,
			y = h/2 + yoffs,
			w = w/2 - 10,
			h = 40,
			group = "add-project"
		})
		:onRelease(function()
			loadMainMenu()
		end),
		gooi.newButton({
			text = "Confirm",
			x = w/2 + xoffs,
			y = h/2 + yoffs,
			w = w/2 - 10,
			h = 40,
			group = "add-project"
		})
		:onRelease(function()
			addNewProject(components[1]:getText())
		end)
	}
end

function loadEditor()
	clearComponents()
	curgroup = "editor"
	components = {
		gooi.newLabel({
			text = curprojectname,
			x = 10 + xoffs,
			y = 10 + yoffs,
			w = w - 60,
			h = 50,
			group = "editor"
		}),
		gooi.newButton({
			text = "Run game",
			x = 10 + xoffs,
			y = h - 50 + yoffs,
			w = w - 20,
			h = 40,
			group = "editor"
		})
		:onRelease(function()
			runCurProject(curprojectpath)
		end),
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
					loadMainMenu()
				end
			})
		end)
	}
end
	