local gc_line,gc_rectangle,gc_circle=GC.line,GC.rectangle,GC.circle
local gc_setLineWidth,gc_setColor=GC.setLineWidth,GC.setColor
local gc_getWidth,gc_getHeight=GC.getWidth,GC.getHeight
local gc_replaceTransform=GC.replaceTransform

local getDelta=love.timer.getDelta
local floor,ceil,max,clamp=math.floor,math.ceil,math.max,MATH.clamp

local nextWidgetID=1        -- For generated widgets in the future
local widgetList={} -- Format: ID=Widget
local undoList={}
local redoList={}

local selectedWidget
local gridEnabled=true
local girdOpacity=0.1
local cellSize=10

local scene={}

local function returnWidgetUnderMouseCursor(x,y,returnID)
    for id,w in pairs(widgetList) do
        if w:isAbove(x,y) then
            if returnID then return id else return w end
        end
    end
end

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
    if x%cellSize>halfCellSize then x=ceil(x/cellSize)*cellSize else x=floor(x/cellSize)*cellSize end
    if y%cellSize>halfCellSize then y=ceil(y/cellSize)*cellSize else y=floor(y/cellSize)*cellSize end

    return x,y
end

function scene.enter()
    BlackCover.playAnimation('fadeOut',0.25)
    if SCN.prev=='newWidget' and SCN.args[1] then
        TEXT:add{
            text=string.format("%s - %s",SCN.args[1],SCN.args[2].type),
            x=SCR.w0/2,y=SCR.h0/2,
            duration=1,
            inPoint=0.25,outPoint=0.25
        }
        selectedWidget=SCN.args[2]
        table.insert(widgetList,nextWidgetID,selectedWidget)
    end
end

function scene.mouseDown(x,y,id)
    if id==3 then
        TEXT:clear()
        TEXT:add{
            text=string.format("%s, %s",x,y),
            x=SCR.w0/2,y=SCR.h0/2,
        }
    end
end

function scene.mouseUp(x,y)
end

function scene.wheelMoved(_,y)
    WHEELMOV(y,'=','-')
end

function scene.keyDown(key,isRep)
    REQUEST_BREAK()
    if selectedWidget then
        local diff=(gridEnabled and cellSize) or 1
        local dx,dy,dw,dh=0,0,0,0

        --     Moving widget                         Resizing widget
        if     key=='a' then dx=dx-diff       elseif key=='j' then dw=dw-diff
        elseif key=='d' then dx=dx+diff       elseif key=='l' then dw=dw+diff
        elseif key=='w' then dy=dy-diff       elseif key=='i' then dh=dh-diff
        elseif key=='s' then dy=dy+diff       elseif key=='k' then dh=dh+diff
        end

        if dx~=0 or dy~=0 or dw~=0 or dh~=0 then
            if selectedWidget.x then selectedWidget.x=selectedWidget.x+dx end
            if selectedWidget.y then selectedWidget.y=selectedWidget.y+dy end
            if selectedWidget.w then selectedWidget.w=selectedWidget.w+dw end
            if selectedWidget.h then selectedWidget.h=selectedWidget.h+dh end

            selectedWidget:reset()
            return true
        end
    end

    if     (key=='=' or key=='kp+') then
        cellSize=cellSize+1
        TEXT:clear()
        TEXT:add{
            text='Cell size of gird: '..cellSize,
            x=SCR.w0/2,y=SCR.h0/2,
        }
    elseif (key=='-' or key=='kp-') then
        cellSize=max(2,cellSize-1)
        TEXT:clear()
        TEXT:add{
            text='Cell size of gird: '..cellSize,
            x=SCR.w0/2,y=SCR.h0/2,
        }

    -- Undo, Redo, Clear, Clear all, Interactive, View widget's detail
    elseif not isRep then
        if key=='escape' then
            if mo.isDown(1) then MouseDownX,MouseDownY=nil else TEXT:clear() end
        -- TODO: remake undo and redo system
        elseif key=='tab' then
            SCN.go('newWidget','none')
            BlackCover.playAnimation('fadeIn',0.5,0.7)
        elseif key=='z' then
            return
            -- TODO: Make DUMP function
        elseif key=='y' then
            return
            -- TODO
        elseif key=='delete' then
            undoList=TABLE.copy(widgetList)
            widgetList={}
            selectedWidget=false
        elseif key=='home' then
            SCN.go('_console')
        elseif key=='i' then
            SCN.scenes.interactive.widgetList={} --Empty the old widget list
            local interactiveWidgetList=SCN.scenes.interactive.widgetList
            for _,w in pairs(widgetList) do
                table.insert(interactiveWidgetList,w[5])
            end
            SCN.go('interactive')
        elseif key=='v' then
            SCN.go('textReader','none',TABLE.dump(widgetList))
        end
    end
end

function scene.draw()
    drawGirdAndSafeBorder()

    gc_setColor(1,1,1,1)
    -- Drawing widgets
    for _,w in pairs(widgetList) do w:draw() end
    -- Drawing the upcoming widget while dragging

    if selectedWidget then
        selectedWidget:draw()
    end

    BlackCover.draw()
end

function scene.update(dt)
    for _,w in pairs(widgetList) do w:update(dt) end
    if selectedWidget then selectedWidget.update() end
    BlackCover.update(dt)
end

return scene