-- world generation settings
world_width = 16 -- world width in tiles
world_height = 16 -- world height in tiles
world = {}

-- generate world
function generate_world()
    for y = 1, world_height do 
        world[y] = {}
        for x = 1, world_width do 
            if rnd(1) < 0.5 then
                world[y][x] = 76
            else
                world[y][x] = 78
            end
        end 
    end 
end 

-- draw world
function draw_world()
    for y=1, world_height do 
        for x=1, world_width do 
            local tile = world[y][x]
            local screen_x = (x-1) * 16
            local screen_y = (y-1) * 16
            spr(tile, screen_x, screen_y, 2, 2)
        end
    end
end