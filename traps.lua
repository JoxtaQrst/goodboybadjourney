-- trap system
traps = {}
dart_projectiles = {}
dart_speed = 2

function init_traps()
    -- iterate through existing traps and print their details
    for trap in all(traps) do
        if trap.type == "spike" then
            printh("Spike trap at ("..trap.x..","..trap.y..") active: "..tostr(trap.active))
        elseif trap.type == "dart" then
            printh("Dart trap at ("..trap.x..","..trap.y..") direction: "..trap.direction.." active: "..tostr(trap.active))
        end
    end

    -- Add a spike trap
    -- add(traps,
    -- {
    --     number = 1,
    --     x=80,
    --     y=80,
    --     type="spike",
    --     timer = 0 ,
    --     cycle = 120, -- total frames for full cycle ( inactive + active )
    --     active_duration = 60, -- frames active
    --     active = false, -- is the trap active?
    --     inactive_sprite = 169, -- sprite for inactive trap
    --     active_sprite = 171, -- sprite for active trap
    -- })

    -- Add a dart trap
    -- add(traps, {
    --     number = 2,
    --     x = 12,
    --     y = 0,
    --     type = "dart",
    --     timer = 0,
    --     cycle = 120, -- total frames for full cycle (inactive + active)
    --     active_duration = 60, -- frames active
    --     active = false, -- is the trap active?
    --     direction = "down", -- direction the dart will fire
    --     fired = false  -- flag to ensure the trap fires only once per active phase
    -- })
end

function make_trap(o)
    assert(o.type=="spike" or o.type=="dart","make_trap: bad type")
    local t = {
        type            = o.type,
        x               = o.x or 0,
        y               = o.y or 0,
        timer           = o.type=="spike"
                        and flr(rnd(o.cycle or 120))
                        or (o.timer or 0),
        cycle           = o.cycle or 120,
        active_duration = o.active_duration or 60,
        active          = false,
    }
    if o.type=="spike" then
        -- defaults for spike
        t.inactive_sprite = o.inactive_sprite or 169
        t.active_sprite   = o.active_sprite   or 171
    
    else -- dart
        -- defaults for dart trap (the turret base)
        t.direction = o.direction or "down"
        t.fired     = false
    end
    printh("Adding trap "..t.type.." at ("..t.x..","..t.y.."), active: "..tostr(t.active))
    add(traps,t)
    return t
end
-- update trap states   ( spikes and darts)
function update_traps()
    for trap in all(traps) do 
        -- if trap.timer is nil, default it to 0, then add 1
        trap.timer = (trap.timer or 0) + 1

        -- likewise guard trap.cycle
        local cycle = trap.cycle or 120
        if trap.timer >= cycle then
        trap.timer = 0
        if trap.type == "dart" then
            trap.fired = false
        end
        end

        -- guard active_duration too
        local adur = trap.active_duration or 60
        trap.active = trap.timer < adur

        if trap.type == "dart" then
            if trap.active and not trap.fired then
                -- spawn a dart projectile when the trap first becomes active
                local dart_x, dart_y
                local dart_sprite = 0
                if trap.direction == "left" then
                    dart_sprite = 129
                    dart_x = trap.x
                    dart_y = trap.y + 4 -- adjust dart position to center
                elseif trap.direction == "right" then
                    dart_sprite = 130
                    dart_x = trap.x + 16
                    dart_y = trap.y + 4
                elseif trap.direction == "up" then
                    dart_sprite = 145
                    dart_x = trap.x + 4
                    dart_y = trap.y
                elseif trap.direction == "down" then
                    dart_sprite = 146
                    dart_x = trap.x + 4 -- adjust dart position to center
                    dart_y = trap.y + 8 -- adjust dart position to center
                end

                add(dart_projectiles, {
                    x = dart_x,
                    y = dart_y,
                    direction = trap.direction,
                    sprite = dart_sprite
                })
                trap.fired = true -- ensure only one dart is fired per activation
            end
        end
    end
end

-- update dart projectiles

function update_darts()
    for i = #dart_projectiles, 1, -1 do 
        local dart = dart_projectiles[i]
        if dart.direction == "left" then
            dart.x -= dart_speed
        elseif dart.direction == "right" then
            dart.x += dart_speed
        elseif dart.direction == "up" then
            dart.y -= dart_speed
        elseif dart.direction == "down" then
            dart.y += dart_speed
        end

        -- remove dart if it goes off-screen or hits a wall
        if dart.x < 0 or dart.x > 128 or dart.y < 0 or dart.y > 128 then
            del(dart_projectiles, dart)
        end
    end
end

-- draw traps
function draw_traps()
    for trap in all(traps) do
        if trap.type == "dart" then
            local spr_num = choose_dart_sprite(trap)
            spr(spr_num, trap.x, trap.y, 2, 2)
        elseif trap.type == "spike" then
            local spr_num = trap.inactive_sprite
            if trap.active then
                spr_num = trap.active_sprite
            end
            -- draw sprite at trap.x,trapy with 16x16 size
            spr(spr_num,trap.x,trap.y,2,2,false,false)
            --printh("trap "..trap.number.." active: "..tostr(trap.active))
        end
    end
end

function draw_darts()
    for dart in all(dart_projectiles) do
        spr(dart.sprite, dart.x, dart.y, 1, 1)
    end
end

function choose_dart_sprite(trap)
    if trap.direction == "left" then
        return 163
    elseif trap.direction == "right" then
        return 165
    elseif trap.direction == "up" then
        return 161
    elseif trap.direction == "down" then
        return 167
    end
end