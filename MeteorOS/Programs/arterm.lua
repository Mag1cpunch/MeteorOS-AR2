-- Add your module directory to the package path
local moduleDirectory = "/MeteorOS/SystemX86/APIS/?.lua;" -- The question mark will be replaced by the module name
package.path = package.path .. ";" .. moduleDirectory
local arterm = require("ar_terminal")
local modules = peripheral.find("neuralInterface")
local function terminal()
    local termsize = term.getSize()
    local canvas = modules.canvas()
    termcanvas = arterm.create(canvas, 250, 250, 10, 18, 2, true, true)
    termcanvas.setVisible(true)
end
local function handleError(err)
    print("Error: " .. err)
    termcanvas.setVisible(false)
    return
end
xpcall(terminal, handleError)