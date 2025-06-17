-- Room definitions (source coordinates in the reserved area)
rooms = {
    { id = 1, sx = 96,  sy = 0,   w = 6, h = 7 },
    { id = 2, sx = 108,  sy = 0,   w = 6, h = 7 },
    { id = 3, sx = 120, sy = 0 , w = 4 , h = 7},
    { id = 4, sx = 96, sy = 14, w = 9, h = 7}
}


function insert_room(room, dest_big_x, dest_big_y)
    -- convert from “big tiles” → 8×8 map cells
    local dst_x  = dest_big_x * 2
    local dst_y  = dest_big_y * 2
    local cell_w = room.w * 2
    local cell_h = room.h * 2

    -- store them on the room object
    room.dest_x  = dst_x
    room.dest_y  = dst_y
    room.cell_w  = cell_w
    room.cell_h  = cell_h

    -- copy the tiles
    for cy=0,cell_h-1 do
        for cx=0,cell_w-1 do
        local t = mget(room.sx + cx, room.sy + cy)
        mset(dst_x + cx,  dst_y + cy,  t)
        end
    end
    printh("Inserted room "..room.id.." at map-cell ("..dst_x..","..dst_y..") size "..cell_w.."×"..cell_h)
end
