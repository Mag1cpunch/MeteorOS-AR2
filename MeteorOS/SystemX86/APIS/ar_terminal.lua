--------------------------------------------------------------------------------------------------------
-- Wojbies API 4.3 - CanvasTerm - Api for drawing window-like term object on Plethora overlay glasses --
--------------------------------------------------------------------------------------------------------
--   Copyright (c) 2015-2021 Wojbie (wojbie@wojbie.net)
--   Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
--   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--   4. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--   5. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--   NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. YOU ACKNOWLEDGE THAT THIS SOFTWARE IS NOT DESIGNED, LICENSED OR INTENDED FOR USE IN THE DESIGN, CONSTRUCTION, OPERATION OR MAINTENANCE OF ANY NUCLEAR FACILITY.

--### Basic utility functions
local function copyTable(...)
    local tArgs = {...}
    local copy = {}
    for _, piece in pairs(tArgs) do
        if piece and type(piece) == "table" then
            for key, val in pairs(piece) do
                if type(val) == "table" then copy[key] = copyTable( copy[key] or {}, val)
                else copy[key] = val end
            end
        end
    end
    return copy
end

--### Initializing
local c = shell and {} or (_ENV or getfenv())
c.versionName = "CanvasTerm By Wojbie"
c.versionNum = 4.338 --2020-01-15

local expect = require "cc.expect".expect

--### Internal palette related tables.
local tDefaultPallette = {[ colors.white ] = 0xF0F0F0, [ colors.orange ] = 0xF2B233, [ colors.magenta ] = 0xE57FD8, [ colors.lightBlue ] = 0x99B2F2, [ colors.yellow ] = 0xDEDE6C, [ colors.lime ] = 0x7FCC19, [ colors.pink ] = 0xF2B2CC, [ colors.gray ] = 0x4C4C4C, [ colors.lightGray ] = 0x999999, [ colors.cyan ] = 0x4C99B2, [ colors.purple ] = 0xB266E5, [ colors.blue ] = 0x3366CC, [ colors.brown ] = 0x7F664C, [ colors.green ] = 0x57A64E, [ colors.red ] = 0xCC4C4C, [ colors.black ] = 0x111111}

local tRGBA = {[ "0" ] = 0xF0F0F0FF, [ "1" ] = 0xF2B233FF, [ "2" ] = 0xE57FD8FF, [ "3" ] = 0x99B2F2FF, [ "4" ] = 0xDEDE6CFF, [ "5" ] = 0x7FCC19FF, [ "6" ] = 0xF2B2CCFF, [ "7" ] = 0x4C4C4CFF, [ "8" ] = 0x999999FF, [ "9" ] = 0x4C99B2FF, [ "a" ] = 0xB266E5FF, [ "b" ] = 0x3366CCFF, [ "c" ] = 0x7F664CFF, [ "d" ] = 0x57A64EFF, [ "e" ] = 0xCC4C4CFF, [ "f" ] = 0x111111FF}

local tHex = {[ colors.white ] = "0", [ colors.orange ] = "1", [ colors.magenta ] = "2", [ colors.lightBlue ] = "3", [ colors.yellow ] = "4", [ colors.lime ] = "5", [ colors.pink ] = "6", [ colors.gray ] = "7", [ colors.lightGray ] = "8", [ colors.cyan ] = "9", [ colors.purple ] = "a", [ colors.blue ] = "b", [ colors.brown ] = "c", [ colors.green ] = "d", [ colors.red ] = "e", [ colors.black ] = "f"}

c.dummyTerm = function(nWidth, nHeight, bColor)

    local isColor = bColor and true or false
    local tDefaultPallette = copyTable(tDefaultPallette)

    local dummy = {}
    dummy.getPaletteColour = function( c ) return colors.unpackRGB(tDefaultPallette[c])  end
    dummy.isColor = function() return isColor end

    local buffer = window.create( dummy, 1, 1, nWidth, nHeight, false )
    local bufferResize = buffer.reposition

    buffer.setVisible = nil
    buffer.redraw = nil
    buffer.restoreCursor = nil
    buffer.getPosition = nil
    buffer.reposition = nil
    buffer.resize = function(nWidth, nHeight) return bufferResize(1, 1, nWidth, nHeight) end

    return buffer
end local dummyTerm = c.dummyTerm

local textOffsetX = { --How much it goes to right on each symbol
    ["!"] = 2, ['"'] = 1, ["'"] = 2, ['('] = 1, [')'] = 1, ['*'] = 1, [","] = 2, ["."] = 2, [":"] = 2, [";"] = 2, ["I"] = 1, ["["] = 1, ["]"] = 1, ["`"] = 2, ["f"] = 1, ["i"] = 2, ["k"] = 1, ["l"] = 2, ["t"] = 1, ["{"] = 1, ["|"] = 2, ["}"] = 1,
    ["\161"] = 2, ["\162"] = 1, ["\164"] = 1, ["\165"] = 1, ["\166"] = 3, ["\167"] = 1, ["\168"] = 1, ["\169"] = 1, ["\176"] = -1, ["\181"] = 1, ["\182"] = 1, ["\184"] = 2, ["\195"] = 1, ["\204"] = 1, ["\205"] = 1, ["\206"] = 1, ["\207"] = 1, ["\208"] = 1, ["\210"] = 1, ["\215"] = 1, ["\217"] = 1, ["\219"] = 1, ["\221"] = 1, ["\222"] = 1, ["\236"] = 1, ["\237"] = 2, ["\239"] = 1, ["\240"] = 1, ["\253"] = 1, ["\254"] = 1,
}
for i = 1, 8 do textOffsetX[string.char(i)] = -1 end
for i = 11, 12 do textOffsetX[string.char(i)] = -1 end
for i = 14, 31 do textOffsetX[string.char(i)] = -1 end
for i = 127, 159 do textOffsetX[string.char(i)] = -1 end
textOffsetX["\173"] = -1

--### Main function
c.create = function( parent, nX, nY, nWidth, nHeight, nScale, bVisible, bFrameCursor, bDisableAutoRedraw )

    expect(1, parent, "table")
    if not parent.addGroup then
        error( "Invalid parent object, please provide 2d canvas. try canvas() or canvas3d().create().addFrame()", 2 )
    end
    expect(2, nX, "number")
    expect(3, nY, "number")
    expect(4, nWidth, "number")
    expect(5, nHeight, "number")
    expect(6, nScale, "number", "nil")
    expect(7, bVisible, "boolean", "nil")
    expect(8, bFrameCursor, "boolean", "nil")
    expect(9, bDisableAutoRedraw, "boolean", "nil")

    bVisible = bVisible ~= false
    nScale = nScale or 1

    local group = parent.addGroup({nX, nY})
    local buffer = dummyTerm(nWidth, nHeight, true)
    local bufferResize = buffer.resize
    buffer.resize = nil
    local tRGBA = copyTable(tRGBA)
    local tHex = copyTable(tHex)
    local textOffsetX = copyTable(textOffsetX)
    local tFrame, tTexts, tBacks, tCursor
    local tText, tFront, tBack, tCursorMeta
    local bBlink, bOnScreen = true, true
    local nTextScaler = 4 / 6

    local function build()
        tTexts = {}
        tBacks = {}
        local xSize = 4 * nScale
        local ySize = 6 * nScale
        tFrame = group.addRectangle( 0 , 0 , xSize * nWidth + 2, ySize * nHeight + 2, 0x111111FF)
        for y = 1, nHeight do
            tBacks[y] = {}
            tTexts[y] = {}
            for x = 1, nWidth do
                tBacks[y][x] = group.addRectangle( (x - 1) * xSize + 1 , (y - 1) * ySize + 1 , xSize, ySize, 0x7F664CFF)
            end
            for x = 1, nWidth do
                tTexts[y][x] = group.addText({(x - 1) * xSize + 1, (y - 1) * ySize + 1}, "A", 0x57A64EFF, nScale * nTextScaler)
                tTexts[y][x].x = (x - 1) * xSize + 1
                tTexts[y][x].y = (y - 1) * ySize + 1
            end
        end
            tCursor = group.addGroup({0, 0})
            tCursor.cursor = tCursor.addText({1, 1}, "_", 0xF0F0F0FF, nScale * nTextScaler)
        if bFrameCursor then
            tCursor.lines = tCursor.addLines({1, 1}, {1, ySize + 1}, {xSize + 1, ySize + 1}, {xSize + 1, 1}, 0xF0F0F0FF, 1)
        end
        bBlink = true
        tText = {}
        tFront = {}
        tBack = {}
        tCursorMeta = {}
        for i in pairs(tHex) do
            tRGBA[tHex[i]] = bit.bor(bit.blshift(colors.packRGB(buffer.getPaletteColour(i)), 8), 0xFF)
        end
    end

    local function destroy()
        for y = 1, nHeight do
            for x = 1, nWidth do tBacks[y][x].remove() end
            for x = 1, nWidth do tTexts[y][x].remove() end
        end
        tFrame.remove()
        tCursor.remove()
    end
    
    local function redrawLine(nLine, bForce)
        local text, front, back = buffer.getLine(nLine)
        if bForce or tBack[nLine] ~= back then --dirty back
            local rowBack = tBacks[nLine]
            back:gsub("()(.)", function(x, c)
                if rowBack[x].color ~= tRGBA[c] then
                    rowBack[x].setColor(tRGBA[c])
                    rowBack[x].color = tRGBA[c]
                end
            end)
            tBack[nLine] = back
        end
        if bForce or tText[nLine] ~= text or tFront[nLine] ~= front then --dirty text
            local rowText = tTexts[nLine]
            front:gsub("()(.)", function(x, c)
                if rowText[x].color ~= tRGBA[c] then
                    rowText[x].setColor(tRGBA[c])
                    rowText[x].color = tRGBA[c]
                end
            end)
            text:gsub("()(.)", function(x, c)
                if rowText[x].text ~= c then
                    rowText[x].setText(c)
                    rowText[x].setPosition(rowText[x].x + (textOffsetX[c] or 0) * nTextScaler * nScale, rowText[x].y)
                    rowText[x].text = c
                end
            end)
            tText[nLine] = text
            tFront[nLine] = front
        end
    end

    local function redraw(bForce)
        for y = 1, nHeight do
            redrawLine(y, bForce)
        end
    end

    local function updateCursor()
        local cx, cy = buffer.getCursorPos()
        if tCursorMeta.x ~= cx or tCursorMeta.y ~= cy then
            bOnScreen = cx > 0 and cx <= nWidth and cy > 0 and cy <= nHeight
            tCursor.setPosition((cx - 1) * 4 * nScale, (cy - 1) * 6 * nScale)
            tCursorMeta.x, tCursorMeta.y = cx, cy
        end
        local cColor = tRGBA[tHex[buffer.getTextColor()]]
        if tCursorMeta.color ~= cColor then
            tCursor.cursor.setColor(cColor)
            tCursorMeta.color = cColor
        end
        local cBlink = buffer.getCursorBlink()
        if tCursorMeta.blink ~= cBlink or tCursorMeta.bOnScreen ~= bOnScreen then
            tCursor.cursor.setAlpha(bBlink and bOnScreen and cBlink and 0xFF or 0)
            tCursorMeta.blink = cBlink
            tCursorMeta.bOnScreen = bOnScreen
        end
    end
    
    local function updatePaletteColor(c)
        if tHex[c] then
            local col =  bit.bor(bit.blshift(colors.packRGB(buffer.getPaletteColour(c)), 8), 0xFF)
            if tRGBA[tHex[c]] ~= col then
                tRGBA[tHex[c]] = col
                return true
            end   
        end
        return false
    end
    
    local function updatePalette()
        local changed = false
        for i in pairs(tHex) do
            local col = bit.bor(bit.blshift(colors.packRGB(buffer.getPaletteColour(i)), 8), 0xFF)
            if tRGBA[tHex[i]] ~= col then
                tRGBA[tHex[i]] = col
                changed = true
            end
        end
        return changed
    end

    local function blinker()
        if math.floor(os.epoch("utc") / 400) % 2 == 0 ~= bBlink then
            bBlink = not bBlink
            tCursor.cursor.setAlpha(bBlink and bOnScreen and buffer.getCursorBlink() and 0xFF or 0)
        end
    end

    
    local redrawDirtiers = {["clear"] = true, ["scroll"] = true }
    local redrawLineDirtiers = {["write"] = true, ["blit"] = true, ["clearLine"] = true }
    local cursorDirters = {["setCursorPos"] = true, ["setCursorBlink"] = true, ["setTextColor"] = true, ["setTextColour"] = true}
    local paletteDirters = {["setPaletteColor"] = true, ["setPaletteColour"] = true}
    
    local canvasTerm = {}
    
    for i, k in pairs(buffer) do
        if bDisableAutoRedraw then
            canvasTerm[i] = k
        elseif redrawDirtiers[i] then
            canvasTerm[i] = function(...)
                local returns = table.pack(k(...))
                if bVisible then redraw() updateCursor() end
                return table.unpack(returns, 1, returns.n)
            end
        elseif redrawLineDirtiers[i] then
            canvasTerm[i] = function(...)
                local returns = table.pack(k(...))
                if bVisible then redrawLine(select(2, buffer.getCursorPos())) updateCursor() end
                return table.unpack(returns, 1, returns.n)
            end
        elseif cursorDirters[i] then
            canvasTerm[i] = function(...)
                local returns = table.pack(k(...))
                if bVisible then updateCursor() end
                return table.unpack(returns, 1, returns.n)
            end
        elseif paletteDirters[i] then
            canvasTerm[i] = function(c, ...)
                local returns = table.pack(k(c, ...))
                local changed = updatePaletteColor(c)
                if bVisible then redraw(changed) updateCursor() end
                return table.unpack(returns, 1, returns.n)
            end
        else
            canvasTerm[i] = k
        end
    end

    canvasTerm.setVisible = function( b )
        expect(1, b, "boolean")
        if bVisible ~= b then
            bVisible = b
            if bVisible then
                build()
                redraw()
                updateCursor()
            else
                destroy()
            end
        end
    end

    if bDisableAutoRedraw then

        canvasTerm.flush = function()
            if bVisible then
                local changed = updatePalette()
                redraw(changed)
                updateCursor()
            end
        end

    end
    
    canvasTerm.loadLines = function(tWindow)
        expect(1, tWindow, "table")
        assert(tWindow.getLine, "Error. loadLones requires windows table with getLine supported")
        local _, inY = tWindow.getSize()
        local cX, xY = buffer.getCursorPos()
        for i in pairs(tHex) do
            buffer.setPaletteColour(i, tWindow.getPaletteColour(i))
        end
        for y = 1, math.min(nHeight, inY) do
            buffer.setCursorPos(1, y)
            buffer.blit(tWindow.getLine(y))
        end
        buffer.setCursorPos(cX, xY)
        if bVisible then
            local changed = updatePalette()
            redraw(changed)
            updateCursor()
        end
    end

    canvasTerm.blinker = function()
        if bVisible then
            blinker()
        end
    end

    canvasTerm.reposition = function( nNewX, nNewY, nNewWidth, nNewHeight, nNewScale, newParent )
        if nNewX ~= nil or nNewY ~= nil then
            expect(1, nNewX, "number")
            expect(2, nNewY, "number")
        end
        if nNewWidth ~= nil or nNewHeight ~= nil then
            expect(3, nNewWidth, "number")
            expect(4, nNewHeight, "number")
        end
        expect(5, nNewScale, "number", "nil")
        expect(6, newParent, "table", "nil")

        if bVisible then
            destroy()
        end

        nX = nNewX or nX
        nY = nNewY or nY
        nWidth = nNewWidth or nWidth
        nHeight = nNewHeight or nHeight
        nScale = nNewScale or nScale
        parent = newParent or parent

        group.remove()
        group = parent.addGroup({nX, nY})
        bufferResize(nWidth, nHeight)

        if bVisible then
            build()
            redraw()
            updateCursor()
        end
    end

    if bVisible then
        build()
        redraw()
        updateCursor()
    end

    return canvasTerm
end

--### Finalizing
return c