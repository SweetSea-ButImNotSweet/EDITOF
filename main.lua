-- Import Zenitha
require('Zenitha')
STRING.install()
-- Set app's resolution and call Zenitha to recalculate the ratio
SCR.resize(1280,720)
-- FPS
Zenitha.setMaxFPS(50) -- Enough
-- Hide FPS and version (not necessary)
-- Zenitha.setShowFPS(false)
-- Zenitha.setVersionText('')
-- Global Fn keys
Zenitha.setOnGlobalKey('f11',function()
    love.window.setFullscreen(not love.window.getFullscreen())
    love.resize(love.graphics.getWidth(),love.graphics.getHeight())
end)

-- Other modules
CHAR=require('assets.char')

-- Default variable
SCENE_PATH='assets/scene'

-- Add scene file and set default scene to main
for _,f in next,love.filesystem.getDirectoryItems(SCENE_PATH) do
    if FILE.isSafe(SCENE_PATH..'/'..f) then
        local sceneName=f:sub(1,-5)
        SCN.add(sceneName,require(SCENE_PATH..'/'..sceneName))
    end
end
Zenitha.setFirstScene('main')

-- Load font
FONT.load{
    main='assets/fonts/RHDisplayGalaxy-Medium.otf',
    symbols='assets/fonts/symbols.otf'
}
FONT.setDefaultFont('main')

-- Load image
IMG.init{
    placeholder ='assets/image/placeholder.png',
}

Zenitha.setOnFnKeys{
    function()
        if WIDGET.getSelected() then
            MSG.new('info',WIDGET.getSelected():getInfo())
        end
    end
}