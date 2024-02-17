local allModules={'color','math','table'}
for _,m in pairs(allModules) do
    require('ZenithaExtended.'..m)
end