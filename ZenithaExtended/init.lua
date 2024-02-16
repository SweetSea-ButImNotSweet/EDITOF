local allModules={'color','table'}
for _,m in pairs(allModules) do
    require('ZenithaExtended.'..m)
end