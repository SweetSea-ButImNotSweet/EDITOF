local gc_line,gc_rectangle,gc_circle=GC.line,GC.rectangle,GC.circle
local gc_setLineWidth,gc_setColor=GC.setLineWidth,GC.setColor
local gc_getWidth,gc_getHeight=GC.getWidth,GC.getHeight
local gc_replaceTransform=GC.replaceTransform

local dumpWidget=require('assets.dumpWidget')

local mo,kb=love.mouse,love.keyboard
local table_clear,table_copy=TABLE.clear,TABLE.copy
local table_insert,table_remove=table.insert,table.remove
local floor,ceil,wrap,max=math.floor,math.ceil,MATH.wrap,math.max

local widgetList={}         -- All widgets will be drawn, updated,...
                            -- in order from the beginning to the end of the list
local selectedWidget
local selectedWidgetID
local hoveringWidget        -- hoveringWidget != selectedWidget
local hoveringWidgetID
local updatedBeforeMoving=false

local undoList={}           -- Format: undoList={{},{w1},{w1,w2},{w1,w2,w3},...}
local redoList={}

local gridEnabled=true
local girdOpacity=0.1
local cellSize=10

local scene={}

local function drawGirdAndSafeBorder()
    -- + ------- X
    -- | +++++++
    -- | +++++++
    -- Y +++++++

    gc_replaceTransform(SCR.origin)
    local scr_origin_w,scr_origin_h=gc_getWidth(),gc_getHeight()

    gc_setColor(1,1,1,girdOpacity)
    gc_setLineWidth(1)
    -- From 0 to X
    for ix=1,floor(scr_origin_w/cellSize) do
        gc_line(cellSize*ix,0,cellSize*ix,scr_origin_h)
    end
    -- From 0 to Y
    for iy=1,floor(scr_origin_h/cellSize) do
        gc_line(0,cellSize*iy,scr_origin_w,cellSize*iy)
    end

    -- Draw safe border
    gc_replaceTransform(SCR.xOy)
    gc_setLineWidth(20)
    gc_setColor(1,1,1,girdOpacity+0.1)
    gc_rectangle('line',0,0,SCR.w0,SCR.h0)
end

local function getSnappedLocation(x,y)
    if not gridEnabled then return x,y end

    local halfCellSize=cellSize/2
    if x%cellSize>halfCellSize
        then x=ceil (x/cellSize)*cellSize
        else x=floor(x/cellSize)*cellSize
    end
    if y%cellSize>halfCellSize
        then y=ceil (y/cellSize)*cellSize
        else y=floor(y/cellSize)*cellSize
    end

    return x,y
end

local function dumpAllWidgets()
    local output={}
    for _,w in pairs(widgetList) do
        output[#output+1]=dumpWidget(w,'table')
    end
    return output
end

local function updateUndoList()
    undoList[#undoList+1]=dumpAllWidgets()
    table_clear(redoList)
end

local function addWidget(w,reason)
    local w=w or selectedWidget
    if not TABLE.findAll(widgetList,w) then
        if reason~='undo' and reason~='redo' then
            updateUndoList()
        end

        table_insert(widgetList,1,w)
    end
end

local function clearAllWidgets()
    hoveringWidget,hoveringWidgetID,selectedWidget,selectedWidgetID=nil
    TABLE.safeClearR(widgetList,{'[Cc]olor','axis'},true,true)
    collectgarbage()    -- Collecting all garbages that released from all widgets.
end

local function switchSelectedWidget(d)
    selectedWidgetID=wrap(
        selectedWidgetID and (selectedWidgetID+(d=='next' and -1 or d=='prev' and 1 or 0) or 0) or
        (d=='next' and #widgetList or 1),
        1,#widgetList
    )
    selectedWidget=widgetList[selectedWidgetID]
end

function scene.enter()
    BlackCover.playAnimation('fadeOut',0.25)
    if SCN.prev=='newWidget' and SCN.args[1] then
        TEXT:add{
            text=string.format('%s - %s',SCN.args[1],SCN.args[2].type),
            x=SCR.w0/2,y=SCR.h0/2,
            duration=1,
            inPoint=0.25,outPoint=0.25
        }
        selectedWidget=SCN.args[2]
        selectedWidgetID=1
        addWidget()
    end
end

function scene.mouseDown(x,y,id)
    local x,y=getSnappedLocation(x,y)

    if id==1 then       -- Add the widget into widgetList
        if selectedWidget and not selectedWidget:isAbove(x,y) then
            selectedWidget,selectedWidgetID=nil
        end
        if hoveringWidget then
            selectedWidget,selectedWidgetID=hoveringWidget,hoveringWidgetID
            hoveringWidget,hoveringWidgetID=nil
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
    local x,y=getSnappedLocation(x,y)

    if mo.isDown(1) and selectedWidget then
        if not updatedBeforeMoving then
            updateUndoList()
            updatedBeforeMoving=true
        end
        selectedWidget.x=selectedWidget.x+dx
        selectedWidget.y=selectedWidget.y+dy
        selectedWidget:reset()
    else
        for id,w in pairs(widgetList) do
            if w:isAbove(x,y) then
                if selectedWidgetID~=id then
                    hoveringWidget  =w
                    hoveringWidgetID=id
                end
                return
            end
        end
        hoveringWidget,hoveringWidgetID=nil
    end
end

function scene.mouseUp()
    if selectedWidget then
        selectedWidget.x,selectedWidget.y=getSnappedLocation(selectedWidget.x,selectedWidget.y)
        selectedWidget:reset()
    end
    updatedBeforeMoving=false
end

function scene.wheelMoved(_,y)
    WHEELMOV(y,'=','-')
end

function scene.keyDown(key)
    if selectedWidget then
        local diff=(gridEnabled and cellSize) or 1
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
            if selectedWidget.x then selectedWidget.x=selectedWidget.x+dx end
            if selectedWidget.y then selectedWidget.y=selectedWidget.y+dy end
            if selectedWidget.w then selectedWidget.w=selectedWidget.w+dw end
            if selectedWidget.h then selectedWidget.h=selectedWidget.h+dh end

            selectedWidget:reset()
            return true
        end
    end

    -- Switch selected widgets
    if     key=='q' then switchSelectedWidget('prev')
    elseif key=='e' then switchSelectedWidget('next')
    -- Zoom the cell size of grid
    elseif kb.isDown('=','-','kp+','kp-') then
        if     (key=='=' or key=='kp+') then cellSize=cellSize+1
        elseif (key=='-' or key=='kp-') then cellSize=max(2,cellSize-1) end
        TEXT:clear()
        TEXT:add{
            text='Cell size of gird: '..cellSize,
            x=SCR.w0/2,y=SCR.h0/2,
        }
    -- Undo, Redo | Look at the beginning of this file to know
    --            | the structure of undoList and redoList
    -- uL[i]=rL[i]={type='sea',x=25,y=52,w=100,...}
    elseif kb.isDown('lctrl','rctrl') then
        if     key=='z' then
            local uL=table_remove(undoList)
            if not uL then return end

            redoList[#redoList+1]=dumpAllWidgets()
            clearAllWidgets()
            for i=#uL,1,-1 do
                addWidget(WIDGET.new(table_copy(uL[i])),'undo')
            end
            return
        elseif key=='y' then
            local rL=table_remove(redoList)
            if not rL then return end

            undoList[#undoList+1]=dumpAllWidgets()
            clearAllWidgets()
            for i=#rL,1,-1 do
                addWidget(WIDGET.new(table_copy(rL[i])),'redo')
            end
            return
        elseif key=='delete' then
            clearAllWidgets()
        elseif key=='return' then SCN.go('_console') end
    -- Clear, Clear all, Interactive, View widget's detail
    elseif key=='escape' then
        if   selectedWidget
        then selectedWidget,selectedWidgetID=nil
        else TEXT:clear() end
    elseif key=='`' then
        SCN.go('newWidget','none')
        BlackCover.playAnimation('fadeIn',0.5,0.7)
    elseif key=='delete' and selectedWidget then
        updateUndoList()
        table_remove(widgetList,selectedWidgetID)
        selectedWidget,selectedWidgetID=nil
    elseif key=='i' then
        SCN.scenes.interactive.widgetList={} --Empty the old widget list
        local interactiveWidgetList=SCN.scenes.interactive.widgetList
        TABLE.clear(interactiveWidgetList)
        for _,w in pairs(widgetList) do
            table_insert(interactiveWidgetList,w)
        end
        SCN.go('interactive')
    elseif key=='v' then
        SCN.go('textViewer','none',dumpWidget(selectedWidget,'string'))
    -- elseif key=='b' then
    --     SCN.go('textViewer','none',TABLE.dump(undoList))
    -- elseif key=='n' then
    --     SCN.go('textViewer','none',TABLE.dump(redoList))
    end
end

function scene.draw()
    drawGirdAndSafeBorder()

    gc_setColor(1,1,1,1)
    -- Draw all widgets
    for i=#widgetList,1,-1 do widgetList[i]:draw() end

    -- Draw the center circle
    if selectedWidget then
        gc_setColor(0,0,0,0.5)
        gc_circle('fill',selectedWidget._x,selectedWidget._y,40)
        gc_setColor(1,1,1,1)
        gc_circle('fill',selectedWidget._x,selectedWidget._y,25)
        gc_setColor(.1,1,.5,1)
        gc_circle('fill',selectedWidget._x,selectedWidget._y,10)
    end
    if hoveringWidget then
        gc_setColor(1,1,1,1)
        gc_circle('fill',hoveringWidget._x,hoveringWidget._y,25)
        gc_setColor(.1,.5,1,1)
        gc_circle('fill',hoveringWidget._x,hoveringWidget._y,10)
    end

    BlackCover.draw()
end

function scene.update(dt)
    for _,w in pairs(widgetList) do w:update(dt) end
    if selectedWidget then selectedWidget:update(dt) end
    BlackCover.update(dt)
end

return scene