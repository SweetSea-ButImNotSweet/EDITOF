local string_format=string.format

local step2
local function step1(key,val,tab)
    local tab_ident=''
    if not tab then tab=1 end
    for _=1,tab do tab_ident=tab_ident..'\t' end  -- general_handling

    key=step2(key,tab_ident,tab,true)
    
    if (key:lower()):find('color',1,true) then
        val=string_format('COLOR.hex\'%s\'',COLOR.rgb2hex(unpack(val)))
    else
        val=step2(val,tab_ident,tab)
    end


    return string_format('%s%s=%s',tab_ident,key,val)
end

step2=function(s,tab_ident,tab,isKey)
    local type_s=type(s)

    if type_s=='boolean' then
        return s and 'true' or 'false'
    elseif type_s=='nil' then
        return 'nil'
    elseif type_s=='table' then
        local temp='{\n'
        for k,v in pairs(s) do
            temp=temp..step1(k,v,tab+1)..',\n'
        end
        return temp..tab_ident..'}'
    elseif (        -- " --> \"
        type_s=='string' and
        string.find(s, '[^A-Za-z0-9_]')
    ) then
        return string_format(isKey and '[%q]' or '%q', s)
    else
        return tostring(s)
    end
end


---@param w Zenitha.widget
---@param exportAs "'string'"|"'table'"
---@return result table
---Get all arguments of the provided widgets when using WIDGET.new()
return function (w,exportAs)
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
        result=string_format('%s%s,\n',result,step1('type',w.type,1))
        for _,k in pairs(originalW.buildArgs) do
            if w[k]~=originalW[k] then
                result=string_format('%s%s,\n',result,step1(k,w[k],1))
            end
        end
        result=result..'}'
        return result
    end
end