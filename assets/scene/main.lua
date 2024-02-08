local gc,mo,kb=love.graphics,love.mouse,love.keyboard
local gc_line,gc_rectangle,gc_circle=gc.line,gc.rectangle,gc.circle
local gc_setLineWidth,gc_setColor=gc.setLineWidth,gc.setColor
local gc_push,gc_pop,gc_translate=gc.push,gc.pop,gc.translate
local gc_getWidth,gc_getHeight=gc.getWidth,gc.getHeight
local gc_replaceTransform=gc.replaceTransform

local getDelta=love.timer.getDelta
local floor,ceil,max,clamp=math.floor,math.ceil,math.max,MATH.clamp

-- TODO: bring it to a function named blackCover
local blackCover_frameCounter=0.75
local blackCover_playFadeOutAnimation=false
local blackCover_show=false

local nextWidgetID=0        -- For generated widgets in the future
local currentUpcomingWidget

local fullWidgetList={}
local widgetList={} -- Format: ID={x,y,w,h,WIDGET}
local undoList={}   -- Format: taskID={widID,key/action,new value,old value}/{'clearAll',{widgetList}}
local redoList={}   -- Format: taskID={widID,key/action,old value,new value}/{'clearAll',{wodgetList}}

local girdEnabled=true
local girdOpacity=0.1
local cellSize=10

local scene={}

local function returnWidgetUnderMouseCursor(x,y,returnID)
    for id,w in pairs(widgetList) do
        if w[5]:isAbove(x,y) then
            if returnID then return id else return w[5] end
        end
    end
end

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
        gc_rectangle('line',0,0,SCR.w0,SCR.h0)
end

local function getSnappedLocation(x,y)
    if not girdEnabled then return x,y end

    local halfCellSize=cellSize/2
    if x%cellSize>halfCellSize then x=ceil(x/cellSize)*cellSize else x=floor(x/cellSize)*cellSize end
    if y%cellSize>halfCellSize then y=ceil(y/cellSize)*cellSize else y=floor(y/cellSize)*cellSize end

    return x,y
end


local function drawWidget(mouseX,mouseY,widgetW,widgetH,wid)
end

function scene.enter()
    blackCover_show=false
    if SCN.prev=='newWidget' and SCN.args[1] then
        blackCover_playFadeOutAnimation=true
        TEXT:add{
            text=string.format("%s - %s",SCN.args[1],SCN.args[2].type),
            x=SCR.w0/2,y=SCR.h0/2,
            duration=1,
            inPoint=0.25,outPoint=0.25
        }
        currentUpcomingWidget=SCN.args[2]
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
    if not isRep then
        if key=='escape' then
            if mo.isDown(1) then MouseDownX,MouseDownY=nil else TEXT:clear() end
        -- TODO: remake undo and redo system
        elseif key=='z' then
            -- local w=table.remove(undoList)
            -- if w then
            --     if w[1]=='clearAll' then
            --         widgetList=TABLE.copy(w[2]) -- I haven't made a DUMP function yet
            --     end
            -- end
        elseif key=='y' then
        elseif key=='delete' then
            undoList=TABLE.copy(widgetList)
            widgetList={}
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
        elseif key=='v' then
            SCN.go('textReader','none',TABLE.dump(widgetList))
        end
    end

    if (key=='=' or key=='kp+')  then
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
    end
end

function scene.draw()
    drawGirdAndSafeBorder()

    gc_setColor(1,1,1,1)
    -- Drawing widgets
    for _,v in pairs(widgetList) do drawWidget(unpack(v)) end -- v={x,y,w,h,wid}
    -- Drawing the upcoming widget while dragging

    -- Black opacity (when switching from previous frames)
    if blackCover_playFadeOutAnimation or blackCover_show then
        gc_push()
            gc_replaceTransform(SCR.origin)
            gc_setColor(0,0,0,0.7*clamp((blackCover_frameCounter+0.75)/0.75,0,1))
            gc_rectangle('fill',0,0,gc_getWidth(),gc_getHeight())
        gc_pop()
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