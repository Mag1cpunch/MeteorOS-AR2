if fs.exists("/MeteorOS") then
    fs.delete("/MeteorOS")
end
shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/startup.lua")
shell.run("mkdir /MeteorOS")
shell.run("cd /MeteorOS")
shell.run("mkdir /MeteorOS/SystemX86")
shell.run("mkdir /MeteorOS/SystemX86/CoreApps")
shell.run("mkdir /MeteorOS/SystemX86/APIS")
shell.run("mkdir /MeteorOS/Programs")
shell.run("cd /MeteorOS/SystemX86/CoreApps")
shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/CoreApps/shell.lua")
shell.run("cd /MeteorOS/Programs")
shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/orescanner.lua")
shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/Programs/arterm.lua")
shell.run("wget https://energetic.pw/computercraft/ore3d/assets/ore3d.lua /MeteorOS/Programs/ore3d.lua")
if fs.exists("/MeteorOS/SystemX86/APIS") then
    fs.delete("/MeteorOS/SystemX86/APIS")
    shell.run("mkdir /MeteorOS/SystemX86/APIS")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/APIS/ar_terminal.lua /MeteorOS/SystemX86/APIS/ar_terminal.lua")
else
    shell.run("mkdir /MeteorOS/SystemX86/APIS")
    shell.run("wget https://raw.githubusercontent.com/Mag1cpunch/MeteorOS-AR2/main/MeteorOS/SystemX86/APIS/ar_terminal.lua /MeteorOS/SystemX86/APIS/ar_terminal.lua")
end
os.reboot()