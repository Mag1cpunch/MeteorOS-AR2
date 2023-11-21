print("Booting UP MeteorOS...")
if not fs.exists("/MeteorOS/BootScripts") then
    fs.makeDir("/MeteorOS/BootScripts")
end
for _, file in ipairs(fs.list("/MeteorOS/BootScripts")) do
    if fs.exists("/MeteorOS/BootScripts/"..file) then
        shell.run("/MeteorOS/BootScripts/"..file)
    end
end
shell.run("/MeteorOS/SystemX86/CoreApps/shell.lua")