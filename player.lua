
-- define player object

-- define player object
player = {
    x = 56,  -- starting x position
    y = 56,  -- starting y position
    speed = 1,  -- movement speed

    -- Sprite settings
    sprite_normal = {1,3},       -- idle state when not moving (visible)
    sprite_moving = {5,7},       -- moving animation sprites
    sprite_invisible = {33,35},  -- idle state when fully invisible

    current_frame = 1,         -- current frame of animation
    frame_timer = 0,           -- timer for frame animation
    frame_delay_idle = 20,     -- delay between frames when idle
    frame_delay_moving = 10,   -- delay between frames when moving
    state = "idle",
    idle_timer = 0,            -- count how many frames player has been idle
    dir = "right"              -- direction
}

-- update player state
function update_player()
    local moving = false

    -- Check direction input {left = 0, right = 1, up = 2, down = 3}
    if (btn(0)) then 
        player.x = player.x - player.speed 
        moving = true 
        player.dir = "left"
    end
    if (btn(1)) then 
        player.x = player.x + player.speed 
        moving = true 
        player.dir = "right"
    end
    if (btn(2)) then 
        player.y = player.y - player.speed 
        moving = true 
    end
    if (btn(3)) then 
        player.y = player.y + player.speed 
        moving = true 
    end

    -- set state and determine animation delay
    local current_delay = player.frame_delay_idle
    if moving then
        player.state = "moving"
        player.idle_timer = 0 -- reset timer when moving
        current_delay = player.frame_delay_moving
    else
        player.state = "idle"
        player.idle_timer = player.idle_timer + 1
    end

    -- update animation frame timer
    player.frame_timer = player.frame_timer + 1
    if player.frame_timer >= current_delay then
        player.frame_timer = 0
        -- cycle between frame 1 and 2
        player.current_frame = (player.current_frame % 2) + 1
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
end