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
        elseif category ~= nil and fs.exists("/MeteorOS/Programs/"..app) then
            if fs.exists("/MeteorOS/Programs/"..category) and fs.exists("/MeteorOS/Programs/"..category.."/"..app) then
                shell.run("/MeteorOS/Programs/"..category.."/"..app)
            elseif not fs.exists("/MeteorOS/Programs/"..category) then
                print("Category '"..category.."' doesn't exist")
            elseif fs.exists("/MeteorOS/Programs/"..category) and not fs.exists("/MeteorOS/Programs/"..category.."/"..app) then
                print("App '"..app.."' doesn't exist in category '"..category.."'")
            end
        else
            print("Program '"..app.."' doesn't exist")
        end
    end
    shell.run("/MeteorOS/Programs/"..app)
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
    os.reboot()
end
-------------------------------
term.clear()
print("[[---------------------]]")
print("[[Interactive Shell 1.0]]")
print("[[---------------------]]")
print()
local function cli()
    local i = input("MeteorOS>> ")
    local words = splitBySpaces(i)
    if words[1] == "shutdown" then
        os.shutdown()
    elseif words[1] == "reboot" then
        os.reboot()
    elseif words[1] == "run" then
        xpcall(openProgram, handleError, words[2])
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
            print("orescanner")
            print("[[---------------------------]]")
        else print("Invalid argument")
        end
    elseif words[1] == "clear" then
        term.clear()
        print("[[-----------------------------------------]]")
        print("[[MeteorOS-AR, OS Version: 2.0, Mode: Shell]]")
        print("[[-----------------------------------------]]")
        print()
    elseif words[1] == "update" then
        installUpdate()
    else
        print("Invalid command: "..i)
    end
end
while true do
    xpcall(cli, handleError)
end
