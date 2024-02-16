local string_format=string.format

local general_handling
local function dump(key,val,tab)
    local tab_ident=''
    if not tab then tab=1 end
    for _=1,tab do tab_ident=tab_ident..'\t' end  -- general_handling

    key=general_handling(key,tab_ident,tab)
    
    if (key:lower()):find('color',1,true) then
        val=string_format('COLOR.hex\'%s\'',COLOR.rgb2hex(unpack(val)))
    else
        val=general_handling(val,tab_ident,tab)
    end


    return string_format('%s[%s]=%s',tab_ident,key,val)
end

general_handling=function(s,tab_ident,tab)
    local type_s=type(s)
    local result

    if type_s=='number' then
        result=s
    elseif type_s=='boolean' then
        result=s and 'true' or 'false'
    elseif type_s=='nil' then
        result='nil'
    elseif type_s=='table' then
        local temp='{\n'
        for k,v in pairs(s) do
            temp=temp..dump(k,v,tab+1)..',\n'
        end
        result=temp..tab_ident..'}'
    else
        result=string_format('%q',s) -- " --> \"
    end
    return result
end


---@param w Zenitha.widget
---@param exportAs 'string'|'table'
---@return table
---Get all arguments of the provided widgets when using WIDGET.new()
return function (w,exportAs)
    exportAs=exportAs or 'string'
    assert(exportAs=='string' or exportAs=='table',"dumpWidget().exportAs must be 'string' or 'table'")

    if not w or not w.type then
        if exportAs=='table' then return {} else return '{\n}' end
    end

    local originalW=WIDGET._prototype[w.type]

    if exportAs=='table' then
        local l={}
        for _,v in pairs(originalW.buildArgs) do l[v]=w[v] end
        return l
    else
        local result='{\n'
        for _,k in pairs(originalW.buildArgs) do
            if w[k]~=originalW[k] then
                result=string_format('%s%s,\n',result,dump(k,w[k],1))
            end
        end
        result=result..'}'
        return result
    end
end