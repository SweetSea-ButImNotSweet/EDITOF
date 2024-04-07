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

    -- Key shortcut, ``{1}:key, {2}:function (string), {3}:argument - can be empty``
    keyShortcut={
        normal={
            escape='unselectWidget',

            q={'switchSelectedWidget','prev'},
            e={'switchSelectedWidget','next'},

            delete='removeSelectedWidget',

            ['+']  ={'adjustZoomLevel','+'},
            ['-']  ={'adjustZoomLevel','-'},
            ['kp+']={'adjustZoomLevel','+'},
            ['kp-']={'adjustZoomLevel','-'},

            ['`']='showNewWidgetDialog',
            space='goToInteractiveMode'
        },
        ctrl_down={
            ['return']='_console',

            z='undo',y='redo',
            delete='removeAllWidget'
        },
        alt_down={},
    },
}