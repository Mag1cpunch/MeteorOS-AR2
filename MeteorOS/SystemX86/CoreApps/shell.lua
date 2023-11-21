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
        if category == nil and fs.exists("/MeteorOS/Programs/"..app) then
            shell.run("/MeteorOS/Programs/"..app)
        elseif category ~= nil and fs.exists("/MeteorOS/Programs/"..category) then
            local fullPath = "/MeteorOS/Programs/"..category.."/"..app
            if fs.exists(fullPath) then
                shell.run(fullPath)
            else
                print("App '"..app.."' doesn't exist in category '"..category.."'")
            end
        else
            print("Program '"..app.."' doesn't exist")
        end
    else
        print("[System Exception] openProgram(): No program specified.")
    end
end
local function installUpdate()
    if fs.exists("/MeteorOS") then
        fs.delete("/MeteorOS")
    end
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/startup.lua")
    shell.run("mkdir /MeteorOS")
    shell.run("cd /MeteorOS")
    shell.run("mkdir SystemX86")
    shell.run("mkdir SystemX86/CoreApps")
    shell.run("mkdir Programs")
    shell.run("cd SystemX86/CoreApps")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/CoreApps/shell.lua")
    shell.run("cd ../../Programs")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/orescanner.lua")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/arterm.lua")
    os.reboot()
end
local function listGitFiles(repoUrl)
    local apiUrl = repoUrl .. "/contents/"
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
    local lines = textutils.unserializeJSON('["' .. content:gsub("\n", '","') .. '"]')
    local yPos = 1
    local scroll = 1
    local cursorX, cursorY = 1, 1

    while true do
        term.clear()
        term.setCursorPos(1, 1)

        -- Display lines
        for i = scroll, scroll + 9 do
            if lines[i] then
                term.setCursorPos(1, i - scroll + 1)
                term.write(lines[i])
            end
        end

        -- Display cursor
        term.setCursorPos(cursorX, cursorY - scroll + 1)

        local event, param = os.pullEvent()
        if event == "key" then
            if param == keys.up and cursorY > 1 then
                cursorY = cursorY - 1
                if cursorY < scroll then
                    scroll = scroll - 1
                end
            elseif param == keys.down and cursorY < #lines then
                cursorY = cursorY + 1
                if cursorY > scroll + 9 then
                    scroll = scroll + 1
                end
            elseif param == keys.left and cursorX > 1 then
                cursorX = cursorX - 1
            elseif param == keys.right and cursorX < #lines[cursorY] + 1 then
                cursorX = cursorX + 1
            elseif param == keys.enter then
                table.insert(lines, cursorY + 1, lines[cursorY]:sub(cursorX))
                lines[cursorY] = lines[cursorY]:sub(1, cursorX - 1)
                cursorY = cursorY + 1
                cursorX = 1
            elseif param == keys.backspace then
                if cursorX > 1 then
                    lines[cursorY] = lines[cursorY]:sub(1, cursorX - 2) .. lines[cursorY]:sub(cursorX)
                    cursorX = cursorX - 1
                elseif cursorY > 1 then
                    cursorY = cursorY - 1
                    cursorX = #lines[cursorY] + 1
                    lines[cursorY] = lines[cursorY] .. lines[cursorY + 1]
                    table.remove(lines, cursorY + 1)
                end
            end
        elseif event == "char" then
            lines[cursorY] = lines[cursorY]:sub(1, cursorX - 1) .. param .. lines[cursorY]:sub(cursorX)
            cursorX = cursorX + 1
        elseif event == "key_up" and param == keys.leftCtrl then
            break
        end
    end

    return table.concat(lines, "\n")
end
local function textEditor()
    term.clear()
    term.setCursorPos(1, 1)

    print("Simple Text Editor")
    print("------------------")

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
            term.clear()
            term.setCursorPos(1, 1)

            print("File: " .. filename)
            print("Press Ctrl to exit editing mode.")

            term.setCursorBlink(true)

            -- Read and edit the content
            content = editContent(content)

            term.setCursorBlink(false)
        elseif option == 2 then
            saveFile(filename, content)
        elseif option == 3 then
            break
        end
    end

    term.clear()
    term.setCursorPos(1, 1)
    print("Text editor closed.")
end
-------------------------------
--Integrated-apps--------------
local function appstore()
    local files
    local files = listGitFiles("https://github.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs")
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
    else
        print("Directory doesn't exist")
    end
end
local function ls(path)
    local t = {}
    if path == nil or path == "" then
        local indexes = fs.list(shell.dir())
        print()
        for _, index in ipairs(indexes) do
            print(index.name)
        end
        print()
    elseif path ~= nil then
        if fs.exists(path) then
            local indexes = fs.list(path)
            print()
            for _, index in ipairs(indexes) do
                print(index.name)
            end
            print()
        else
            print("Directory '"..path.."' doesn't exist")
        end
    else
        print("No path specified")
    end
end
-------------------------------
local function verifyAPIS()
    print("Verifying APIS...")
    if not fs.exists("/MeteorOS/SystemX86/APIS/ar_terminal.lua") then
        shell.run("mkdir /MeteorOS/SystemX86/APIS")
        shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/APIS/ar_terminal.lua")
    else
        fs.delete("/MeteorOS/SystemX86/APIS/ar_terminal.lua")
        shell.run("mkdir /MeteorOS/SystemX86/APIS")
        shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/APIS/ar_terminal.lua")
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
            print("desktop - Launches experimental ui environment(Needs overlay glasses and neural interface)")
            print("clear - Clear the terminal text")
            print("update - Update the OS")
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
    elseif words[1] == "clear" then
        term.clear()
        print("[[---------------------]]")
        print("[[Interactive Shell 1.0]]")
        print("[[---------------------]]")
        print()
    elseif words[1] == "cd" then
        cd(words[2])
    elseif words[1] == "ls" then
        ls(words[2])
    elseif words[1] == "update" then
        installUpdate()
    elseif words[1] == "appstore" then
        appstore()
    elseif words[1] == "nova" then
        textEditor()
    else
        print("Invalid command: "..i)
    end
end
while true do
    xpcall(cli, handleError)
end
