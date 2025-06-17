game_state = "playing"
difficulty = 0.2 -- difficulty level for traps
owner = {
    x = 0,
    y = 0,
    w = 16,
    h = 16,
    sprites = {192,194},
    frame   = 1,
    timer   = 0,
    delay   = 30,   -- frames between sprite changes
}
-- at the top, pick your constants
local BGM_ROW      = 0    -- start of your background track
local BGM_LEN      = 24   -- number of patterns in the loop
local WIN_ROW      = 25   -- start of your win tune
local WIN_LEN      = 20   -- length of the win tune (44−25+1)
-- screen-shake
local shake_timer = 0
local SHAKE_DURATION = 12
local SHAKE_MAG      = 2
local played_win_music = false



function _init()
    generate_world() -- generate the world
    local goal = placed_rooms[#placed_rooms]
    owner.x = (goal.dest_x + flr(goal.cell_w/2)) * 8 - owner.w/2
    owner.y = (goal.dest_y + flr(goal.cell_h/2)) * 8 - owner.h/2
    --init_traps()
    printh("Booting up...")
    health = 3
    current_level = 1 -- current level
    timer = 0
    music(BGM_ROW,        -- which row to start
        0,              -- fade length
        0b1111,         -- channel mask (all 4 channels)
        BGM_ROW,        -- loop start
        BGM_LEN)        -- loop length
    printh("Music started at row " .. BGM_ROW .. " with length " .. BGM_LEN)
end

-- Pico-8 main loop functions
function _update()
    if game_state == "playing" then
        update_player()
        update_traps()     -- from traps.lua
        update_darts()     -- from traps.lua
        update_owner()
        update_vfx()

        if rect_collide_margin(
            player.x, player.y, player.w, player.h,
            owner.x, owner.y, owner.w, owner.h, 0) then
            game_state = "win"
            printh("You found your owner!")
            -- stop the old loop and kick off the win tune exactly once
            music(-1)
            music(WIN_ROW, 0, 0b1111, WIN_ROW, WIN_LEN)
            played_win_music = true
        end

        check_trap_collisions()  -- from player.lua
        update_timer()
        update_camera()
        check_game_over()  -- Check if player's life has reached 0
        
    elseif game_state == "game_over" then
        -- Wait for the player to press the x button (typically btnp(5) in Pico-8)
        if btnp(5) then
            restart_game()
        end
    elseif game_state == "win" then
        -- Wait for the player to press the x button (typically btnp(5) in Pico-8)
        if btnp(5) then
            restart_game()
        end
    end
end

function _draw()
    if game_state == "playing" then
        cls(0)
        -- world stuff is still under camera:
        map(0, 0, 0, 0, world_width, world_height)
        draw_traps()
        draw_darts()
        draw_owner()
        draw_player()
        draw_vfx()

        -- now snap camera back to origin for your UI:
        camera(0, 0)
        draw_ui()

    elseif game_state=="game_over" then
        camera(0, 0)
        draw_game_over()
        draw_ui()

    elseif game_state=="win" then
        camera(0, 0)
        draw_win()
        draw_ui()
    end
end


function check_game_over()
    if player.life <= 0 then
        game_state = "game_over"
        printh("Game Over!")
    end
end

function draw_game_over()
    -- draw a black rectangle in the middle of the screen
    rectfill(16, 16, 112, 112, 1)
    rect(16, 16, 112, 112, 5)
    print ("game over!", 40,50,7)
    print ("you died :( ", 40,60,7)
    -- sad dog sprite
    spr(9,56,30,2,2)
    print(" want to try again?", 25,70,7)
    print(" press x to restart", 25,80,7)
end

function draw_win()
    -- draw a black rectangle in the middle of the screen
    rectfill(16, 16, 112, 112, 1)
    rect(16, 16, 112, 112, 5)
    print ("you win!", 40,50,7)
    print ("you found him! ", 40,60,7)
    -- happy dog sprite
    spr(11,56,30,2,2)
    print(" want to try again?", 25,70,7)
    print(" press x to restart", 25,80,7)
end

-- This function resets the game (restart) when the player presses x
function restart_game()
    game_state = "playing"
    -- Reset player properties
    player.life = player.max_life
    player.x = 7
    player.y = 5
    player.idle_timer = 0
    player.fade_progress = 0
    player.invincibility_timer = 0
    init_traps()
    timer = 0
    -- reset player, traps, etc…
    music(BGM_ROW,        -- start row
            0,              -- fade length
            0b1111,         -- all channels
            BGM_ROW,        -- loop start
            BGM_LEN)        -- loop length
    played_win_music = false
end

-- animate the owner
function update_owner()
    owner.timer += 1
    if owner.timer >= owner.delay then
        owner.timer = 0
        owner.frame = (owner.frame % 2) + 1
    end
end

-- draw the owner
function draw_owner()
    local spr_id = owner.sprites[owner.frame]
    spr(spr_id, owner.x, owner.y, 2, 2)
end
