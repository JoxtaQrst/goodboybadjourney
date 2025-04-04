game_state = "playing"

function _init()
    generate_world() -- generate the world
    init_traps()
    printh("Booting up...")
    health = 3
    current_level = 1 -- current level
    timer = 0
end

-- Pico-8 main loop functions
function _update()
    if game_state == "playing" then
        update_player()
        update_traps()     -- from traps.lua
        update_darts()     -- from traps.lua
        check_trap_collisions()  -- from player.lua
        update_timer()
        update_camera()
        check_game_over()  -- Check if player's life has reached 0
    elseif game_state == "game_over" then
        -- Wait for the player to press the x button (typically btnp(5) in Pico-8)
        if btnp(5) then
            restart_game()
        end
    end
end

function _draw()
    if game_state == "playing" then
        cls(0)
        draw_world() -- draw the world
        draw_traps()
        draw_darts()
        draw_player()
        draw_ui()
    elseif game_state == "game_over" then
        draw_game_over()
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
    print ("game Over!", 40,50,7)
    print ("you died :( ", 40,60,7)
    -- sad dog sprite
    spr(9,56,30,2,2)
    print(" want to try again?", 25,70,7)
    print(" press x to restart", 25,80,7)
end

-- This function resets the game (restart) when the player presses x
function restart_game()
    game_state = "playing"
    -- Reset player properties
    player.life = player.max_life
    player.x = 56
    player.y = 56
    player.idle_timer = 0
    player.fade_progress = 0
    player.invincibility_timer = 0
    init_traps()
    timer = 0
end