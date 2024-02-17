local abs=math.abs

---@param x number
---@param low number
---@param high number
---@return number
---Wraps a number x within a closed range defined by ``low`` and ``high``
function MATH.wrap(x,low,high)
    local gap=abs(high-low+1)
    if x<low or x>high then return low+(x-low)%gap else return x end
end