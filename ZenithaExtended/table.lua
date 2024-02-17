---@param t table
---@return output table
---@author: Not_A_Robot
--- Return table where keys and values are swapped (useful for hashmap)
function TABLE.kvSwap(t)
    local output={}
    for k,v in next,t do output[v]=k end
    return output
end

---@param t table k: number, v: string|number
---@return output table
---Generate a simple hashmap (only simple: k - v with v is a string or number, not function or boolean!)
function TABLE.generateHashmap(t)
    error('TABLE.generateHashmap is not ready to use yet!')
    local output={}
    for _,k in pairs(t) do
        output[k]=true
    end
end

---@param t table
---Clear table recusively (deep clean!)
---
---Use with **CAUTION**: it may clear the value of other tables if t contains references to them!
---
---```lua
---​-- Example:
---tableA={6,2,6}
---tableB={a=2,b=5,c=tableA}
---TABLE.clearR(tableB)
---print(TABLE.dump(TABLE.a))    -- tableA={}
---print(TABLE.dump(TABLE.b))    -- tableB={}
---​--To prevent issue like this, use TABLE.safeClearR
---```
function TABLE.clearR(t)
    assertf(type(t)=='table',"TABLE.clearR needs a table, but t's type is %s",type(t))
    for k in next,t do
        if type(t[k])=='table' then TABLE.clearR(t[k]) end
        t[k]=nil
    end
end

local string_find=string.find
---@param t table @ The table need to clear
---@param dangerousKeys string[]|string @ Which key is very dangerous to clear it recusively!
---@param regEx? false|boolean @ Enable using regEx to exclude keys (Only use this if the dangerousKey is a regEx string!)
---@param passR? false|boolean @ Passing dangerousKey when making recusive call?
---Clear table recusively but with protection to not accidentally clear the value of other tables
---```lua
---​-- Example:
---tableA={6,2,6}
---tableB={a=2,b=5,c=tableA}
---TABLE.clearR(tableB,'c')
---print(TABLE.dump(TABLE.a))    -- tableA={6,2,6}
---print(TABLE.dump(TABLE.b))    -- tableB={}
---```
function TABLE.safeClearR(t,dangerousKeys,regEx,passR)
    regEx=regEx or false
    passR=passR or false

    assertf(type(t)=='table',"TABLE.safeClearR needs a table, but t's type is %s",type(t))
    assertf(type(regEx)=='boolean',"TABLE.safeClearR.regEx is a boolean, got %s",type(regEx))
    assertf(
        type(dangerousKeys)=='string' or type(dangerousKeys)=='table',
        "TABLE.safeClearR.dangerousKeys needs a string if regEx is true OR table of string! Got %s",
        type(dangerousKeys)
    )

    for k in next,t do
        local isOkToClearRecusively=true
        if type(dangerousKeys)=='string' then
            dangerousKeys={dangerousKeys}
        end
        for _,dK in pairs(dangerousKeys) do
            if string_find(k,dK,1,not regEx) then
                isOkToClearRecusively=false
                break
            end
        end

        if isOkToClearRecusively and type(t[k])=='table' then
            if passR then
                TABLE.safeClearR(t[k],dangerousKeys,regEx,true)
            else
                TABLE.clearR(t[k])
            end
        end
        t[k]=nil
    end
end