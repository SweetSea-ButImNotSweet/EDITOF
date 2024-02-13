---@param w Zenitha.widget
---@param exportAs 'string'|'table'
---@return table
---Get all arguments of the provided widgets when using WIDGET.new()
---
---***NOTE:*** `exportAs=table` will return a table of strings!
local function dW (w,exportAs)
    if exportAs then
        assert(
            exportAs=='string' or exportAs=='table',
            "dumpWidget().exportAs must be 'string' or 'table'"
        )
    else
        exportAs='string'
    end

    if not w or not w.type then
        if exportAs=='table' then
            return {}
        elseif exportAs=='string' then
            return '{\n}'
        end
    end

    if exportAs=='table' then
        local l={}
        for _,v in pairs(WIDGET._prototype[w.type].buildArgs) do
            l[v]=w[v]
        end
        return l
    else
        local s='{\n'
        for _,k in pairs(WIDGET._prototype[w.type].buildArgs) do
            local type_wk=type(w[k])
            if type_wk=='string' then
                s=s..'\t'..k..'='..string.format('%q',w[k])..',\n' -- " --> \"
            elseif type_wk=='number' then
                s=s..'\t'..k..'='..w[k]..',\n'
            elseif type_wk=='boolean' then
                s=s..'\t'..k..'='..(w[k] and 'true' or 'false')..',\n'
            elseif type_wk=='nil' then
                s=s..'\t'..k..'=nil,\n'
            elseif type_wk=='table' then
                s=s..'\t'..k..'={\n'
                local dumpedT=STRING.split(TABLE.dump(w[k]),'\n')
                table.remove(dumpedT)
                table.remove(dumpedT,1)

                for K,V in pairs(dumpedT) do s=s..'\t\t'..K..'='..STRING.trim(V)..'\n' end
                s=s..'\t},\n'
            end
        end
        s=s..'}'
        return s
    end
end

return dW