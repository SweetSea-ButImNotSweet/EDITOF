local toHex=STRING.toHex
local sub=string.sub
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
---@param a? number
---@return string @ Color in HEX format string
--- Convert color from RGB(A) format to HEX format
function COLOR.rgb2hex(r,g,b,a)
    assertf(
        (
            type(r)=='number' and r>=0 and r<=255 and
            type(g)=='number' and g>=0 and g<=255 and
            type(b)=='number' and b>=0 and b<=255 and
            (
                type(a)=='nil' or
                type(a)=='number' and a>=0 and a<=1
            )
        ),
        'Require r, g, b, a need to be in 0-1 or 0-255, got r=%s, g=%s, b=%s, a=%s',
        tostring(r), tostring(g), tostring(b), tostring(a)
    )
    local Rh,Gh,Bh,Ah
    Rh=toHex((r%1~=0 and r*255) or r)
    Gh=toHex((g%1~=0 and g*255) or g)
    Bh=toHex((b%1~=0 and b*255) or b)
    Ah=a and toHex(a) or ''

    return Rh..Gh..Bh..Ah
end

local color_hex_superTable={
    Red=     {'3D0401','83140F','FF3126','FF7B74','FFC0BC'},
    Flame=   {'3B1100','802806','FA5311','F98D64','FAC5B0'},
    Orange=  {'341D00','7B4501','F58B00','F4B561','F5DAB8'},
    Yellow=  {'2E2500','755D00','F5C400','F5D763','F5EABD'},
    Apple=   {'202A02','536D06','AFE50B','C5E460','D9E5B2'},
    Kelly=   {'0C2800','236608','4ED415','8ADE67','C2E5B4'},
    Green=   {'002A06','096017','1DC436','69D37A','B0E2B8'},
    Jungle=  {'002E2C','00635E','00C1B7','5BD2CA','B0E1DE'},
    Cyan=    {'032733','135468','30A3C6','72C1D7','B1DBE8'},
    Ice=     {'0C2437','194A73','318FDB','6FAEE0','A9CAE4'},
    Sea=     {'001F40','014084','007BFF','519CEF','B0CCEB'},
    Blue=    {'0D144F','212B8F','4053FB','7C87F7','B2B8F4'},
    Purple=  {'1D1744','332876','5947CC','897CE1','B7ADF7'},
    Violet=  {'2A1435','54296C','9F4BC9','B075CB','C8A7D8'},
    Magenta= {'37082B','731A5D','DE3AB5','DF74C3','DEA9D1'},
    Wine=    {'460813','871126','F52249','F56D87','F5B4C0'},

    Dark=    {'000000','060606','101010','3C3C3C','7A7A7A'},
    Light=   {'B8B8B8','DBDBDB','FDFDFD','FEFEFE','FFFFFF'},
    Xback=   {'060606CC','3C3C3CCC','7A7A7ACC','DBDBDBCC','FEFEFECC'},
}
local color_brightness_string={'D','d','','l','L'}
---Get the pair of letters of provided color.
---
---Example: ``dL``,``lW``,...
---@param c string @ Color as hex string
---@return string
function COLOR.getPairOfLetters(c)
    local colorString
    if type(c)=='table' and (#c==3 or #c==4) then
        colorString=COLOR.rgb2hex(unpack(c))
    else
        colorString=c
    end
    assertf(c and type(c)=='string' and #c>=6 and #c<=8,'COLOR.getPairOfLetters requires a table of color or a HEX string')

    for color_name,color_table in pairs(color_hex_superTable) do
        for i,C in pairs(color_table) do
            if colorString==C then
                return (color_brightness_string[i])..sub(color_name,1,1)
            end
        end
    end
end