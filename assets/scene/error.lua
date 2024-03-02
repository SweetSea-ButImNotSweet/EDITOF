local BGcolor
local currentScn,errorText

local scene={}

function scene.enter()
    if Zenitha.getErr('#') then
        Zenitha.setShowFPS(false)
        Zenitha.setVersionText('')
    end

    err=Zenitha.getErr('#') or {
        scene="C L G T ? !",
        msg={
            "ỦA APP CÓ BUG NÀO ĐÂU? VẪN CHẠY BÌNH THƯỜNG MÀ NHỈ???\nLÀM QUÁI NÀO MÀN HÌNH NÀY LẠI XUẤT HIỆN KHI KHÔNG CÓ LỖI CƠ CHỨ?",
            "",
            "À hiểu rồi, ông cố mở đúng không?",
            "Ông có thể nhấn nút ESC để có thể thoát ra",
            "(hoặc nhấn nút 'QUIT' trên màn hình cũng được)",
            "",
            "Nếu app gặp bug thì cứ thoải mái tạo issue trên GitHub đi!",
            "(mà làm ơn đừng tạo issue trùng với issue đã tạo rồi đấy!)",
            "",
            "(Placeholder cho ảnh chụp màn hình được làm bởi 'CoColemon')"
        },
        shot=IMG.error_placeholder
    }
    BGcolor=Zenitha.getErr('#') and {.0,.0,.5} or {.1,.5,.9}
    currentScn="scene: "..err.scene
    errorText ="EDITOF has unexpectedly stopped working!\n#tấtcảlàtạiMagiaBaiser #tấtcảlàtạiUtenaHiigari"
end

function scene.draw()
    GC.clear(BGcolor)
    GC.setColor(1,1,1)
    GC.draw(err.shot,100,230,nil,512/err.shot:getWidth(),288/err.shot:getHeight())

    GC.setColor(COLOR.LL)
    FONT.set(40,'monoBI')GC.printf(errorText,100,55,SCR.w0-100)

    FONT.set(20,'monoB')
    GC.print(currentScn,100,200)
    GC.printf(err.msg[1],626,200,600)

    FONT.set(17,'monoM')
    GC.printf(table.concat(err.msg,'\n',2),626,300,600)
end

scene.widgetList={
    WIDGET.new{type='button',name='console',x=225,y=570,w=245,h=80,cornerR=0,fontSize=40,fontType='symbols',text=CHAR.icon.console  ..' Terminal',code=WIDGET.c_goScn'_console'},
    WIDGET.new{type='button',name='quit'   ,x=485,y=570,w=245,h=80,cornerR=0,fontSize=40,fontType='symbols',text=CHAR.icon.cross_big..' Quit',code=WIDGET.c_pressKey'escape'},
}

return scene
