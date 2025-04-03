
function _init()
    init_traps()
    printh("Booting up...")
    health = 3
    current_level = 1 -- current level
    timer = 0
end

-- Pico-8 main loop functions
function _update()
    update_player()
    update_traps()
    update_darts()
    update_timer()
end

function _draw()
    cls()  -- clear the screen
    
    map(0,0)
    draw_traps()
    draw_darts()
    draw_player()
    draw_ui()
end