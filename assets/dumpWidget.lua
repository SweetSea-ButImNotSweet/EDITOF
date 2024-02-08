return function (widgetFromInput)
    -- local buildArgs=WIDGET._prototype[widgetFromInput.type].buildArgs
    -- return TABLE.dump(buildArgs)

    local w=setmetatable(TABLE.copy(widgetFromInput),debug.getmetatable(widgetFromInput))
    -- P/s: we need to ignore the __metamethod__ so we can get the correct thing we need
end