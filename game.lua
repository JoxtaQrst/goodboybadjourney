-- Pico-8 main loop functions
function _update()
    update_player()
end

function _draw()
    cls()  -- clear the screen
    draw_player()
end