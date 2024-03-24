local dumpWidget=require('assets.EDITOR.dumpWidget')


local gc_circle,gc_setColor=GC.circle,GC.setColor
local max=math.max
local table_copy=TABLE.copy
local mo,kb=love.mouse,love.keyboard

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
        EDITOF.addWidget()
    end
end

function scene.mouseDown(x,y,id)
    local x,y=EDITOF.getSnappedLocation(x,y)

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
    local x,y=EDITOF.getSnappedLocation(x,y)

    if mo.isDown(1) and EDITOR.selectedWidget then
        local selectedWidget=EDITOR.selectedWidget
        if not EDITOR.updatedBeforeMoving then
            EDITOF.updateUndoList()
            EDITOR.updatedBeforeMoving=true
        end
        selectedWidget.x=selectedWidget.x+dx
        selectedWidget.y=selectedWidget.y+dy
        selectedWidget:reset()
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
        EDITOR.selectedWidget.x,EDITOR.selectedWidget.y=EDITOF.getSnappedLocation(EDITOR.selectedWidget.x,EDITOR.selectedWidget.y)
        EDITOR.selectedWidget:reset()
    end
    EDITOR.updatedBeforeMoving=false
end

function scene.wheelMoved(_,y)
    WHEELMOV(y,'=','-')
end

function scene.keyDown(key)
    if EDITOR.selectedWidget then
        if EDITOF.selectedWidget_onKeyDown(key) then return end
    end

    -- Switch selected widgets
    if     key=='q' then EDITOF.switchSelectedWidget('prev')
    elseif key=='e' then EDITOF.switchSelectedWidget('next')
    -- Zoom the cell size of grid
    elseif kb.isDown('=','-','kp+','kp-') then
        if     (key=='=' or key=='kp+') then EDITOR.cellSize=EDITOR.cellSize+1
        elseif (key=='-' or key=='kp-') then EDITOR.cellSize=max(2,EDITOR.cellSize-1) end
        TEXT:clear()
        TEXT:add{
            text='Cell size of gird: '..EDITOR.cellSize,
            x=SCR.w0/2,y=SCR.h0/2,
        }
    -- Clear, Clear all, Undo, Redo
    elseif key=='delete' and EDITOR.selectedWidget then EDITOF.removeSelectedWidget()
    elseif kb.isCtrlDown() then
        if     key=='z'      then EDITOF.undo()
        elseif key=='y'      then EDITOF.redo()
        elseif key=='delete' then EDITOF.removeAllWidgets()
        elseif key=='return' then SCN.go('_console') end
    -- Unselect widget
    elseif key=='escape' then
        if   EDITOR.selectedWidget
        then EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
        else TEXT:clear() end
    -- New widget, interactive mode and view widget's detail.
    elseif key=='`' then
        SCN.go('newWidget','none')
        BlackCover.playAnimation('fadeIn',0.5,0.7)
    elseif key=='space' then
        SCN.scenes.interactive.widgetList={} --Empty the old widget list
        SCN.scenes.interactive.widgetList=table_copy(EDITOR.widgetList,0)
        collectgarbage()
        SCN.go('interactive')
    elseif key=='v' then
        SCN.go('textViewer','none',dumpWidget(EDITOR.selectedWidget,'string'))
    end
end

function scene.draw()
    EDITOF.drawGirdAndSafeBorder()

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