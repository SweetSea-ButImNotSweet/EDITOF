local gc_circle,gc_setColor=GC.circle,GC.setColor

local dumpWidget=require('assets.EDITOR.dumpWidget')

local max=math.max
local table_copy=TABLE.copy
local mo,kb=love.mouse,love.keyboard
local table_insert,table_remove=table.insert,table.remove

local scene={}

function scene.enter()
    BlackCover.playAnimation('fadeOut',0.25)
    if SCN.prev=='newWidget' and SCN.args[1] then
        TEXT:add{
            text=string.format('%s - %s',SCN.args[1],SCN.args[2].type),
            x=SCR.w0/2,y=SCR.h0/2,
            duration=1,
            inPoint=0.25,outPoint=0.25
        }
        EDITOR.selectedWidget=SCN.args[2]
        EDITOR.selectedWidgetID=1
        EDITORfunc.addWidget()
    end
end

function scene.mouseDown(x,y,id)
    local x,y=EDITORfunc.getSnappedLocation(x,y)

    if id==1 then       -- Add the widget into widgetList
        if EDITOR.selectedWidget and not EDITOR.selectedWidget:isAbove(x,y) then
            EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
        end
        if EDITOR.hoveringWidget then
            EDITOR.selectedWidget,EDITOR.selectedWidgetID=EDITOR.hoveringWidget,EDITOR.hoveringWidgetID
            EDITOR.hoveringWidget,EDITOR.hoveringWidgetID=nil
        end
    elseif id==3 then
        TEXT:clear()
        TEXT:add{
            text=string.format("%s, %s",x,y),
            x=SCR.w0/2,y=SCR.h0/2,
        }
    end
end

function scene.mouseMove(x,y,dx,dy)
    local x,y=EDITORfunc.getSnappedLocation(x,y)

    if mo.isDown(1) and EDITOR.selectedWidget then
        if not EDITOR.updatedBeforeMoving then
            EDITORfunc.updateUndoList()
            EDITOR.updatedBeforeMoving=true
        end
        EDITOR.selectedWidget.x=EDITOR.selectedWidget.x+dx
        EDITOR.selectedWidget.y=EDITOR.selectedWidget.y+dy
        EDITOR.selectedWidget:reset()
    else
        for id,w in pairs(EDITOR.widgetList) do
            if w:isAbove(x,y) then
                if EDITOR.selectedWidgetID~=id then
                    EDITOR.hoveringWidget  =w
                    EDITOR.hoveringWidgetID=id
                end
                return
            end
        end
        EDITOR.hoveringWidget,EDITOR.hoveringWidgetID=nil
    end
end

function scene.mouseUp()
    if EDITOR.selectedWidget then
        EDITOR.selectedWidget.x,EDITOR.selectedWidget.y=EDITORfunc.getSnappedLocation(EDITOR.selectedWidget.x,EDITOR.selectedWidget.y)
        EDITOR.selectedWidget:reset()
    end
    EDITOR.updatedBeforeMoving=false
end

function scene.wheelMoved(_,y)
    WHEELMOV(y,'=','-')
end

function scene.keyDown(key)
    if EDITOR.selectedWidget then
        local diff=(EDITOR.gridEnabled and EDITOR.cellSize) or 1
        local dx,dy,dw,dh,df=0,0,0,0,0

        --     Moving widget                         Resizing widget
        if     key=='a' then dx=dx-diff       elseif key=='j' then dw=dw-diff
        elseif key=='d' then dx=dx+diff       elseif key=='l' then dw=dw+diff
        elseif key=='w' then dy=dy-diff       elseif key=='i' then dh=dh+diff
        elseif key=='s' then dy=dy+diff       elseif key=='k' then dh=dh-diff

        --     Font size
        elseif key=='u' then df=df-diff
        elseif key=='o' then df=df+diff
        end

        if dx~=0 or dy~=0 or dw~=0 or dh~=0 or df~=0 then
            if EDITOR.selectedWidget.x then EDITOR.selectedWidget.x=EDITOR.selectedWidget.x+dx end
            if EDITOR.selectedWidget.y then EDITOR.selectedWidget.y=EDITOR.selectedWidget.y+dy end
            if EDITOR.selectedWidget.w then EDITOR.selectedWidget.w=EDITOR.selectedWidget.w+dw end
            if EDITOR.selectedWidget.h then EDITOR.selectedWidget.h=EDITOR.selectedWidget.h+dh end

            EDITOR.selectedWidget:reset()
            return true
        end
    end

    -- Switch selected widgets
    if     key=='q' then EDITORfunc.switchSelectedWidget('prev')
    elseif key=='e' then EDITORfunc.switchSelectedWidget('next')
    -- Zoom the cell size of grid
    elseif kb.isDown('=','-','kp+','kp-') then
        if     (key=='=' or key=='kp+') then EDITOR.cellSize=EDITOR.cellSize+1
        elseif (key=='-' or key=='kp-') then EDITOR.cellSize=max(2,EDITOR.cellSize-1) end
        TEXT:clear()
        TEXT:add{
            text='Cell size of gird: '..EDITOR.cellSize,
            x=SCR.w0/2,y=SCR.h0/2,
        }
    -- Undo, Redo | Look at the beginning of this file to know
    --            | the structure of undoList and redoList
    -- uL[i]=rL[i]={type='sea',x=25,y=52,w=100,...}
    elseif kb.isDown('lctrl','rctrl') then
        if     key=='z' then
            local uL=table_remove(EDITOR.undoList)
            if not uL then return end

            EDITOR.redoList[#EDITOR.redoList+1]=EDITORfunc.dumpAllWidgets()
            EDITORfunc.clearAllWidgets()
            for i=#uL,1,-1 do
                EDITORfunc.addWidget(WIDGET.new(table_copy(uL[i])),'undo')
            end
            return
        elseif key=='y' then
            local rL=table_remove(EDITOR.redoList)
            if not rL then return end

            EDITOR.undoList[#EDITOR.undoList+1]=EDITORfunc.dumpAllWidgets()
            EDITORfunc.clearAllWidgets()
            for i=#rL,1,-1 do
                EDITORfunc.addWidget(WIDGET.new(table_copy(rL[i])),'redo')
            end
            return
        elseif key=='delete' then
            EDITORfunc.clearAllWidgets()
        elseif key=='return' then SCN.go('_console') end
    -- Clear, Clear all, Interactive, View widget's detail
    elseif key=='escape' then
        if   EDITOR.selectedWidget
        then EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
        else TEXT:clear() end
    elseif key=='`' then
        SCN.go('newWidget','none')
        BlackCover.playAnimation('fadeIn',0.5,0.7)
    elseif key=='delete' and EDITOR.selectedWidget then
        EDITORfunc.updateUndoList()
        table_remove(EDITOR.widgetList,EDITOR.selectedWidgetID)
        EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
    elseif key=='i' then
        SCN.scenes.interactive.widgetList={} --Empty the old widget list
        local interactiveWidgetList=SCN.scenes.interactive.widgetList
        TABLE.clear(interactiveWidgetList)
        for _,w in pairs(EDITOR.widgetList) do
            table_insert(interactiveWidgetList,w)
        end
        SCN.go('interactive')
    elseif key=='v' then
        SCN.go('textViewer','none',dumpWidget(EDITOR.selectedWidget,'string'))
    -- elseif key=='b' then
    --     SCN.go('textViewer','none',TABLE.dump(EDITOR.undoList))
    -- elseif key=='n' then
    --     SCN.go('textViewer','none',TABLE.dump(EDITOR.redoList))
    end
end

function scene.draw()
    EDITORfunc.drawGirdAndSafeBorder()

    gc_setColor(1,1,1,1)
    -- Draw all widgets
    for i=#EDITOR.widgetList,1,-1 do EDITOR.widgetList[i]:draw() end

    -- Draw the center circle
    if EDITOR.selectedWidget then
        gc_setColor(0,0,0,0.5)
        gc_circle('fill',EDITOR.selectedWidget._x,EDITOR.selectedWidget._y,40)
        gc_setColor(1,1,1,1)
        gc_circle('fill',EDITOR.selectedWidget._x,EDITOR.selectedWidget._y,25)
        gc_setColor(.1,1,.5,1)
        gc_circle('fill',EDITOR.selectedWidget._x,EDITOR.selectedWidget._y,10)
    end
    if EDITOR.hoveringWidget then
        gc_setColor(1,1,1,1)
        gc_circle('fill',EDITOR.hoveringWidget._x,EDITOR.hoveringWidget._y,25)
        gc_setColor(.1,.5,1,1)
        gc_circle('fill',EDITOR.hoveringWidget._x,EDITOR.hoveringWidget._y,10)
    end

    BlackCover.draw()
end

function scene.update(dt)
    for _,w in pairs(EDITOR.widgetList) do w:update(dt) end
    if EDITOR.selectedWidget then EDITOR.selectedWidget:update(dt) end
    BlackCover.update(dt)
end

return scene