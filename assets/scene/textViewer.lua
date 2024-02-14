local showingText
local textBox=WIDGET.new{type='textBox',name='texts',x=30,y=45,w=1000,h=640,fontSize=20,fixContent=true}
local copyButton
copyButton=WIDGET.new{
    type='button',name='back',x=1140,y=540,w=170,h=80,fontSize=60,fontType='symbols',text=CHAR.icon.copy,
    code=function()
        love.system.setClipboardText(table.concat(showingText))

        copyButton.color='lG'
        copyButton.text=CHAR.icon.check_circ
        copyButton:reset()
        end
    }
local fontButton
fontButton=WIDGET.new{
    type='button',name='back',x=1140,y=440,w=170,h=80,fontSize=40,fontType='main',text='FONT',
    code=function()
        if textBox.fontType=='main' then
            textBox   .fontType='_mono'
            fontButton.fontType='main'
        else
            textBox   .fontType='main'
            fontButton.fontType='_mono'
        end
        textBox   :reset()
        fontButton:reset()
    end
}
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
            assert(type(SCN.args[1])=='table','textViewer: SCN.args[1] must be string or table of text')
            showingText=SCN.args[1]
        end
    else showingText={'No text!'} end

    textBox.font=SCN.args[2] or 20
    textBox:setTexts(showingText)
    textBox:reset()

    BG.set(SCN.args[3])

    copyButton.color='LL'
    copyButton.text=CHAR.icon.copy
    copyButton:reset()
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
    copyButton,
    fontButton
}

return scene
