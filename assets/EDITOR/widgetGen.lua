local originalImageResetFunc=WIDGET._prototype.image.reset
-- Make the blank widget first
WIDGET.newClass('blank')
WIDGET.setDefaultOption{
    -- Blank widget basically contain nothing, just for decorating
    blank={
        alignX='left',alignY='up',
        buildArgs={'name','pos','x','y','w','h'},
        draw=function(self)
            GC.setColor(1,1,1)
            GC.setLineWidth(10)
            GC.rectangle('line',self._x,self._y,self.w,self.h)
        end,
        isAbove=function(self,x,y)
            return (
                x>self._x and
                y>self._y and
                x<self._x+self.w and
                y<self._y+self.h
            )
        end
    },
    -- Add Widgets.image:isAbove because...
    -- MrZ doesn't want to implement one
    image={
        reset=function(self)
            originalImageResetFunc(self)

            self.h=self._scaleH*self._image:getHeight()
            self.w=self._scaleW*self._image:getWidth ()

            self._left=self._x-self.w*(
                self.alignX=='left'   and 0   or
                self.alignX=='center' and 0.5 or 1 -- right
            )
            self._top=self._y-self.h*(
                self.alignY=='up'     and 0   or
                self.alignY=='center' and 0.5 or 1 -- down
            )
        end,
        isAbove=function(self,x,y)
            -- Check border
            -- love.graphics.rectangle('line',self._left,self._top,self.w,self.h)
            -- love.graphics.flushBatch()
            -- love.graphics.present()

            -- Find the boundaries, based on top-left of widget when it sets to center-center
            if (
                x>self._left and
                x<self._left+self.w and
                y>self._top  and
                y<self._top +self.h
            ) then
                return true
            end
        end
    }
}

local baseWidgetDict
do
    local checkBoxR,switchR=false,false
    local sliderR,slider_fillR,slider_progressR,selectorR=0,0,0,0
    baseWidgetDict={
        text           ={type='text'           ,x=0,y=0,            text ='My internal name is text'           ,},
        image          ={type='image'          ,x=0,y=0,w=300,h=300,image='placeholder'                        ,},
        button         ={type='button'         ,x=0,y=0,w=300,h=300,text ='My internal name is button'         ,cornerR=0},
        button_fill    ={type='button_fill'    ,x=0,y=0,w=300,h=300,text ='My internal name is button_fill'    ,cornerR=0},
        button_invis   ={type='button_invis'   ,x=0,y=0,w=300,h=300,text ='My internal name is button_invis'   ,cornerR=0},
        checkBox       ={type='checkBox'       ,x=0,y=0,            text ='My internal name is checkBox'       ,disp=function() return checkBoxR        end,code=function(v) checkBoxR       =not checkBoxR end,},
        switch         ={type='switch'         ,x=0,y=0,            text ='My internal name is switch'         ,disp=function() return switchR          end,code=function(v) switchR         =not switchR   end,},
        slider         ={type='slider'         ,x=0,y=0,w=300,      text ='My internal name is slider'         ,disp=function() return sliderR          end,code=function(v) sliderR         =v end,axis={0,100,10}},
        slider_fill    ={type='slider_fill'    ,x=0,y=0,w=300,      text ='My internal name is slider_fill'    ,disp=function() return slider_fillR     end,code=function(v) slider_fillR    =v end,axis={0,100   }},
        slider_progress={type='slider_progress',x=0,y=0,w=300,      text ='My internal name is slider_progress',disp=function() return slider_progressR end,code=function(v) slider_progressR=v end},
        selector       ={type='selector'       ,x=0,y=0,w=300,      text ='My internal name is selector'       ,disp=function() return selectorR        end,code=function(v) selectorR       =v end,list={0,1,2,3,4,5}},
        inputBox       ={type='inputBox'       ,x=0,y=0,w=300,h=300,text ='My internal name is inputBox'       ,},
        textBox        ={type='textBox'        ,x=0,y=0,w=300,h=300,},
        listBox        ={type='listBox'        ,x=0,y=0,w=300,h=300,                                            drawFunc=function() FONT.set(25) GC.safePrint('My internal name is listbox',5,0) end},
        blank          ={type='blank'          ,x=0,y=0,w=300,h=300,},
    }
end

return setmetatable({},{
    __index=function(_,k)
        local w=WIDGET.new(TABLE.copy(baseWidgetDict[k]))

        if     k=='listBox' then w:setList {1,2,3,4,5}
        elseif k=='textBox' then w:setTexts{'My internal name is textBox'}
        end
        w.x,w.y=SCR.w0/2,SCR.h0/2
        w:reset()
        
        return w
    end,
    __metatable=true
})