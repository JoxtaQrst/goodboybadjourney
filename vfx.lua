-- vfx.lua

vfx = {}
vfx.particles = {}

-- spawn N dust puffs at (x,y)
function vfx_spawn_dust(x,y)
    for i=1,2 do
        add(vfx.particles, {
            x    = x + (rnd(4)-2),
            y    = y + (rnd(2)-1),
            vx   = rnd(1)-.5,
            vy   = -rnd(1),
            life = 8 + flr(rnd(4)),
            size = rnd(2),
            col  = 7
        })
    end
end

-- spawn a little red burst at (x,y)
function vfx_spawn_burst(x,y)
    for i=1,6 do
        add(vfx.particles, {
            x    = x,
            y    = y,
            vx   = (rnd()<.5 and -1 or 1)*rnd(1.5),
            vy   = -rnd(1.5),
            life = 6 + flr(rnd(4)),
            size = rnd(2)+1,
            col  = 8
        })
    end
end

function update_vfx()
    for i=#vfx.particles,1,-1 do
        local p = vfx.particles[i]
        p.life -= 1
        if p.life <= 0 then
            del(vfx.particles, p)
        else
            p.x += p.vx
            p.y += p.vy
            p.vy += 0.1    -- a little gravity
        end
    end
end

function draw_vfx()
    for p in all(vfx.particles) do
        local a = p.life/12
        circfill(p.x, p.y, p.size*a, p.col)
    end
end
