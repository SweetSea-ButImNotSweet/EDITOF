local gc_setColor,gc_rectangle=GC.setColor,GC.rectangle
local gc_replaceTransform=GC.replaceTransform
local gc_getWidth,gc_getHeight=GC.getWidth,GC.getHeight
local clamp=MATH.clamp

local status='hide' -- 'show'|'fadeIn'|'fadeOut|'hide'
local framePassed=0
local anim_duration=0
local cover_opacity=0

local blackCover={}

---@param opacity number
function blackCover.show(opacity)
    status='show'
    cover_opacity=opacity
end

function blackCover.hide()
    status='hide'
    framePassed=0
end

---@param anim     'fadeIn'|'fadeOut'
---@param start    number
---@param duration number
function blackCover.playAnimation(anim,duration,opacity)
    if not anim then
        if status=='show' or status=='fadeIn' then
            status='fadeOut'
        else
            status='fadeIn'
        end
    else
        assert(anim=='fadeIn' or anim=='fadeOut',"[blackCover].anim must be 'fadeIn' or 'fadeOut', not "..tostring(anim))
        status=anim
    end
    if duration then anim_duration=duration end
    if opacity  then cover_opacity=opacity  end
    framePassed=0
end

---Please put this in the end of ``love.update`` or ``scene.update``
---@param dt number
function blackCover.update(dt)
    if status~='hide' then
        framePassed=framePassed+dt
    end
end

---Please put this in the end of ``love.draw`` or ``scene.draw``
function blackCover.draw()
    if     status=='hide'    then return
    elseif status=='fadeIn'  then gc_setColor(0,0,0,cover_opacity*clamp(   framePassed/anim_duration ,0,1))
    elseif status=='fadeOut' then gc_setColor(0,0,0,cover_opacity*clamp(1-(framePassed/anim_duration),0,1))
    else                          gc_setColor(0,0,0,cover_opacity) end

    gc_replaceTransform(SCR.origin)
    gc_rectangle('fill',0,0,gc_getWidth(),gc_getHeight())
end

return blackCover