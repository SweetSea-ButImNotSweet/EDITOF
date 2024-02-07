function love.conf(t)
    -- SHOULD CHANGE
    local game_name='Something4Zen'
    local game_ver ='0.0'
    local game_id  ='Something4Zen'

    local SCREEN_W,SCREEN_H=1280,720
    local SCREEN_minW,SCREEN_minH=1280,720
    local portrait=false
    
    -- SHOULD NOT CHANGE!
    local msaa=4
    local mobile=love._os=='Android' or love._os=='iOS'

    t.identity=game_id
    t.externalStorage=true -- Use external storage on Android
    t.version="11.4"

    t.gammacorrect=false
    t.appendidentity=true -- Search files in source then in save directory
    t.accelerometerjoystick=false -- Accelerometer=joystick on ios/android
    if t.audio then
        t.audio.mic=false
        t.audio.mixwithsystem=true
    end

    -- Enable love's modules
    -- Better to keep like this in order to keep Zenitha can work stably
    t.modules={
        system=true,event=true,window=true,
        thread=true,math=true,data=true,

        -- WARNING: Disable timer module will lead to delta time is 0 in love.update()
        timer=true,

        video=true,   audio=true,sound=true,
        graphics=true,image=true,font=true,

        mouse   =true,
        keyboard=true,
        touch   =true,
        joystick=true,

        physics =false,
    }

    t.window={
        title         =game_name..' '..game_ver,
        icon          =nil,

        display       =1,           -- Monitor ID
        vsync         =0,           -- 0 = Unlimited FPS, otherwise limit to x FPS
        msaa          =msaa,        -- Multi-sampled antialiasing
        highdpi       =true,        -- High-dpi mode for the window on a Retina display

        x             =nil,         -- Position of the window (set to nil so...
        y             =nil,         -- ...love2d will align the window to the center of the screen)

        depth         =0,           -- Bits/samp of depth buffer
        stencil       =1,           -- Bits/samp of stencil buffer

        borderless    =mobile,
        resizable     =not mobile,
        fullscreentype=mobile and "exclusive" or "desktop", -- Fullscreen type
    }

    -- Set the window's size (don't need to change this)
    local W=t.window
    if portrait then
        W.width,W.height=SCREEN_H,SCREEN_W
        W.minwidth,W.minheight=SCREEN_minH,SCREEN_minW
    else
        W.width,W.height=SCREEN_W,SCREEN_H
        W.minwidth,W.minheight=SCREEN_minW,SCREEN_minH
    end
end