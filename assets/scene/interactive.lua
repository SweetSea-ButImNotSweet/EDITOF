local gc=love.graphics
local draw,setColor=gc.draw,gc.setColor

local introduction_text,introduction_text_X,introduction_text_Y
local big_text,big_text_X,big_text_Y
gc.push()
gc.replaceTransform(SCR.xOy)
    introduction_text=gc.newText(
        FONT.get(25),
        [[Oh hello there! You are in Interactive mode.
This interactive mode is designed to allow you to interact with widgets XD

There is no widgets on the screen right now, press Esc to go back
and create some widgets, then press [I] on the keyboard to come back here.]]
        )
    introduction_text_X,introduction_text_Y=(SCR.w-introduction_text:getWidth())/2,(SCR.h-introduction_text:getHeight())/2

    big_text=gc.newText(FONT.get(100),"INTERACTIVE MODE")
    big_text_X,big_text_Y=(SCR.w-big_text:getWidth())/2,(SCR.h-big_text:getHeight())/2
gc.pop()

local scene={}

function scene.draw()
    if #scene.widgetList==0 then
        setColor(1,1,1)
        draw(introduction_text,introduction_text_X,introduction_text_Y)
    else
        setColor(1,1,1,0.25)
        draw(big_text,big_text_X,big_text_Y)
    end
end

scene.widgetList={}

return scene