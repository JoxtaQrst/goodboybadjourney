-- trap system
traps = {}
dart_projectiles = {}
dart_speed = 2

function init_traps()
    traps = {}
    add(traps,
    {
        number = 1,
        x=80,
        y=80,
        type="spike",
        timer = 0 ,
        cycle = 120, -- total frames for full cycle ( inactive + active )
        active_duration = 60, -- frames active
        active = false, -- is the trap active?
        inactive_sprite = 169, -- sprite for inactive trap
        active_sprite = 171, -- sprite for active trap

    })
    -- Dart trap example (16x16 base, scales by 2)
    add(traps, {
        number = 2,
        x = 12,
        y = 0,
        type = "dart",
        timer = 0,
        cycle = 120,
        active_duration = 60,
        active = false,
        -- The trap's base sprite will depend on the shooting direction:
        -- up: 100, left: 102, right: 104, down: 106.
        direction = "down",
        fired = false  -- flag to ensure the trap fires only once per active phase
    })
    add(traps, {
        number = 3,
        x = 0,
        y = 60,
        type = "dart",
        timer = 0,
        cycle = 120,
        active_duration = 60,
        active = false,
        direction = "up",
        fired = false
    })
    add(traps, {
        number = 4,
        x = 50,
        y = 80,
        type = "dart",
        timer = 0,
        cycle = 120,
        active_duration = 60,
        active = false,
        direction = "right",
        fired = false
    })
    add(traps, {
        number = 5,
        x = 30,
        y = 50,
        type = "dart",
        timer = 0,
        cycle = 120,
        active_duration = 60,
        active = false,
        direction = "left",
        fired = false
    })
end

-- update trap states   ( spikes and darts)
function update_traps()
    for trap in all(traps) do 
        trap.timer = trap.timer + 1
        if trap.timer >= trap.cycle then
            trap.timer = 0
            if trap.type == "dart" then
                trap.fired = false -- reset firing flag for next cycle
            end
        end 

        -- activ if within the first active_duration frames of the cycle
        trap.active = trap.timer <trap.active_duration

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