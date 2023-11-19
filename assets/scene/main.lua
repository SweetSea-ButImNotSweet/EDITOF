local gc=love.graphics
local editingText='Hello'

-- All variables for Vietnamese typing method
local telexLayout={
    
}

local doubleKeyPressed=false

local scene={}

function scene.enter()
end

function scene.draw()
    FONT.set(30)
    GC.safePrint(editingText,15,SCR.H/2-20)
end

function scene.keyDown(key,isRep)
    if string.find(key,'[A-Za-z0-9]') then

    end
end

return scene