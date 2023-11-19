-- Import Zenitha
require('Zenitha')
STRING.install()

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

-- Add language file here
-- LANG.add{
--     en='assets/lang/en'
--     -- Add more here
-- }
-- LANG.setDefault('en')

-- Load font
FONT.load{
    main='assets/fonts/RHDisplayGalaxy-Medium.otf'
}
FONT.setDefaultFont('main')