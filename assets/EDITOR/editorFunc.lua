local gc_setLineWidth,gc_setColor=GC.setLineWidth,GC.setColor
local gc_getWidth,gc_getHeight=GC.getWidth,GC.getHeight
local gc_line,gc_rectangle=GC.line,GC.rectangle
local gc_replaceTransform=GC.replaceTransform

local dumpWidget=require('assets.EDITOR.dumpWidget')

local table_clear=TABLE.clear
local table_insert=table.insert
local floor,ceil,wrap,max=math.floor,math.ceil,MATH.wrap,math.max

--- EDITOF is the EDITORfunc
---
--- I prefer using EDITOF than EDITORfunc, but you can use it if you want
EDITOF={}
EDITORfunc=EDITOF

------------------ < WIDGET > ------------------

function EDITOF.dumpAllWidgets()
    local output={}
    for _,w in pairs(EDITOR.widgetList) do
        output[#output+1]=dumpWidget(w,'table')
    end
    return output
end

function EDITOF.updateUndoList()
    EDITOR.undoList[#EDITOR.undoList+1]=EDITOF.dumpAllWidgets()
    table_clear(EDITOR.redoList)
end

function EDITOF.addWidget(w,reason)
    local w=w or EDITOR.selectedWidget
    if not TABLE.findAll(EDITOR.widgetList,w) then
        if reason~='undo' and reason~='redo' then
            EDITOF.updateUndoList()
        end

        table_insert(EDITOR.widgetList,1,w)
    end
end

function EDITOF.clearAllWidgets()
    EDITOR.hoveringWidget,EDITOR.hoveringWidgetID,EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
    TABLE.safeClearR(EDITOR.widgetList,{'[Cc]olor','axis'},true,true)
    collectgarbage()    -- Collecting all garbages that released from all widgets.
end

function EDITOF.switchSelectedWidget(d)
    EDITOR.selectedWidgetID=wrap(
        EDITOR.selectedWidgetID and (EDITOR.selectedWidgetID+(d=='next' and -1 or d=='prev' and 1 or 0) or 0) or
        (d=='next' and #EDITOR.widgetList or 1),
        1,#EDITOR.widgetList
    )
    EDITOR.selectedWidget=EDITOR.widgetList[EDITOR.selectedWidgetID]
end

------------------ </ WIDGET /> ------------------

------------------ < ON KEY > ------------------

--- Put this in ``scene.keyDown()``
function EDITOF.selectedWidget_onKeyDown(key)
    local diff=(EDITOR.gridEnabled and EDITOR.cellSize) or 1
    local selectedWidget=EDITOR.selectedWidget
    local dx,dy,dw,dh,df=0,0,0,0,0

    --     Moving widget                         Resizing widget
    if     key=='a' then dx=dx-diff       elseif key=='j' then dw=dw-diff
    elseif key=='d' then dx=dx+diff       elseif key=='l' then dw=dw+diff
    elseif key=='w' then dy=dy-diff       elseif key=='i' then dh=dh+diff
    elseif key=='s' then dy=dy+diff       elseif key=='k' then dh=dh-diff

    --     Font size
    elseif key=='u' then df=df-1
    elseif key=='o' then df=df+1
    end

    if dx~=0 or dy~=0 or dw~=0 or dh~=0 or df~=0 then
        if selectedWidget.x then selectedWidget.x=selectedWidget.x+dx end
        if selectedWidget.y then selectedWidget.y=selectedWidget.y+dy end
        if selectedWidget.w then selectedWidget.w=selectedWidget.w+dw end
        if selectedWidget.h then selectedWidget.h=selectedWidget.h+dh end
        
        if selectedWidget.fontSize then
            selectedWidget.fontSize=max(selectedWidget.fontSize+df,1)
        end

        selectedWidget:reset()
        return true
    end
end

------------------ </ ON KEY /> ------------------

------------------ < DRAW > ------------------

function EDITOF.drawGirdAndSafeBorder()
    -- +-------X
    -- |+++++++
    -- |+++++++
    -- Y+++++++

    gc_replaceTransform(SCR.origin)
    local scr_origin_w,scr_origin_h=gc_getWidth(),gc_getHeight()

    gc_setColor(1,1,1,EDITOR.girdOpacity)
    gc_setLineWidth(1)
    -- From 0 to X
    for ix=1,floor(scr_origin_w/EDITOR.cellSize) do
        gc_line(EDITOR.cellSize*ix,0,EDITOR.cellSize*ix,scr_origin_h)
    end
    -- From 0 to Y
    for iy=1,floor(scr_origin_h/EDITOR.cellSize) do
        gc_line(0,EDITOR.cellSize*iy,scr_origin_w,EDITOR.cellSize*iy)
    end

    -- Draw safe border
    gc_replaceTransform(SCR.xOy)
    gc_setLineWidth(20)
    gc_setColor(1,1,1,EDITOR.girdOpacity+0.1)
    gc_rectangle('line',0,0,SCR.w0,SCR.h0)
end

------------------ </ DRAW /> ------------------


------------------ < OTHER > ------------------

function EDITOF.getSnappedLocation(x,y)
    if not EDITOR.gridEnabled then return x,y end

    local halfCellSize=EDITOR.cellSize/2
    if x%EDITOR.cellSize>halfCellSize
        then x=ceil (x/EDITOR.cellSize)*EDITOR.cellSize
        else x=floor(x/EDITOR.cellSize)*EDITOR.cellSize
    end
    if y%EDITOR.cellSize>halfCellSize
        then y=ceil (y/EDITOR.cellSize)*EDITOR.cellSize
        else y=floor(y/EDITOR.cellSize)*EDITOR.cellSize
    end

    return x,y
end