EDITOR={
    widgetList={},

    -- Hover and select widgets
    selectedWidget=nil,
    selectedWidgetID=nil,
    hoveringWidget=nil,         -- hoveringWidget != selectedWidget
    hoveringWidgetID=nil,
    updatedBeforeMoving=false,

    -- Undo and Redo
    -- Format: {{},{w1},{w1,w2},{w1,w2,w3},...}
    undoList={},
    redoList={},

    -- Gird
    gridEnabled=true,
    girdOpacity=0.1,
    cellSize=10,
}