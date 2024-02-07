local kb =love.keyboard
local gc =love.graphics
local min,max=math.min,math.max

local baseWidgetIDlist={
    ['1']='text',
    ['2']='image',
    ['3']='button',
    ['4']='button_fill',
    ['5']='button_invis',
    ['6']='checkBox',
    ['7']='switch',
    ['8']='slider',
    ['9']='slider_fill',
    ['0']='slider_progress',
    ['!']='selector',
    ['@']='inputBox',
    ['#']='textBox',
    ['$']='listBox',
}

local newWidget
do
    local baseWidgetDict={
        text           ={type='text'           ,x=0,y=0,            text ='Example of textbox'        ,},
        image          ={type='image'          ,x=0,y=0,w=500,h=100,image='placeholder'               ,keepAspectRatio=false},
        button         ={type='button'         ,x=0,y=0,w=500,h=100,text ='Example of button'         ,cornerR=0},
        button_fill    ={type='button_fill'    ,x=0,y=0,w=500,h=100,text ='Example of button_fill'    ,cornerR=0},
        button_invis   ={type='button_invis'   ,x=0,y=0,w=500,h=100,text ='Example of button_invis'   ,cornerR=0},
        checkBox       ={type='checkBox'       ,x=0,y=0,            text ='Example of checkBox'       ,disp=function() return 0 end,},
        switch         ={type='switch'         ,x=0,y=0,            text ='Example of switch'         ,disp=function() return 0 end,},
        slider         ={type='slider'         ,x=0,y=0,w=500,      text ='Example of slider'         ,disp=function() return 0 end,},
        slider_fill    ={type='slider_fill'    ,x=0,y=0,w=500,      text ='Example of slider_fill'    ,disp=function() return 0 end,},
        slider_progress={type='slider_progress',x=0,y=0,w=500,      text ='Example of slider_progress',disp=function() return 0 end,},
        selector       ={type='selector'       ,x=0,y=0,w=500,      text ='Example of selector'       ,disp=function() return 0 end,list={0,1,2,3,4,5}},
        inputBox       ={type='inputBox'       ,x=0,y=0,w=500,h=100,text ='Example of inputBox'       ,},
        textBox        ={type='textBox'        ,x=0,y=0,w=500,h=100,                                   },
        listBox        ={type='listBox'        ,x=0,y=0,w=500,h=100,                                   drawFunc=function() FONT.set(25) GC.safePrint('Example of listbox',5,0) end,},
    }

    newWidget=setmetatable({},{
        __index=function(_,k)
            local w=WIDGET.new(TABLE.copy(baseWidgetDict[k]))
            if k=='listBox' then w:setList{1,2,3,4,5} end
            return w
        end,
        __metatable=true
    })
end

local introduction_text=[[
To add a widget, press the number key that corresponds to the widget.
To return, hit Tab or ESC.

To choose a key that corresponds to !, @, #, $, and %,
hold down the Shift key and press any number from 1 to 5.
]]
local keyLayout_text=[[
1 - text                   6 - checkBox           ! - selector
2 - image                  7 - switch             @ - inputBox
3 - button                 8 - slider             # - textBox
4 - button_fill            9 - slider_fill        $ - listBox
5 - button_invis           0 - slider_progress
]]

-- For animation
local framePassed
local timeToQuit

local backArg

local scene={}

function scene.enter()
    backArg=nil

    framePassed=0 -- For animation
end

function scene.leave()
    -- For animation
    scene.widgetList[1].color={0,0,0,0}
    scene.widgetList[2].color={0,0,0,0}
end

function scene.keyDown(key)
    if key=='escape' or key=='tab' then
        timeToQuit=true -- SCN.back()
    end
end

function scene.keyUp(key,isRep)
    -- From 0 to 9, !, @, #, $, %
    if key:sub(1,2)=='kp' then key=key:sub(3) end
    if kb.isDown('lshift') or kb.isDown('rshift') then
        key=STRING.shift(key)
    end

    local selectedWidgetID=baseWidgetIDlist[key]
    if selectedWidgetID then
        -- backArg={key,WIDGET.new(TABLE.copy(baseWidgetDict[selectedWidgetID]))}
        backArg={key,newWidget[selectedWidgetID]}
        timeToQuit=true
    end
end

function scene.update(dt)
    -- For animation
    if timeToQuit then
        if backArg then framePassed=-1e99 else framePassed=framePassed-dt end
        if framePassed<0 then
            timeToQuit=false
            if backArg then
                SCN.back('none',unpack(backArg))
            else
                SCN.back('none')
            end
        end
    elseif framePassed<0.25 then
        framePassed=framePassed+dt
    end

    scene.widgetList[1].color={1,1,1,min(framePassed/0.25,1)}
    scene.widgetList[2].color={1,1,1,min(framePassed/0.25,1)}
end

-- Only drawing the black overlay
function scene.draw()
    SCN.scenes.main:draw()
end

scene.widgetList={
    {type='text',pos={0.5,0.5},y=-120,color={0,0,0,0},text=introduction_text},
    {type='text',pos={0.5,0.5},y= 140,color={0,0,0,0},text=keyLayout_text,fontType='_mono',fontSize=25},
}

return scene