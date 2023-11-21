if fs.exists("/MeteorOS") then
    fs.delete("/MeteorOS")
end
shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/startup.lua")
shell.run("mkdir /MeteorOS")
shell.run("cd /MeteorOS")
shell.run("mkdir /MeteorOS/SystemX86")
shell.run("mkdir /MeteorOS/SystemX86/CoreApps")
shell.run("mkdir /MeteorOS/Programs")
shell.run("cd /MeteorOS/SystemX86/CoreApps")
shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/CoreApps/shell.lua")
shell.run("cd /MeteorOS/Programs")
shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/orescanner.lua")
os.reboot()