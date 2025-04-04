-- define player object

-- tile flags
wall_flag = 0
trap_flag = 1

player = {
    life = 3,
    max_life = 3,
    x = 56,  -- starting x position
    y = 56,  -- starting y position
    speed = 1,  -- movement speed
    w = 16,
    h = 16,  -- width and height of player sprite

    -- Sprite settings
    sprite_normal = {1,3},       -- idle state when not moving (visible)
    sprite_moving = {5,7},       -- moving animation sprites
    sprite_invisible = {33,35},  -- idle state when fully invisible

    current_frame = 1,         -- current frame of animation
    invincibility_timer = 0, -- timer for invincibility frames
    frame_timer = 0,           -- timer for frame animation
    frame_delay_idle = 20,     -- delay between frames when idle
    frame_delay_moving = 10,   -- delay between frames when moving
    state = "idle",
    idle_timer = 0, 
    fade_progress = 0,           -- count how many frames player has been idle
    dir = "right"              -- direction
}

-- update player state
function update_player()
    local moving = false
    local current_delay = player.frame_delay_idle

    -- Check direction input {left = 0, right = 1, up = 2, down = 3}
    if (btn(0)) then 
        if not collide_map(player, "left", wall_flag) then
            player.x = player.x - player.speed 
        end
        moving = true 
        player.dir = "left"
    end
    if (btn(1)) then 
        if not collide_map(player, "right", wall_flag) then
            player.x = player.x + player.speed 
        end
        moving = true 
        player.dir = "right"
    end
    if (btn(2)) then 
        if not collide_map(player, "up", wall_flag) then
            player.y = player.y - player.speed 
        end
        moving = true 
    end
    if (btn(3)) then 
        if not collide_map(player, "down", wall_flag) then
            player.y = player.y + player.speed 
        end
        moving = true 
    end

    if moving then
        player.state = "moving"
        player.idle_timer = 0  -- reset idle timer when moving
        player.fade_progress = 0
        current_delay = player.frame_delay_moving
    else
        player.state = "idle"
        player.idle_timer = player.idle_timer + 1
        if player.idle_timer > 30 then
            player.fade_progress = (player.idle_timer - 30) / 30
            if player.fade_progress > 1 then player.fade_progress = 1 end
        else
            player.fade_progress = 0
        end
    end

    -- Update animation frame timer
    player.frame_timer = player.frame_timer + 1
    if player.frame_timer >= current_delay then
        player.frame_timer = 0
        player.current_frame = (player.current_frame % 2) + 1
    end

    player.frame_timer = player.frame_timer + 1
    if player.frame_timer >= current_delay then
        player.frame_timer = 0
        player.current_frame = (player.current_frame % 2) + 1
    end

    -- Decrement invincibility timer if active.
    if player.invincibility_timer > 0 then
        player.invincibility_timer = player.invincibility_timer - 1
    end
end

function draw_player()
    local chosen_sprite_set

    if player.state == "moving" then
        -- Use moving animation sprites (5 and 7) when moving
        chosen_sprite_set = player.sprite_moving
    else
        -- Default to normal idle sprites
        chosen_sprite_set = player.sprite_normal

        local fade_progress = 0
        -- After 1 second (30 frames) start fading over the next 30 frames:
        if player.idle_timer > 30 then  
            fade_progress = (player.idle_timer - 30) / 30
            if fade_progress > 1 then fade_progress = 1 end
        end
        -- As fade_progress increases, the chance to use the invisible sprite set increases.
        if fade_progress > 0 and rnd(1) < fade_progress then
            chosen_sprite_set = player.sprite_invisible
        end
    end

    local spr_index = chosen_sprite_set[player.current_frame]
    -- Determine horizontal flip: true if player.dir is "left"
    local flip_x = (player.dir == "left")
    spr(spr_index, player.x, player.y, 2, 2, flip_x, false)

    if player.invincibility_timer > 0 then
        -- Alternate between white and the normal sprite:
        if (player.invincibility_timer % 6) < 3 then
            -- Remap entire palette to white (color 7)
            for c = 0, 15 do
                pal(c, 7)
            end
            spr(spr_index, player.x, player.y, 2, 2, flip_x, false)
            pal() -- reset palette mapping
        else
            spr(spr_index, player.x, player.y, 2, 2, flip_x, false)
        end
    else
        spr(spr_index, player.x, player.y, 2, 2, flip_x, false)
    end
end

function update_camera()
    local region_x = flr(player.x / 128)
    local region_y = flr(player.y / 128)
    local cam_x = region_x * 128
    local cam_y = region_y * 128
    camera(cam_x, cam_y)
end

-- Rectangle collision helper
function rect_collide(ax, ay, aw, ah, bx, by, bw, bh)
    return not (ax + aw < bx or ax > bx + bw or ay + ah < by or ay > by + bh)
end

-- Reduce player life when damage is taken
function damage_player()
    if player.invincibility_timer > 0 then
        return
    end
    player.life = player.life - 1
    player.invincibility_timer = 30  -- Set invincibility timer (30 frames)
    printh("Player damaged! Life: " .. player.life)
end

-- Check collisions between the player and traps/dart projectiles.
function check_trap_collisions()
    -- Only check for damage if the player isn't fully invisible.
    if player.fade_progress >= 1 then
        return
    end

    -- Check collision with spike traps (16x16)
    for trap in all(traps) do
        if trap.type == "spike" and trap.active then
            if rect_collide(player.x, player.y, player.w, player.h, trap.x, trap.y, 16, 16) then
                damage_player()
            end
        end
    end

    -- Check collision with dart projectiles (8x8)
    for dart in all(dart_projectiles) do
        if rect_collide(player.x, player.y, player.w, player.h, dart.x, dart.y, 8, 8) then
            damage_player()
            del(dart_projectiles, dart)  -- Remove the dart after collision
        end
    end
end
