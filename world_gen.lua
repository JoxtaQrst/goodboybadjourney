-- world_gen.lua
-- world generation settings
world_width = 96 -- world width in map-cells
world_height = 32 -- world height in map-cells
world = {}
placed_rooms = {}
difficulty = 0.4 -- trap spawn chance (0.0 to 1.0)

-- helper: check AABB overlap in map-cells
function overlaps_any(room, x, y)
    for pr in all(placed_rooms) do
        if not (
            x + room.cell_w <= pr.dest_x or
            pr.dest_x + pr.cell_w <= x or
            y + room.cell_h <= pr.dest_y or
            pr.dest_y + pr.cell_h <= y
        ) then
            return true
        end
    end
    return false
end

-- stamp a room onto the map at map-cell coords (mx,my)
function insert_room_at_map(room, mx, my)
    room.dest_x = mx
    room.dest_y = my
    room.cell_w = room.w * 2
    room.cell_h = room.h * 2
    for dy = 0, room.cell_h - 1 do
        for dx = 0, room.cell_w - 1 do
            local t = mget(room.sx + dx, room.sy + dy)
            mset(mx + dx, my + dy, t)
        end
    end
    printh("Inserted room " .. room.id .. " at ("..mx..","..my..") size "..room.cell_w.."x"..room.cell_h)
end

-- determine dart firing direction by scanning ahead up to N cells for floor tiles
function set_dart_direction(px, py)
    local cx = flr(px / 8)
    local cy = flr(py / 8)
    local tries = {
        {dx=-1, dy=0, dir="left"},
        {dx= 1, dy=0, dir="right"},
        {dx= 0, dy=-1, dir="up"},
        {dx= 0, dy= 1, dir="down"},
    }
    local max_dist = 4
    -- for each direction, look ahead up to max_dist cells
    for _,t in ipairs(tries) do
        for d=1, max_dist do
            local tx = cx + t.dx * d
            local ty = cy + t.dy * d
            if mget(tx, ty) == 76 then
                return t.dir
            end
        end
    end
    -- fallback if no floor found in any direction
    return "down"
end


-- scatter traps in a room by scanning each top-left corner of 2x2 flagged areas
function process_room_traps(room, difficulty)
    for my = room.dest_y, room.dest_y + room.cell_h - 2, 2 do
        for mx = room.dest_x, room.dest_x + room.cell_w - 2, 2 do
            local tile = mget(mx, my)
            -- spike markers (flag 7)
            if fget(tile, 7) then
                if rnd() < difficulty then
                    make_trap{type="spike", x = mx * 8, y = my * 8}
                else
                    -- clear 2x2 marker
                    local ft = 76
                    mset(mx,     my,     ft)
                    mset(mx + 1, my,     ft)
                    mset(mx,     my + 1, ft)
                    mset(mx + 1, my + 1, ft)
                end
            end

            -- dart markers (flag 6)
            if fget(tile, 6) then
                if rnd() < difficulty then
                    local px, py = mx * 8, my * 8
                    local dir = set_dart_direction(px, py)
                    make_trap{type="dart", x = px, y = py, direction = dir}
                else
                    -- failed dart: stamp 66
                    local dt = 66
                    mset(mx,     my,     dt)
                    mset(mx + 1, my,     dt)
                    mset(mx,     my + 1, dt)
                    mset(mx + 1, my + 1, dt)
                end
            end
        end
    end
end

-- main world generator
function generate_world()
    -- fill map with default floor tile
    for y = 0, world_height - 1 do
        for x = 0, world_width - 1 do
            mset(x, y, 76)
        end
    end

    -- compute each room's footprint in map-cells
    for r in all(rooms) do
        r.cell_w = r.w * 2
        r.cell_h = r.h * 2
    end

    -- 1) place the first room at origin (safe spawn)
    local first = rooms[1]
    insert_room_at_map(first, 0, 0)
    placed_rooms = { first }

    -- 2) build a list of remaining rooms and shuffle
    local unplaced = {}
    for i = 2, #rooms do add(unplaced, rooms[i]) end

    -- 3) place shuffled rooms side-by-side on the top row
    local cursor_x = first.cell_w
    while #unplaced > 0 do
        local idx = flr(rnd(#unplaced)) + 1
        local r = deli(unplaced, idx)
        if cursor_x + r.cell_w > world_width then break end
        insert_room_at_map(r, cursor_x, 0)
        add(placed_rooms, r)
        cursor_x += r.cell_w
    end

    -- 4) spawn the player in the center of the first room
    local px = 7
    local py = 5
    player.x = px * 8 + (8 - player.w) / 2
    player.y = py * 8 + (8 - player.h) / 2

    -- 5) spawn the owner in the center of the last room
    local last = placed_rooms[#placed_rooms]
    owner.x = (last.dest_x + flr(last.cell_w / 2)) * 8 - owner.w / 2
    owner.y = (last.dest_y + flr(last.cell_h / 2)) * 8 - owner.h / 2

    -- 6) process traps in every placed room
    for r in all(placed_rooms) do
        process_room_traps(r, difficulty)
    end
    -- add a decorative border:
    -- horizontal line y=16 from x=0 to 64 using tiles {64,68,70} randomly
    for x=0,64 do
        local tset = {64,68,70}
        mset(x,16,tset[flr(rnd(#tset))+1])
    end
    -- vertical line x=64 from y=0 to 14 using tile 66
    for y=0,14 do
        -- the tile 66 is a 2x2 wall tile, so it must draw 4 1x1 tiles starting from tile 66
        mset(50, y, 66)
        mset(51, y, 66)
        mset(50, y + 1, 66)
        mset(51, y + 1, 66)
    end
end
