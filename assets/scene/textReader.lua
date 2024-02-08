local showingText
local textBox=WIDGET.new{type='textBox',name='texts',x=30,y=45,w=1000,h=640,fontSize=20,fixContent=true}
local scene={}

function scene.enter()
    --[[
        Argument:
        [1] - Text (in table format). Default to "No text!"
        [2] - Font size (in number)
        [3] - Background (in string format)
    ]]

    if SCN.args[1] then
        if type(SCN.args[1])=='string' then
            local _
            _,showingText=FONT.get(20):getWrap(SCN.args[1],960)
        else
            assert(type(showingText)=='table','textReader: SCN.args[1] must be string or table of text')
            showingText=SCN.args[1]
        end
    end

    textBox.font=SCN.args[2] or 20
    textBox:setTexts(showingText)
    textBox:reset()

    BG.set(SCN.args[3])
end

function scene.wheelMoved(_,y)
    WHEELMOV(y)
end

function scene.keyDown(key)
    if key=='up' then
        textBox:scroll(5,0)
    elseif key=='down' then
        textBox:scroll(-5,0)
    elseif key=='pageup' then
        textBox:scroll(20,0)
    elseif key=='pagedown' then
        textBox:scroll(-20,0)
    elseif key=='escape' then
        SCN.back('none')
    end
end

scene.widgetList={
    textBox,
    WIDGET.new{type='button',name='back',x=1140,y=640,w=170,h=80,fontSize=60,fontType='symbols',text=CHAR.icon.back,code=WIDGET.c_backScn('none')},
}

return scene
