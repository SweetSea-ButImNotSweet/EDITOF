local toHex=STRING.toHex
-- local function toHex(n)     --- ONLY USED BY COLOR.rgb2hex
--     local sub,floor=string.sub,math.floor
--     local hexBase='0123456789ABCDEF'
--     local result=''
--     local n=n

--     while n>0 do
--         local R=n%16+1
--         result=sub(hexBase,R,R)..result
--         n=floor(n*0.0625)
--     end
--     return result
-- end


---@param r number
---@param g number
---@param b number
---@return string @ Color in Hex format
--- Convert color from RGB format to HEX format
function COLOR.rgb2hex(r,g,b)
    assertf(
        (
            type(r)=='number' and r>=0 and r<=255 and
            type(g)=='number' and g>=0 and g<=255 and
            type(b)=='number' and b>=0 and b<=255
        ),
        'Require r, g, b need to be in 0-1 or 0-255, got r=%s, g=%s, b=%s',
        tostring(r), tostring(g), tostring(b)
    )
    local Rh,Gh,Bh
    Rh=toHex((r%1~=0 and r*255) or r)
    Gh=toHex((g%1~=0 and g*255) or g)
    Bh=toHex((b%1~=0 and b*255) or b)

    return Rh..Gh..Bh
end