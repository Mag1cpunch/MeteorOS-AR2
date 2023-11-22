-- Add your module directory to the package path
local moduleDirectory = "/MeteorOS/SystemX86/APIS/?.lua;" -- The question mark will be replaced by the module name
package.path = package.path .. ";" .. moduleDirectory
local arterm = require("ar_terminal")
local modules = peripheral.find("neuralInterface")
local function terminal()
    local termsize = term.getSize()
    local canvas = modules.canvas()
    termcanvas = arterm.create(canvas, termsize / 2 + 40, termsize / 2 - 40, 300, 200, 2, true, false)
end
local function update()
    termcanvas.redraw()
end
terminal()
while true do
    update()
    sleep(0.1)
end