local curent_level = 1 -- current level
local timer = 0

function draw_ui()
    -- draw hearts
    local padding = 0
    rectfill(0, 0, 128, 8, 0) -- clear the top bar
    for i = 1, player.max_life do 
        local heart_spr = ( i <= player.life) and 131 or 132
        spr(heart_spr, 8*i + 2 + padding,0,1,1)
        padding += 2 -- add padding between hearts
    end 

    -- draw dog portrait
    spr(133, 0, 0, 1, 1) -- dog portrait

    -- draw current level
    print("level: " .. curent_level, 50, 1, 7) -- level text
    
    -- Draw the formatted timer
    local minutes = flr(timer / 60) -- Get the minutes
    local seconds = flr(timer) % 60 -- Get the seconds (remainder of division by 60)
    
    -- Manually format time as "00:00"
    local formatted_time = tostring(minutes)
    if minutes < 10 then
        formatted_time = "0" .. formatted_time
    end
    formatted_time = formatted_time .. ":"
    
    local formatted_seconds = tostring(seconds)
    if seconds < 10 then
        formatted_seconds = "0" .. formatted_seconds
    end
    formatted_time = formatted_time .. formatted_seconds

    print(formatted_time, 100, 1, 7) -- Display the timer in the formatted style
end

-- Update timer logic (counts seconds)
function update_timer()
    timer = timer + 1 / 60  -- Increment timer by 1/60 each frame (assuming 60 FPS)
    
    -- If the timer reaches 5999 seconds (99:59), reset to 0
    if timer >= 6000 then
        timer = 0  -- Reset the timer
    end
end
