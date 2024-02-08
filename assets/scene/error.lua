local BGcolor
local sysAndScn,errorText

local scene={}

function scene.enter()
    if Zenitha.getErr('#') then
        Zenitha.setShowFPS(false)
        Zenitha.setVersionText('')
    end

    err=Zenitha.getErr('#') or {
        scene="NULL",
        msg={"??????????????????????????","","Traceforward","??????","?????","????","???","??","?"},
        shot=GC.load{200,120,
            {'setLW',2},
            {'setCL',1,1,1,.2},
            {'fRect',0,0,200,120},
            {'setCL',COLOR.L},
            {'setFT',60},
            {'print','?',118,95,MATH.pi},
        },
    }
    BGcolor=math.random()>.026 and {.3,.5,.9} or {.62,.3,.926}
    sysAndScn="Something4Fun        scene:"..err.scene
    errorText="WTF my application crashed again?\nPlease tell me, SweetSea, about this error ASAP so I can fix."
end

function scene.draw()
    GC.clear(BGcolor)
    GC.setColor(1,1,1)
    GC.draw(err.shot,100,326,nil,512/err.shot:getWidth(),288/err.shot:getHeight())
    GC.setColor(COLOR['LL'])
    FONT.set(100)GC.print(":(",100,0,0,1.2)
    FONT.set(40)GC.printf(errorText,100,160,SCR.w0-100)
    FONT.set(20,'_mono')
    GC.print(sysAndScn,100,630)
    FONT.set(15,'_mono')
    for i=1,#err.msg do
        GC.printf(err.msg[i],626,326+20*(i==1 and 0 or i+2),650)
    end
end

scene.widgetList={
    WIDGET.new{type='button',name='console',x=940,y=85,w=170,h=80,fontSize=65,fontType='symbols',text=CHAR.icon.console,code=WIDGET.c_goScn'_console'},
    WIDGET.new{type='button',name='quit',x=1140,y=85,w=170,h=80,fontSize=60,fontType='symbols',text=CHAR.icon.cross_big,code=WIDGET.c_pressKey'escape'},
}

return scene
