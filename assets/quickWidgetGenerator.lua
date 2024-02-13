-- Make the blank widget first
-- Blank widget basically contain nothing, just for decorating
WIDGET.newClass('blank')
WIDGET.setDefaultOption{
    blank={
        alignX='left',alignY='up',
        buildArgs={'name','pos','x','y','w','h'},
        draw=function(self)
            GC.setColor(1,1,1)
            GC.setLineWidth(10)
            GC.rectangle('line',self._x,self._y,self.w,self.h)
        end
    }
}

local baseWidgetDict={
    text           ={type='text'           ,x=0,y=0,            text ='My internal name is text'           ,},
    image          ={type='image'          ,x=0,y=0,w=300,h=300,image='placeholder'                        ,keepAspectRatio=false},
    button         ={type='button'         ,x=0,y=0,w=300,h=300,text ='My internal name is button'         ,cornerR=0},
    button_fill    ={type='button_fill'    ,x=0,y=0,w=300,h=300,text ='My internal name is button_fill'    ,cornerR=0},
    button_invis   ={type='button_invis'   ,x=0,y=0,w=300,h=300,text ='My internal name is button_invis'   ,cornerR=0},
    checkBox       ={type='checkBox'       ,x=0,y=0,            text ='My internal name is checkBox'       ,disp=function() return 0 end,},
    switch         ={type='switch'         ,x=0,y=0,            text ='My internal name is switch'         ,disp=function() return 0 end,},
    slider         ={type='slider'         ,x=0,y=0,w=300,      text ='My internal name is slider'         ,disp=function() return 0 end,},
    slider_fill    ={type='slider_fill'    ,x=0,y=0,w=300,      text ='My internal name is slider_fill'    ,disp=function() return 0 end,},
    slider_progress={type='slider_progress',x=0,y=0,w=300,      text ='My internal name is slider_progress',disp=function() return 0 end,},
    selector       ={type='selector'       ,x=0,y=0,w=300,      text ='My internal name is selector'       ,disp=function() return 0 end,list={0,1,2,3,4,5}},
    inputBox       ={type='inputBox'       ,x=0,y=0,w=300,h=300,text ='My internal name is inputBox'       ,},
    textBox        ={type='textBox'        ,x=0,y=0,w=300,h=300,},
    listBox        ={type='listBox'        ,x=0,y=0,w=300,h=300,                                            drawFunc=function() FONT.set(25) GC.safePrint('My internal name is listbox',5,0) end},
    blank          ={type='blank'          ,x=0,y=0,w=300,h=300,},
}

return setmetatable({},{
    __index=function(_,k)
        local w=WIDGET.new(TABLE.copy(baseWidgetDict[k]))

        if     k=='listBox' then w:setList {1,2,3,4,5}
        elseif k=='textBox' then w:setTexts{'My internal name is textBox'}
        end

        w.x,w.y=SCR.w0/2,SCR.h0/2

        w:reset()
        w:update(1234568789)

        return w
    end,
    __metatable=true
})