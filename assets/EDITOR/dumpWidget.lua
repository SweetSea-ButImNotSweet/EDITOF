local string_format=string.format

local function KV_handling(key,value,tab,isKey)
    local type_k=type(key)
    local type_v=type(value)
    local result_k,result_v

    local indent_str=''
    tab=tab or 1
    for _=1,tab do indent_str=indent_str..'\t' end -- general_handling

    if type_k=='string' and string.find(key,'[^A-Za-z0-9_]') then
        result_k=string_format('[%q]',key)
    else
        result_k=key
    end

    if type_v=='boolean' then
        result_v=value and 'true' or 'false'
    elseif type_v=='nil' then
        result_v='nil'
    elseif type_v=='table' then
        local temp='{\n'
        for k,v in pairs(value) do
            local _k,_v=KV_handling(k,v,tab+1)
            temp=temp.._k..'='.._v..',\n'
        end
        result_v=temp..indent_str..'}'
    elseif type_v=='number' then
        result_v=value
    else
        result_v=tostring(value)
    end

    return indent_str..result_k,result_v
end


---@param w Zenitha.widget
---@param exportAs "'string'"|"'table'"
---@return table|string
---Get all arguments of the provided widgets when using WIDGET.new()
return function(w,exportAs)
    exportAs=exportAs or 'string'
    assert(exportAs=='string' or exportAs=='table',"dumpWidget().exportAs must be 'string' or 'table'")

    if not w or not w.type then
        if exportAs=='table' then return {} else return '{\n}' end
    end

    local originalW=WIDGET._prototype[w.type]

    if exportAs=='table' then
        local l={type=w.type}
        for _,v in pairs(originalW.buildArgs) do l[v]=w[v] end
        return l
    else
        local result='{\n'
        for _,k in pairs(originalW.buildArgs) do
            if w[k]~=originalW[k] and not TABLE.find({'function','thread','userdata'},type(w[k]))
            then
                local _k,_v=KV_handling(k,w[k],1)
                result=result.._k..'='.._v..',\n'
            end
        end
        result=result..'}'
        return result
    end
end