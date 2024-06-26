---@diagnostic disable: unbalanced-assignments, ambiguity-1

local gc_setLineWidth,gc_setColor=GC.setLineWidth,GC.setColor
local gc_getWidth,gc_getHeight=GC.getWidth,GC.getHeight
local gc_line,gc_rectangle=GC.line,GC.rectangle
local gc_replaceTransform=GC.replaceTransform

local dumpWidget=require('assets.EDITOR.dumpWidget')

local kb=love.keyboard
local table_copy,table_clear=TABLE.copy,TABLE.clear
local table_insert,table_remove=table.insert,table.remove
local floor,ceil,wrap,max=math.floor,math.ceil,MATH.wrap,math.max

--- EDITOF is the EDITORfunc
---
--- I prefer using EDITOF than EDITORfunc, but you can use it if you want
EDITOF={}
EDITORfunc=EDITOF

------------------ < EDITOR > ------------------

function EDITOF.showNewWidgetDialog()
    SCN.go('newWidget','none')
    BlackCover.playAnimation('fadeIn',0.5,0.7)
end

function EDITOF.adjustZoomLevel(key)
    if     (key=='=' or key=='kp+') then EDITOR.cellSize=EDITOR.cellSize+1
    elseif (key=='-' or key=='kp-') then EDITOR.cellSize=max(2,EDITOR.cellSize-1) end
    TEXT:clear()
    TEXT:add{
        text='Cell size of gird: '..EDITOR.cellSize,
        x=SCR.w0/2,y=SCR.h0/2,
    }
end

function EDITOF.goToInteractiveMode()
    SCN.scenes.interactive.widgetList={}
    SCN.scenes.interactive.widgetList=table_copy(EDITOR.widgetList,0)
    collectgarbage()
    SCN.go('interactive')
end

------------------ </EDITOR > ------------------

------------------ < WIDGET > ------------------

function EDITOF.addWidget(w,reason)
    local w=w or EDITOR.selectedWidget
    if reason~='undo' and reason~='redo' then EDITOF.updateUndoList() end

    table_insert(EDITOR.widgetList,1,w)
end

function EDITOF.removeSelectedWidget()
    if not EDITOR.selectedWidget then return end

    EDITOF.updateUndoList()
    table_remove(EDITOR.widgetList,EDITOR.selectedWidgetID)
    EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
end

function EDITOF.removeAllWidgets()
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

---Use this to unselect selected widget (escape key)
function EDITOF.unselectWidget()
    if   EDITOR.selectedWidget
    then EDITOR.selectedWidget,EDITOR.selectedWidgetID=nil
    else TEXT:clear() end
end

function EDITOF.dumpAllWidgets()
    local output={}
    for _,w in pairs(EDITOR.widgetList) do
        output[#output+1]=dumpWidget(w,'table')
    end
    return output
end

--- # PLEASE USE THIS TO UPDATE UNDO LIST!
function EDITOF.updateUndoList()
    EDITOR.undoList[#EDITOR.undoList+1]=EDITOF.dumpAllWidgets()
    table_clear(EDITOR.redoList)
end

------------------ </ WIDGET /> ------------------

------------------ < ON KEY > ------------------

--- Put this in ``scene.keyDown()``
function EDITOF.selectedWidget_onKeyDown(key)
    local diff=(EDITOR.gridEnabled and EDITOR.cellSize) or 1
    if kb.isCtrlDown()  then diff=diff*10 end
    if kb.isShiftDown() then diff=diff*10 end

    local selectedWidget=EDITOR.selectedWidget
    local dx,dy,dw,dh,df=0,0,0,0,0

    --     Moving widget                         Resizing widget
    if     key=='a' then dx=-diff       elseif key=='j' then dw=-diff
    elseif key=='d' then dx= diff       elseif key=='l' then dw= diff
    elseif key=='w' then dy=-diff       elseif key=='i' then dh= diff
    elseif key=='s' then dy= diff       elseif key=='k' then dh=-diff

    --     Font size
    elseif key=='u' then df=-1
    elseif key=='o' then df= 1
    end

    -- Change alignment
    if kb.isDown(';','p') then
        if key==';' then
            selectedWidget.alignX=TABLE.next(
                {'left','center','right'},
                selectedWidget.alignX
            )
            MSG.new('info','selectedWidget.alignX='..selectedWidget.alignX,0.5)
        elseif key=='p' then
            selectedWidget.alignY=TABLE.next(
                {'top','center','bottom'},
                selectedWidget.alignY
            )
            MSG.new('info','selectedWidget.alignY='..selectedWidget.alignY,0.5)
        end

        EDITOF.updateUndoList()
        selectedWidget:reset()
        return true
    end

    if dx~=0 or dy~=0 or dw~=0 or dh~=0 or df~=0 then
        if selectedWidget.x then selectedWidget.x=selectedWidget.x+dx end
        if selectedWidget.y then selectedWidget.y=selectedWidget.y+dy end
        if selectedWidget.w then selectedWidget.w=selectedWidget.w+dw end
        if selectedWidget.h then selectedWidget.h=selectedWidget.h+dh end
        
        if selectedWidget.fontSize then
            selectedWidget.fontSize=max(selectedWidget.fontSize+df,1)
        end

        EDITOF.updateUndoList()
        selectedWidget:reset()
        return true
    end
end

------------------ </ ON KEY /> ------------------

------------------ < UNDO AND REDO > ------------------

-- Look at the editorTable.lua to know the structure
-- of undoList and redoList table

-- uL[i]=rL[i]={type='sea',x=25,y=52,w=100,...}

function EDITOF.undo()
    local uL=table_remove(EDITOR.undoList)
    if not uL then return end

    EDITOR.redoList[#EDITOR.redoList+1]=EDITOF.dumpAllWidgets()
    EDITOF.removeAllWidgets()
    for i=#uL,1,-1 do
        EDITOF.addWidget(WIDGET.new(table_copy(uL[i])),'undo')
    end
    return
end

function EDITOF.redo()
    local rL=table_remove(EDITOR.redoList)
    if not rL then return end

    EDITOR.undoList[#EDITOR.undoList+1]=EDITOF.dumpAllWidgets()
    EDITOF.removeAllWidgets()
    for i=#rL,1,-1 do
        EDITOF.addWidget(WIDGET.new(table_copy(rL[i])),'redo')
    end
    return
end

------------------ </ UNDO AND REDO /> ------------------

------------------ < DRAW > ------------------

--- Draw gird in the editor's area
function EDITOF.drawGird()
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
end
--- Draw safe border
function EDITOF.drawSafeBorder()
    gc_replaceTransform(SCR.xOy)
    gc_setLineWidth(20)
    gc_setColor(1,1,1,EDITOR.girdOpacity+0.1)
    gc_rectangle('line',0,0,SCR.w0,SCR.h0)
end
------------------ </ DRAW /> ------------------


------------------ < OTHER > ------------------

function EDITOF.getSnappedLocation(x,y)
    if not EDITOR.gridEnabled then return x,y end
    local cellSize=EDITOR.cellSize

    local halfCellSize=EDITOR.cellSize/2
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