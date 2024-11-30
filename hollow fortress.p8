-- tab 0: allgemeine spiellogik

-- variablen, die fれもr das gesamte spiel genutzt werden
px, py = 31 * 8, 31 * 8  -- startposition x und y
speed = 1.5  -- bewegungsgeschwindigkeit
direction = "right"
sprite = 64  -- start-sprite
animating = false  -- flag fれもr animation

-- funktion zum zeichnen der textbox
function draw_textbox(text, player_x, player_y, width, height)
    local camera_x = stat(26)  -- kamera-x-offset
    local camera_y = stat(27)  -- kamera-y-offset

    -- zentriert れもber dem kopf des spielers und manuell nach rechts verschoben
    local center_x = player_x - camera_x + 59  -- adjust the x-offset to shift a few tiles to the right
    local center_y = player_y - camera_y - 20  -- adjust the y-offset to position above the player's head

    local x = center_x - width // 2
    local y = center_y - height // 2

    rectfill(x, y, x + width, y + height, 0)
    local lines = split(text, "\n")
    for i, line in ipairs(lines) do
        print(line, x + 4, y + 4 + (i - 1) * 6, 7)
    end
end



-- funktion zum れ░ndern des sprites bei sprite 24
function check_and_update_sprite()
    -- prれもfen, ob der spieler sprite 24 berれもhrt
    local sprite_x = flr(px / 8)
    local sprite_y = flr(py / 8)
    local target_sprite = mget(sprite_x, sprite_y)  -- mget gibt das sprite an der position zurれもck
    
    if target_sprite == 24 then
        if direction == "right" then
            sprite = 83
        elseif direction == "left" then
            sprite = 84
        end
        animating = false  -- walk-animation deaktivieren
    end
end



-- funktion fれもr die allgemeine spielerbewegung
function player_movement()
    -- keine bewegung wれさhrend eines dialogs
    if full_dialog_active or secondary_dialog_active or cat_dialog_1_active or cat_dialog_2_active then
        return  -- keine bewegung wれさhrend eines dialogs
    end

    local new_px, new_py = px, py
    local moving = false

    if btn(1) then
        new_px += speed
        direction = "right"
        moving = true
    elseif btn(0) then
        new_px -= speed
        direction = "left"
        moving = true
    end

    if btn(3) then
        new_py += speed
        moving = true
    elseif btn(2) then
        new_py -= speed
        moving = true
    end

    if moving then
        sprite = direction == "right" and 64 + flr((t() % 0.2) * 10) or 66 + flr((t() % 0.2) * 10)
    else
        sprite = direction == "right" and 64 or 66
    end

    px, py = new_px, new_py
    
    -- check for sprite 24
    check_and_update_sprite()
end

-- kamera aktualisieren
function update_camera()
    camera(px - 64, py - 64)
end




-- tab 1: stage 1 - spezifische spiellogik

-- variablen und flags fれもr stage 1
dialog_stage = 1  -- dialogstufe
secondary_dialog_active = false  -- flag fれもr zweite textbox
secondary_dialog_stage = 1  -- dialogstufe fれもr zweite textbox
secondary_dialog_completed = false  -- dialog abgeschlossen
tile_changed = false  -- flag fれもr kachelれさnderung
tile_animated = false  -- flag fれもr tile-animation
cat_dialog_1_active = false  -- flag fれもr katzen-dialog
cat_dialog_1_stage = 1  -- dialogstufe fれもr katzen-dialog
cat_dialog_1_completed = false  -- dialog abgeschlossen

-- dialogtexte fれもr stage 1
dialog_texts = {
    "ein offenes tor?\ndas fれもhlt sich\nnicht richtig an … ",
    "warum ist niemand\nhier, um es zu\nbewachen?"
}

secondary_dialog_texts = {
    "seltsam...",
    "die teller und tassen\nsind noch halb voll",
    "haben sie das festmahl ab-\ngebrochen oder ist das\nhier ihre art\nvon gastfreundschaft?",
    "diese menschen sind\nso verschwenderisch..."
}

-- dialog fれもr die katze (stage 1)
cat_dialog_1 = {
    "oh? wer bist denn du?",  -- erste zeile
    "bist du etwa von hier?",  -- zweite zeile
    "mein herrchen hat mich\neinfach zurれもckgelassen…\nund jetzt finde ich\nnichts mehr zu fressen.", 
    "nicht einmal die\nkleinen nager streunen\nnoch umher.\nalles, was ich hier finde,\nist dieses menschenzeug.", 
    "kれへrner! brot!\nunertrれさglich!",  -- siebte zeile
    "sag, hast du nicht\nirgendwo fleisch\noder fisch gesehen?",  -- achte zeile
    "irgendetwas, das wir\nkatzen essen kれへnnen?",  -- neunte zeile
    "ich verhungere sonst…"  -- zehnte zeile
}


-- init-funktion fれもr stage 1
function _init()
    animating = true  -- animation starten
    tile_changed = false  -- kachelれさnderung als false setzen
    tile_animated = false  -- kachel-animation als false setzen
end

-- flagge, die speichert, ob der spieler die zone betreten hat
local zone_entered = false

-- update-funktion fれもr stage 1
function _update()
    -- spielerbewegung aufrufen (aus tab 0)
    player_movement()

    -- dialog fれもr stage 1
    if dialog_stage <= #dialog_texts then
        if btnp(5) then
            dialog_stage += 1
            if dialog_stage > #dialog_texts then
                animating = true  -- starte die animation    
            end
        end
        
    elseif secondary_dialog_active then
        if btnp(5) then
            secondary_dialog_stage += 1
            if secondary_dialog_stage > #secondary_dialog_texts then
                secondary_dialog_active = false
                secondary_dialog_completed = true  -- dialog abgeschlossen
            end
        end
        
    elseif animating then
        -- animation, wenn spieler auf der karte ist
        if py > 28 * 8 then
            py = py - speed
            sprite = direction == "right" and 64 + flr((t() % 0.2) * 10) or 66 + flr((t() % 0.2) * 10)
        else
            animating = false
            initial_dialog_active = false  -- ende der animation, bewegung freigeben
        end
    else
        -- zone betreten, um zweiten dialog zu starten
        if not secondary_dialog_active and not secondary_dialog_completed and
           flr(px / 8) >= 115 and flr(px / 8) < 115 + 10 and
           flr(py / 8) == 59 then
            secondary_dialog_active = true
            secondary_dialog_stage = 1
        end

        -- teleportation zu bestimmten punkten (45, 8)
        if flr(px / 8) == 45 and flr(py / 8) == 7 then
            px = 120 * 8
            py = 61 * 8
        end

        -- zurれもckteleportation bei (120, 63)
        if flr(px / 8) == 120 and flr(py / 8) == 63 then
            px = 45 * 8
            py = 9 * 8

            -- kachelれさnderung an (58, 13) und animation starten
            if not tile_changed then
                mset(58, 13, 98)  -- れさndere kachel-sprite
                tile_changed = true
            end

            -- starte die tile-animation
            tile_animated = true
            
            -- setze flag fれもr zone_entered
            zone_entered = true
        end
        
        -- katzen-dialog stage 1 starten (zone angepasst auf 57, 12, 3, 3) und nur wenn zone_entered wahr ist
        if zone_entered and not cat_dialog_1_active and not cat_dialog_1_completed and
           flr(px / 8) >= 57 and flr(px / 8) < 60 and
           flr(py / 8) >= 12 and flr(py / 8) < 15 then
            cat_dialog_1_active = true
            cat_dialog_1_stage = 1
        end

        -- katzen-dialog fortsetzen (stage 1)
        if cat_dialog_1_active then
            if btnp(5) then
                cat_dialog_1_stage += 1
                if cat_dialog_1_stage > #cat_dialog_1 then
                    cat_dialog_1_active = false
                    cat_dialog_1_completed = true  -- dialog abgeschlossen
                    
                    -- kacheln れさndern nach dialog_1
                    mset(45, 6, 127)  -- れさndere sprite von kachel 45, 6 zu 127
                    mset(45, 7, 77)   -- れさndere sprite von kachel 45, 7 zu 77
                    mset(45, 8, 77)   -- れさndere sprite von kachel 45, 8 zu 77
                    mset(69, 15, 111)   -- れ░ndere sprite von kachel 45, 8 zu 77
                    mset(69, 16, 107)   -- れ░ndere sprite von kachel 45, 8 zu
                end
            end
        end
    end
    
    -- teleportationspunkte hinzufれもgen
                    if flr(px / 8) == 69 and flr(py / 8) == 15 then
                        px = 125 * 8
                        py = 21 * 8
                    elseif flr(px / 8) == 125 and flr(py / 8) == 23 then
                        px = 69 * 8
                        py = 17 * 8
                    end
    
    
    
    
    

    update_camera()
end


-- draw-funktion fれもr stage 1
function _draw()
    cls()
    map(0, 0, 0, 0, 128, 64)  -- karte zeichnen

    -- zeichnen der dialoge
    if dialog_stage <= #dialog_texts then
        draw_textbox(dialog_texts[dialog_stage], px, py, 120, 40)
    elseif secondary_dialog_active then
        draw_textbox(secondary_dialog_texts[secondary_dialog_stage], px, py, 120, 40)
    elseif cat_dialog_1_active then
        draw_textbox(cat_dialog_1[cat_dialog_1_stage], px, py, 120, 40)
    elseif cat_dialog_2_active then
        draw_textbox(cat_dialog_2[cat_dialog_2_stage], px, py, 120, 40)
    else
        -- animierte kachel (43, 18) wechseln zwischen 123 und 124
        if tile_animated then
            local sprite_index = 123 + flr((t() * 5) % 2)
            spr(sprite_index, 43 * 8, 18 * 8)
        end
    end

    -- spieler-sprite immer zeichnen
    spr(sprite, px, py)
end


-- draw-funktion fれもr stage 1
function _draw()
    cls()
    map(0, 0, 0, 0, 128, 64)  -- karte zeichnen

    -- zeichnen der dialoge
    if dialog_stage <= #dialog_texts then
        draw_textbox(dialog_texts[dialog_stage], px, py, 120, 40)
    elseif secondary_dialog_active then
        draw_textbox(secondary_dialog_texts[secondary_dialog_stage], px, py, 120, 40)
    elseif cat_dialog_1_active then
        draw_textbox(cat_dialog_1[cat_dialog_1_stage], px, py, 120, 40)
    elseif cat_dialog_2_active then
        draw_textbox(cat_dialog_2[cat_dialog_2_stage], px, py, 120, 40)
    else
        -- animierte kachel (43, 18) wechseln zwischen 123 und 124
        if tile_animated then
            local sprite_index = 123 + flr((t() * 5) % 2)
            spr(sprite_index, 43 * 8, 18 * 8)
        end
    end

    -- spieler-sprite immer zeichnen
    spr(sprite, px, py)
end
