-- collision functions

function collide_map(obj, aim, flag)
-- how many pixels to inset on each side
local margin = 5

-- compute an inner rectangle [x..x+w) × [y..y+h)
local ix = obj.x + margin
local iy = obj.y + margin
local iw = obj.w - margin*2
local ih = obj.h - margin*2

-- now pick two sample points on the edge you’re moving toward
local x1,y1,x2,y2
if aim=="left" then
    x1 = ix - 1
    y1 = iy
    x2 = ix - 1
    y2 = iy + ih - 1

elseif aim=="right" then
    x1 = ix + iw
    y1 = iy
    x2 = ix + iw
    y2 = iy + ih - 1

elseif aim=="up" then
    x1 = ix
    y1 = iy - 1
    x2 = ix + iw - 1
    y2 = iy - 1

elseif aim=="down" then
    x1 = ix
    y1 = iy + ih
    x2 = ix + iw - 1
    y2 = iy + ih
end

-- convert to map‐tile coords
x1,y1 = flr(x1/8), flr(y1/8)
x2,y2 = flr(x2/8), flr(y2/8)

-- if either corner is solid, block
if fget(mget(x1,y1), flag)
or fget(mget(x1,y2), flag)
or fget(mget(x2,y1), flag)
or fget(mget(x2,y2), flag) then
    return true
end

return false
end
