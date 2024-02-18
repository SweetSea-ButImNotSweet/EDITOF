local gc_setLineWidth,gc_setColor=GC.setLineWidth,GC.setColor
local gc_getWidth,gc_getHeight=GC.getWidth,GC.getHeight
local gc_line,gc_rectangle=GC.line,GC.rectangle
local gc_replaceTransform=GC.replaceTransform

local dumpWidget=require('assets.EDITOR.dumpWidget')

local table_clear=TABLE.clear
local table_insert=table.insert
local floor,ceil,wrap=math.floor,math.ceil,MATH.wrap

EDITORfunc={}

function EDITORfunc.drawGirdAndSafeBorder()
    -- + ------- X
    -- | +++++++
    -- | +++++++
    -- Y +++++++

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

function EDITORfunc.getSnappedLocation(x,y)
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

function EDITORfunc.dumpAllWidgets()
    local output={}
    for _,w in pairs(EDITOR.widgetList) do
        output[#output+1]=dumpWidget(w,'table')
    end
    return output
end

function EDITORfunc.updateUndoList()
    EDITOR.undoList[#EDITOR.undoList+1]=EDITORfunc.dumpAllWidgets()
    table_clear(EDITOR.redoList)
end

function EDITORfunc.addWidget(w,reason)
    local w=w or EDITOR.selectedWidget
    if not TABLE.findAll(EDITOR.widgetList,w) then
        if reason~='undo' and reason~='redo' then
            EDITORfunc.updateUndoList()
        end

        table_insert(EDITOR.widgetList,1,w)
    end
end

function EDITORfunc.clearAllWidgets()
    EDITOR.hoveringWidget,EDITOR.hoveringWidgetID,EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
    TABLE.safeClearR(EDITOR.widgetList,{'[Cc]olor','axis'},true,true)
    collectgarbage()    -- Collecting all garbages that released from all widgets.
end

function EDITORfunc.switchSelectedWidget(d)
    EDITOR.selectedWidgetID=wrap(
        EDITOR.selectedWidgetID and (EDITOR.selectedWidgetID+(d=='next' and -1 or d=='prev' and 1 or 0) or 0) or
        (d=='next' and #EDITOR.widgetList or 1),
        1,#EDITOR.widgetList
    )
    EDITOR.selectedWidget=EDITOR.widgetList[EDITOR.selectedWidgetID]
end