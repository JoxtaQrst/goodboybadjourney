-- world generation settings
world_width = 96 -- world width in tiles
world_height = 32 -- world height in tiles
world = {}
difficulty = 0.2 -- difficulty level for traps (0 to 1)
placed_rooms = {} -- table to keep track of placed rooms

function boxes_overlap(ax,ay,aw,ah,bx,by,bw,bh)
    return not (ax+aw <= bx
            or bx+bw <= ax
            or ay+ah <= by
            or by+bh <= ay)
end

function generate_world()
    -- 1) clear & fill entire map with random floor (76 or 78)
    for y=0,world_height-1 do
        for x=0,world_width-1 do
        mset(x,y, (rnd()<0.5) and 76 or 78)
        end
    end

    -- 2) compute each room’s map‐cell size
    for r in all(rooms) do
        r.cell_w = r.w * 2
        r.cell_h = r.h * 2
    end

    -- 3) place room 3 at the origin
    local first = rooms[3]
    insert_room_at_map(first, 0, 0)
    placed_rooms = { first }

    -- set up our “cursor” and track row height
    local cx, cy, row_h = first.cell_w, 0, first.cell_h

    -- 4) build a list of the *other* rooms
    local unplaced = {}
    for r in all(rooms) do
        if r.id ~= first.id then add(unplaced, r) end
    end

    -- 5) while we still have rooms to place...
    while #unplaced > 0 do
        -- pick one at random
        local idx = flr(rnd(#unplaced)) + 1
        local room = unplaced[idx]

        -- if it doesn’t fit horizontally, wrap
        if cx + room.cell_w > world_width then
        cx = 0
        cy += row_h
        row_h = 0
        end
        -- if it doesn’t fit vertically either, stop
        if cy + room.cell_h > world_height then
        break
        end

        -- place it
        insert_room_at_map(room, cx, cy)
        add(placed_rooms, room)

        -- advance cursor & row height
        cx += room.cell_w
        row_h = max(row_h, room.cell_h)

        -- remove it from unplaced
        deli(unplaced, room)
    end

    -- 6) now you can spawn the player in `first` and do traps
    local px = first.dest_x + flr(first.cell_w/2)
    local py = first.dest_y + flr(first.cell_h/2)
    player.x = px*8 + (8-player.w)/2
    player.y = py*8 + (8-player.h)/2

    process_room_traps(first, difficulty)
    -- process traps for all placed rooms
    for _,room in ipairs(placed_rooms) do
        if room.id ~= first.id then
            process_room_traps(room, difficulty)
        end
    end
end



function process_room_traps(room, difficulty)
    for my = room.dest_y, room.dest_y + room.cell_h -1 do 
        for mx = room.dest_x, room.dest_x + room.cell_w -1 do
            local tile = mget(mx,my)
            -- only look at top-left corners
            -- if flag is 7 place spike trap
            -- if flag is 6 place dart trap
            if fget(tile, 7) then
                if rnd() < difficulty then
                    make_trap{type="spike", x=mx*8, y=my*8}
                end
            elseif fget(tile, 6) then
                if rnd() < difficulty then
                    local temp = {x=mx*8, y=my*8}
                    local dir = set_dart_direction(temp)
                    printh("Dart trap direction: " .. dir)
                    make_trap{type="dart", x=mx*8, y=my*8, direction=dir}
                end
                
            end
        end
    end
end

function draw_world()
    for y=0,world_height-1 do
        for x=0,world_width-1 do
        local t = mget(x,y)
        if t~=0 then
            spr(t, x*16, y*16, 2,2)
        end
        end
    end
end     

-- helper: returns true if `tile` has *any* flag (0–7) set
function has_any_flag(tile)
    for f=0,7 do
        if fget(tile,f) then
        return true
        end
    end
    return false
end

-- set of explicit ground tile‐indices
local ground_tiles = {
[76]=true, [77]=true, [78]=true, [79]=true,
[92]=true, [93]=true, [94]=true, [95]=true,
}

-- returns true if this neighbour is valid floor to face
function is_ground(tile)
    -- either no flags, or in your explicit list
    return (not has_any_flag(tile))
        and ground_tiles[tile]
end

-- choose one of the 4 directions whose neighbour passes is_ground()
function set_dart_direction(trap)
    local cx = flr(trap.x/8)
    local cy = flr(trap.y/8)

    local tries = {
        {dx=-1, dy= 0, dir="left"},
        {dx= 1, dy= 0, dir="right"},
        {dx= 0, dy=-1, dir="up"},
        {dx= 0, dy= 1, dir="down"},
    }

    for _,t in ipairs(tries) do
        local tx,ty = cx+t.dx, cy+t.dy
        local tile = mget(tx,ty)
        if is_ground(tile) then
        return t.dir
        end
    end

    -- fallback if none found
    return "down"
end

function overlaps_any(room,x,y)
    for pr in all(placed_rooms) do
        if boxes_overlap(
            x,y,room.cell_w,room.cell_h,
            pr.dest_x,pr.dest_y,pr.cell_w,pr.cell_h) then
            return true
        end
    end
    return false
end

function place_adjacent(room)
    for i=1,30 do    -- up to 30 random attempts
    local anchor = placed_rooms[flr(rnd(#placed_rooms))+1]
    local dir    = flr(rnd(4))  -- 0=right,1=left,2=down,3=up
    local nx,ny
    if dir==0 then
        -- to the right
        nx = anchor.dest_x + anchor.cell_w
        ny = anchor.dest_y + flr(rnd(anchor.cell_h - room.cell_h + 1))
    elseif dir==1 then
        -- to the left
        nx = anchor.dest_x - room.cell_w
        ny = anchor.dest_y + flr(rnd(anchor.cell_h - room.cell_h + 1))
    elseif dir==2 then
        -- below
        nx = anchor.dest_x + flr(rnd(anchor.cell_w - room.cell_w + 1))
        ny = anchor.dest_y + anchor.cell_h
    else
        -- above
        nx = anchor.dest_x + flr(rnd(anchor.cell_w - room.cell_w + 1))
        ny = anchor.dest_y - room.cell_h
    end
    -- bounds‐check
    if nx>=0
    and ny>=0
    and nx+room.cell_w <= world_width
    and ny+room.cell_h <= world_height
    and not overlaps_any(room,nx,ny)
    then
        local big_x = nx/2
        local big_y = ny/2
        insert_room(room,big_x,big_y)
        add(placed_rooms,room)
        return true
    end
    end

    return false
end


function insert_room_at_map(room, mx, my)
    room.dest_x = mx
    room.dest_y = my
    for dy=0,room.cell_h-1 do
        for dx=0,room.cell_w-1 do
        local t = mget(room.sx + dx, room.sy + dy)
        mset(mx + dx, my + dy, t)
        end
    end
    printh("Inserted room "..room.id.." at ("..mx..","..my..")")
end
