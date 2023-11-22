----Utilities------------------
local function input(prompt)
    term.write(prompt)
    local i = read()
    return i
end
local function isCharArray(str)
    for i = 1, #str do
        local char = string.sub(str, i, i)
        if #char ~= 1 then
            return false
        end
    end
    return true
end
local function parse(var, datatype)
    if var == nil or datatype == nil then
        printError("[System Exception] parse(): Variable or datatype is not provided")
    elseif var ~= nil and datatype == "string" then
        local a = var.tostring()
        return a
    elseif var ~= nil and datatype == "int" then
        local a = tonumber(var)
        return a
    elseif var ~= nil and datatype == "float" then
        a = tonumber(var)
        return a + 0.0
    else
        printError("[System Exception] parse(): Variable is not defined or invalid datatype")
    end
end
local function readLines(filename)
    local file = io.open(filename, "r")
    if file then
        local lines = {}
        for line in file:lines() do
            table.insert(lines, line)
        end
        file:close()
        return lines
    else
        print("Error opening file: " .. filename)
        return nil
    end
end
local function handleError(err)
    printError("System Exception:", err)
end
local function splitBySpaces(str)
    local t = {}
    for word in str:gmatch("%S+") do
        table.insert(t, word)
    end
    return t
end
local function openProgram(app, category)
    if app ~= nil then
        local path = category and ("/MeteorOS/Programs/"..category.."/"..app) or ("/MeteorOS/Programs/"..app)
        if fs.exists(path) then
            shell.run(path)
        else
            print("Program '"..app.."' doesn't exist" .. (category and " in category '"..category.."'" or ""))
        end
    else
        print("[System Exception] openProgram(): No program specified.")
    end
end
local function installUpdate()
    fs.delete("/MeteorOS")
    fs.makeDir("/MeteorOS")
    fs.makeDir("/MeteorOS/SystemX86")
    fs.makeDir("/MeteorOS/SystemX86/CoreApps")
    fs.makeDir("/MeteorOS/Programs")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/startup.lua /startup.lua")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/CoreApps/shell.lua /MeteorOS/SystemX86/CoreApps/shell.lua")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/orescanner.lua /MeteorOS/Programs/orescanner.lua")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/arterm.lua /MeteorOS/Programs/arterm.lua")
    shell.run("wget https://energetic.pw/computercraft/ore3d/assets/ore3d.lua /MeteorOS/Programs/ore3d.lua")
    fs.delete("/MeteorOS/SystemX86/APIS")
    shell.run("mkdir /MeteorOS/SystemX86/APIS")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/APIS/ar_terminal.lua /MeteorOS/SystemX86/APIS/ar_terminal.lua")
    os.reboot()
end
local function listGitFiles(username, repo, path)
    local apiUrl = "https://api.github.com/repos/"..username.."/".. repo.."/contents/"..path
    local response = http.get(apiUrl)

    if response then
        local responseData = response.readAll()
        response.close()

        local files = textutils.unserializeJSON(responseData)
        local t = {}
        for _, file in ipairs(files) do
            if file.type == "file" and file.name ~= "README.md" then
                table.insert(t, file.name)
            end
        end
        return t
    else
        print("Failed to fetch data from GitHub.")
    end
end

local function table_contains(tbl, x)
    local found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end
local function installPackage(pkg)
    if pkg == nil or pkg == "" then
        print("mpm: No package specified")
        return
    end

    local pkgs = listGitFiles("Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs")
    if not pkgs then
        print("mpm: Failed to retrieve package list.")
        return
    end

    if not table_contains(pkgs, pkg) then
        print("mpm: Package '"..pkg.."' doesn't exist.")
        return
    end

    print("Downloading package '"..pkg.."'...")
    local success = shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/"..pkg..".lua /MeteorOS/Programs/"..pkg..".lua")
    if success then
        print("Package '"..pkg.."' installed.")
    else
        print("Failed to download package '"..pkg.."'.")
    end
end
local function removePackage(pkg)
    if fs.exists("MeteorOS/Programs"..pkg..".lua") then
        fs.delete("MeteorOS/Programs"..pkg..".lua")
        print("Package '"..pkg.."' removed.")
    elseif pkg == nil or pkg == "" then
        print("mpm: No package specified")
        return
    else
        print("Package '"..pkg.."' doesn't exist.")
    end
end
local function loadFile(filename)
    local file = fs.open(filename, "r")
    if file then
        local content = file.readAll()
        file.close()
        return content
    else
        return nil
    end
end
local function saveFile(filename, content)
    local file = fs.open(filename, "w")
    if file then
        file.write(content)
        file.close()
        print("File saved as " .. filename)
    else
        print("Error saving file")
    end
end
local function editContent(content)
    local lines = {}
    for line in content:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local cursorX, cursorY = 1, 1
    local scroll = 0

    while true do
        term.clear()
        term.setCursorPos(1, 1)

        -- Display lines within the scroll window
        for i = 1, 19 do
            if lines[i + scroll] then
                term.setCursorPos(1, i)
                term.write(lines[i + scroll])
            end
        end

        -- Display cursor
        term.setCursorPos(cursorX, cursorY - scroll)

        local event, key = os.pullEvent()
        if event == "key" then
            if key == keys.up and cursorY > 1 then
                cursorY = cursorY - 1
            elseif key == keys.down and cursorY < #lines then
                cursorY = cursorY + 1
            elseif key == keys.left and cursorX > 1 then
                cursorX = cursorX - 1
            elseif key == keys.right and cursorX <= #lines[cursorY] then
                cursorX = cursorX + 1
            elseif key == keys.enter then
                table.insert(lines, cursorY + 1, "")
                cursorY = cursorY + 1
                cursorX = 1
            elseif key == keys.backspace and cursorX > 1 then
                lines[cursorY] = lines[cursorY]:sub(1, cursorX - 2) .. lines[cursorY]:sub(cursorX)
                cursorX = cursorX - 1
            elseif key == keys.backspace and cursorX == 1 and cursorY > 1 then
                cursorX = #lines[cursorY - 1] + 1
                lines[cursorY - 1] = lines[cursorY - 1] .. lines[cursorY]
                table.remove(lines, cursorY)
                cursorY = cursorY - 1
            end
        elseif event == "char" then
            lines[cursorY] = lines[cursorY]:sub(1, cursorX - 1) .. key .. lines[cursorY]:sub(cursorX)
            cursorX = cursorX + 1
        elseif event == "key_up" and key == keys.leftCtrl then
            break
        end
    end

    return table.concat(lines, "\n")
end
local function textEditor()
    term.clear()
    term.setCursorPos(1, 1)
    print("[[----------------]]")
    print("[[Nova Text Editor]]")
    print("[[----------------]]")
    print()

    local filename = input("Enter filename to edit: ")
    local content = loadFile(filename) or ""

    while true do
        term.clear()
        term.setCursorPos(1, 1)

        print("File: " .. filename)
        print("Options:")
        print("1. Edit")
        print("2. Save")
        print("3. Exit")

        local option = tonumber(input("Select option (1-3): "))
        if option == 1 then
            content = editContent(content)
        elseif option == 2 then
            saveFile(filename, content)
        elseif option == 3 then
            break
        end
    end

    term.clear()
    term.setCursorPos(1, 1)
    print("Nova editor closed.")
end
-------------------------------
--Integrated-apps--------------
local function appstore()
    local files
    local files = listGitFiles("Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs")
    print("Programs:")
    for _, file in ipairs(files) do
        print(file)
    end
    print("---End---")
    local i = input("Enter program to download(say 'exit' to exit program): ")
    if i == "exit" then
        return
    end
    if table_contains(files, i) then
        print("Installing "..i.."...")
        shell.run("cd /MeteorOS/Programs/")
        shell.run("wget https://github.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/"..i)
        shell.run("cd /")
        print("Installed!")
    elseif table_contains(files, i) and fs.exists("/MeteorOS/Programs"..i) then
        print("Program '"..i.."' already installed, Updating...")
        fs.delete("/MeteorOS/Programs"..i)
        shell.run("cd /MeteorOS/Programs/")
        shell.run("wget https://github.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/"..i)
        shell.run("cd /")
        print("Updated!")
    else
        print("Program '"..i.."' doesn't exists in repository")
    end
end
local function initfs()
    if not fs.exists("/MeteorOS/Storage") then
        fs.makeDir("/MeteorOS/Storage")
        fs.makeDir("/MeteorOS/Storage/Downloads")
        fs.makeDir("/MeteorOS/Storage/Documents")
    end
end
local function cd(path)
    if fs.exists(path) then
        shell.setDir(path)
    elseif path == nil then
        print("No directory specified")
    elseif path == "/" then
        shell.setDir("/MeteorOS")
    else
        print("Directory doesn't exist")
    end
end
local function ls(path)
    local directory = path or shell.dir()
    if fs.exists(directory) then
        local listings = fs.list(directory)
        for _, item in ipairs(listings) do
            print(item)
        end
    else
        print("Directory '"..directory.."' doesn't exist")
    end
end
-- Global Variables
local screenWidth, screenHeight = term.getSize()
local appMenuVisible = false
local currentApp = nil

-- Apps List
local apps = {
    { name = "Calculator", action = function() openCalculator() end },
    -- Add more apps here
}
-- Function to draw the desktop
local function drawDesktop()
    term.setBackgroundColor(colors.white)
    term.clear()

    -- Draw the app menu toggle button
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.setCursorPos(1, screenHeight)
    term.write(appMenuVisible and "Close" or "Menu")
end
-- Function to draw the app menu
local function drawAppMenu()
    if appMenuVisible then
        term.setBackgroundColor(colors.gray)
        for y = 1, screenHeight - 1 do
            term.setCursorPos(1, y)
            term.clearLine()
        end

        -- List apps
        for i, app in ipairs(apps) do
            term.setCursorPos(1, i)
            term.write(app.name)
        end
    end
end
-- Function to handle touch events
local function handleTouch(x, y)
    if y == screenHeight then
        -- Toggle app menu
        appMenuVisible = not appMenuVisible
    elseif appMenuVisible and y < screenHeight then
        -- Launch app
        local appIndex = y
        if apps[appIndex] then
            currentApp = apps[appIndex].action
            appMenuVisible = false
        end
    end
end
-- Calculator App
function openCalculator()
    local input = ""
    local result = nil
    local errorMessage = nil

    local function drawCalculator()
        term.setBackgroundColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
        term.write("Calculator")
        term.setCursorPos(screenWidth - 6, 1)
        term.write("Close")

        -- Display input and result
        term.setCursorPos(1, 3)
        if errorMessage then
            term.setTextColor(colors.red)
            term.write(errorMessage)
        else
            term.setTextColor(colors.black)
            term.write("Input: " .. input)
            term.setCursorPos(1, 4)
            if result then
                term.write("Result: " .. tostring(result))
            end
        end
    end

    local function calculate()
        local func, err = load("return " .. input)
        if func then
            local ok, res = pcall(func)
            if ok then
                result = res
                errorMessage = nil
            else
                errorMessage = "Error: Invalid calculation"
            end
        else
            errorMessage = "Error: " .. err
        end
    end

    local function handleCalculatorTouch(x, y)
        if y == 1 and x >= screenWidth - 6 then
            return false -- Close button clicked
        end

        if y == screenHeight then
            -- Add your calculator buttons logic here
            -- Example: if x == 1 then input = input .. "1" end
            -- You can add more buttons and handle their logic similarly
        end

        return true
    end

    while true do
        drawCalculator()

        local event, button, x, y = os.pullEvent()
        if event == "mouse_click" or event == "monitor_touch" then
            if not handleCalculatorTouch(x, y) then
                break -- Exit the calculator app
            end
        end

        if event == "key" then
            if button == keys.enter then
                calculate()
            elseif button == keys.backspace then
                input = input:sub(1, -2) -- Remove last character
            end
        end
    end
end
-- Main desktop function
local function desktop()
    while true do
        drawDesktop()
        drawAppMenu()

        local event, button, x, y = os.pullEvent()
        if event == "mouse_click" or event == "monitor_touch" then
            handleTouch(x, y)
        end

        if currentApp then
            currentApp()
            currentApp = nil
        end
    end
end
-------------------------------
local function verifyAPIS()
    print("Verifying APIs...")
    if not fs.exists("/MeteorOS/SystemX86/APIS/ar_terminal.lua") then
        shell.run("mkdir /MeteorOS/SystemX86/APIS")
        shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/APIS/ar_terminal.lua /MeteorOS/SystemX86/APIS/ar_terminal.lua")
    else
        fs.delete("/MeteorOS/SystemX86/APIS/ar_terminal.lua")
        shell.run("mkdir /MeteorOS/SystemX86/APIS")
        shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/APIS/ar_terminal.lua /MeteorOS/SystemX86/APIS/ar_terminal.lua")
    end
    print("Verified!")
end
initfs()
verifyAPIS()
term.clear()
print("[[-------------------------------]]")
print("[[MeteorOS, Interactive Shell 1.0]]")
print("[[-------------------------------]]")
print()
shell.setDir("/MeteorOS")
local function cli()
    cdir = shell.dir()
    local i = input(cdir..">> ")
    local words = splitBySpaces(i)
    if words[1] == "shutdown" then
        os.shutdown()
    elseif words[1] == "reboot" then
        os.reboot()
    elseif words[1] == "run" then
        openProgram(words[2])
    elseif words[1] == "help" then
        if words[2] == nil then
            print("[[---------------------------]]")
            print("shutdown - Shutdown the computer")
            print("reboot - Reboot the computer")
            print("help - Show list of commands")
            print("run - Launch the specified program")
            print("desktop - Launches experimental ui environment")
            print("clear - Clear the terminal text")
            print("update - Update the OS")
            print("mpm - Package management")
            print("nova - Open nova text editor")
            print("[[---------------------------]]")
        elseif words[2] == "programs" then
            print("[[----------Programs---------]]")
            local programs = fs.list("/MeteorOS/Programs")
            for i in ipairs(programs) do
                print(i.name)
            end
            print("[[---------------------------]]")
        else print("Invalid argument")
        end
    elseif words[1] == "mpm -i" or words[1] == "mpm install" then
        installPackage(words[2])
    elseif words[1] == "mpm -h" or words[1] == "mpm --help" then
        print("-i or install - Install specific package, usage: mpm -i <package> or mpm install <package>")
    elseif words[1] == "mpm -r" or words[1] == "mpm remove" then
        removePackage(words[2])
    elseif words[1] == "clear" then
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        print("[[-------------------------------]]")
        print("[[MeteorOS, Interactive Shell 1.0]]")
        print("[[-------------------------------]]")
        print()
    elseif words[1] == "cd" then
        cd(words[2])
    elseif words[1] == "ls" then
        ls(words[2])
    elseif words[1] == "update" then
        installUpdate()
    elseif words[1] == "appstore" then
        appstore()
    elseif words[1] == "desktop" then
        desktop()
    elseif words[1] == "nova" then
        textEditor()
    else
        print("Invalid command: "..i)
    end
end
while true do
    xpcall(cli, handleError)
end
