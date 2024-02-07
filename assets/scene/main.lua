local gc,mo,kb=love.graphics,love.mouse,love.keyboard
local gc_line,gc_rectangle,gc_circle=gc.line,gc.rectangle,gc.circle
local gc_setLineWidth,gc_setColor=gc.setLineWidth,gc.setColor
local gc_push,gc_pop,gc_translate=gc.push,gc.pop,gc.translate

local getDelta=love.timer.getDelta
local floor,ceil,max,clamp=math.floor,math.ceil,math.max,MATH.clamp

local MouseDownX,MouseDownY
local widgetList={}
local currentUpcomingWidget
local redoList={}
local justClearAll=false

local blackCover_frameCounter=0.75
local blackCover_playFadeOutAnimation=false
local blackCover_show=false

local girdEnabled=true
local girdOpacity=0.1
local cellSize=10

local scene={}

local function drawGirdAndSafeBorder()
    -- + ----- X
    -- | +++++
    -- | +++++
    -- Y +++++

    gc_push()
    gc.replaceTransform(SCR.origin)
        local w,h=gc.getWidth(),gc.getHeight()

        gc_setColor(1,1,1,girdOpacity)
        gc_setLineWidth(1)
        -- From 0 to X
        for ix=1,floor(w/cellSize) do
            gc_line(cellSize*ix,0,cellSize*ix,h)
        end
        -- From 0 to Y
        for iy=1,floor(h/cellSize) do
            gc_line(0,cellSize*iy,w,cellSize*iy)
        end
    gc_pop()

        -- Draw safe border
        gc_setLineWidth(20)
        gc_setColor(1,1,1,girdOpacity+0.1)
        gc_line(0,0,SCR.w0,0)
        gc_line(0,0,0,SCR.h0)
        gc_line(SCR.w0,SCR.h0,SCR.w0,0)
        gc_line(SCR.w0,SCR.h0,0,SCR.h0)
end

local function getSnappedLocation(x,y)
    if not girdEnabled then return x,y end

    local halfCellSize=cellSize/2
    if x%cellSize>halfCellSize then x=ceil(x/cellSize)*cellSize else x=floor(x/cellSize)*cellSize end
    if y%cellSize>halfCellSize then y=ceil(y/cellSize)*cellSize else y=floor(y/cellSize)*cellSize end

    return x,y
end

--- For drawing widget, if there is no widget, draw a blank widget instead
-- xByMouse,yByMouse,wByMouse,hByMouse <-- assuming the widget's center is top left
local function drawWidget(xByMouse,yByMouse,wByMouse,hByMouse,wid)
    local alignX,alignY
    if (wid and (  -- Ignore wid.alignX and wid.alignY in these widgets as they doesn't use
        wid.type=='selector' or     -- the same rule while drawing itself on the screen.
        wid.type=='inputBox' or
        wid.type=='textBox'  or
        wid.type=='listBox'
    )) or not wid then
        alignX,alignY='left','up'
    else
        alignX=wid and wid.alignX
        alignY=wid and wid.alignY
    end
    
    -- Modifying X and Y for center and right-down case
    if wid then
        if currentUpcomingWidget and wid==currentUpcomingWidget then
            wid.x,wid.y=xByMouse,yByMouse
            wid.w=alignX=='center' and wByMouse*2 or alignX=='right' and -wByMouse or wByMouse
            wid.h=alignY=='center' and hByMouse*2 or alignY=='down'  and -hByMouse or hByMouse
            
            -- Need to double the size of some widget (due to their specific nature)
            if wid.type=='checkBox' then
                wid.w=wid.w*2
                wid.h=wid.w
            elseif wid.type=='switch' then
                wid.h=wid.w
            end
        end
        if wid.type=='listBox' then wid:update(getDelta()) else wid:reset() end
        wid:draw()
    else
        gc_setColor(1,1,1,1)
        gc_setLineWidth(5)
        gc_rectangle('line',xByMouse,yByMouse,wByMouse,hByMouse)
    end

    gc_push()
        do -- Modify the coordinatior for drawing 4 lines -\|/
            local w,h

            if wid then
                w,h=wid.w,wid.h;
                gc_translate(wid._x-w/2,wid._y-h/2)
            else
                w,h=wByMouse,hByMouse
                gc_translate(xByMouse,yByMouse)
            end

            gc_setColor(1,1,1)
            gc_circle('fill',w/2,h/2,16)
            gc_setColor(unpack(COLOR.lG))
            gc_circle('fill',w/2,h/2,8)
        end
    gc_pop()
end

function scene.enter()
    blackCover_show=false
    if SCN.prev=='newWidget' and SCN.args[1] then
        blackCover_playFadeOutAnimation=true
        TEXT:add{
            text=string.format("%s - %s",SCN.args[1],SCN.args[2].type),
            x=SCR.w/2,y=SCR.h/2,
            duration=1,
            inPoint=0.25,outPoint=0.25
        }
        currentUpcomingWidget=SCN.args[2]
    end
end

function scene.mouseDown(x,y)
    if mo.isDown(1) then
        MouseDownX,MouseDownY=getSnappedLocation(x,y)
        if currentUpcomingWidget then
            currentUpcomingWidget.x,currentUpcomingWidget.y=MouseDownX,MouseDownY
            currentUpcomingWidget:reset()
        end
    else
        TEXT:clear()
        TEXT:add{
            text=string.format("%s, %s",getSnappedLocation(x,y)),
            x=SCR.w/2,y=SCR.h/2,
            duration=1.5
        }
    end
end

function scene.mouseUp(x,y)
    x,y=getSnappedLocation(x,y)
    if not MouseDownX or (MouseDownX==x and MouseDownY==y) then return end

    local widgetW,widgetH=x-MouseDownX,y-MouseDownY
    if kb.isDown('lshift','rshift') then widgetH=widgetW end

    table.insert(widgetList,{MouseDownX,MouseDownY,widgetW,widgetH,currentUpcomingWidget})
    currentUpcomingWidget,MouseDownX,MouseDownY=nil
    justClearAll=false
end

function scene.wheelMoved(_,y)
    WHEELMOV(y,'=','-')
end

function scene.keyDown(key,isRep)
    if not isRep then
        if key=='escape' then
            if mo.isDown(1) then MouseDownX,MouseDownY=nil else TEXT:clear() end
        elseif key=='z' then
            if #widgetList>0 then
                table.insert(redoList,table.remove(widgetList))
            elseif justClearAll then
                widgetList=TABLE.copy(redoList)
                TABLE.cut(redoList)
            end
            justClearAll=false
        elseif key=='delete' then
            redoList=TABLE.copy(widgetList)
            widgetList={}
            justClearAll=true
        elseif key=='tab' then
            blackCover_frameCounter=0.75
            blackCover_show=true
            blackCover_playFadeOutAnimation=false
            SCN.go('newWidget','none')
        -- elseif key=='home' then
        --     SCN.go('test')
        elseif key=='i' then
            SCN.scenes.interactive.widgetList={} --Empty the old widget list
            local interactiveWidgetList=SCN.scenes.interactive.widgetList
            for _,w in pairs(widgetList) do
                table.insert(interactiveWidgetList,w[5])
            end
            SCN.go('interactive')
        end
    end

    if (key=='=' or key=='kp+')  then
        cellSize=cellSize+1
        TEXT:clear()
        TEXT:add{
            text='Cell size of gird: '..cellSize,
            x=SCR.w/2,y=SCR.h/2,
        }
    elseif (key=='-' or key=='kp-') then
        cellSize=max(2,cellSize-1)
        TEXT:clear()
        TEXT:add{
            text='Cell size of gird: '..cellSize,
            x=SCR.w/2,y=SCR.h/2,
        }
    end
end

function scene.draw()
    drawGirdAndSafeBorder()

    gc_setColor(1,1,1,1)
    -- Drawing widgets
    for _,v in pairs(widgetList) do drawWidget(unpack(v)) end -- v={x,y,w,h,wid}
    -- Drawing the upcoming widget while dragging
    local mouseCurrentX,mouseCurrentY=mo.getPosition()
    if MouseDownX and mo.isDown(1) then
        local widgetW,widgetH=mouseCurrentX-MouseDownX,mouseCurrentY-MouseDownY
        if kb.isDown('lshift','rshift') then widgetH=widgetW end

        drawWidget(MouseDownX,MouseDownY,widgetW,widgetH,currentUpcomingWidget)
    end

    -- Black opacity (when switching from previous frames)
    if blackCover_playFadeOutAnimation or blackCover_show then
        gc_setColor(0,0,0,0.7*clamp((blackCover_frameCounter+0.75)/0.75,0,1))
        gc_rectangle('fill',0,0,SCR.w,SCR.h)
        if blackCover_frameCounter>0 then
            if blackCover_playFadeOutAnimation then blackCover_frameCounter=blackCover_frameCounter-getDelta() end
        else
            blackCover_frameCounter=0.75
            blackCover_show=false
            blackCover_playFadeOutAnimation=false
        end
    end
end

function scene.update(dt)
    for _,v in pairs(widgetList) do -- v={x,y,w,h,wid}
        if v[5] and v[5].update then v[5]:update(dt) end
    end 
end

return scene