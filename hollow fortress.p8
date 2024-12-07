-- tab 0: allgemeine spiellogik

-- variablen, die fれもr das gesamte spiel genutzt werden
px, py = 31 * 8, 31 * 8  -- startposition x und y
speed = 2  -- bewegungsgeschwindigkeit
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


-- funktion fuer uebergang stages
stage_transition = false  -- flag fれもr stufenれもbergang

-- funktionen fuer die stages
current_stage = 3  -- wechselt zu stage 3




function _update()
    player_movement()
    update_camera()
    
    if current_stage == 1 then
        stage1_update()
    elseif current_stage == 2 then
        stage2_update()
    elseif current_stage == 3 then
        stage3_update()
    elseif current_stage == 4 then
        stage4_update()
    
    
    
    end


-- stufenwechsel prれもfen
    if stage_transition then
        current_stage += 1  -- wechsel zur nれさchsten stage
        stage_transition = false  -- れうbergangs-flag zurれもcksetzen
    end

end





function _draw()
    cls()
    map(0, 0, 0, 0, 128, 64)

    if current_stage == 1 then
        stage1_draw()
    elseif current_stage == 2 then
        stage2_draw()
    elseif current_stage == 3 then
        stage3_draw()
    elseif current_stage == 4 then
        stage4_draw()
    end

    -- spieler-sprite immer zeichnen
    spr(sprite, px, py)
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
    "ein offenes tor?\ndas fuehlt sich\nnicht richtig an … ",
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
    "mein herrchen hat mich\neinfach zurueckgelassen…\nund jetzt finde ich\nnichts mehr zu fressen.", 
    "nicht einmal die\nkleinen nager streunen\nnoch umher.\nalles, was ich hier finde,\nist dieses menschenzeug.", 
    "koerner! brot!\nunertraeglich!",  -- siebte zeile
    "sag, hast du nicht\nirgendwo fleisch\noder fisch gesehen?",  -- achte zeile
    "irgendetwas, das wir\nkatzen essen koennen?",  -- neunte zeile
    "ich verhungere sonst…"  -- zehnte zeile
}


-- init-funktion fれもr stage 1
function _init()
    animating = true  -- animation starten
    tile_changed = false  -- kachelれさnderung als false setzen
    tile_animated = false  -- kachel-animation als false setzen
    current_stage = 1  -- start in stage 1




end

-- flagge, die speichert, ob der spieler die zone betreten hat
local zone_entered = false

-- update-funktion fれもr stage 1
function stage1_update()
    

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

        -- teleportation zu schloss
        if flr(px / 8) == 45 and flr(py / 8) == 7 then
            px = 120 * 8
            py = 61 * 8
        end
        

        -- zurueckteleportation von schloss
        if flr(px / 8) == 120 and flr(py / 8) == 63 then
            px = 45 * 8
            py = 9 * 8

            -- kachelれさnderung an (58, 13) und animation starten
            if not tile_changed then
                mset(58, 13, 98)  -- れさndere kachel-sprite
                tile_changed = true
            end
            
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
                    
                    mset(69, 15, 111)   -- れ░ndere sprite von kachel 45, 8 zu 77
                    mset(69, 16, 107)   -- れ░ndere sprite von kachel 45, 8 zu
                    mset(76, 15, 111)   -- れ░ndere sprite von kachel 45, 8 zu 77
                    mset(76, 16, 107)   -- れ░ndere sprite von kachel 45, 8 zu
           
                    -- kachel an (43, 18) れさndern und animation starten
                    mset(43, 18, 124) -- beispiel-kachelれさnderung
                    tile_animated = true  -- animation starten
                    
                    stage_transition = true
   
                end
            end
        end
    end
    
   if stage_transition then
    -- れうbergang zu stage 2
    current_stage = 2
    stage_transition = false  -- zurれもcksetzen des flags
   end

   
    update_camera()
end


-- draw-funktion fれもr stage 1
function stage1_draw()
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
            local sprite_index = 123 + flr((t() * 5) % 2)  -- wechseln zwischen 123 und 124
            mset(43, 18, sprite_index)  -- setze die kachel auf den wechselnden sprite
        end
    end


    -- spieler-sprite immer zeichnen
    spr(sprite, px, py)
end



-- tab 2: stage 2 - spezifische spiellogik

-- variablen fuer fleisch
local in_meat_zone = false
local meat_dialog_active = false
local meat_dialog_text = "druecke x um fleisch zu nehmen"
local meat_zone_x, meat_zone_y, meat_zone_w, meat_zone_h = 122, 16, 3, 2
local meat_taken = false
local meat_sprite = 34  -- sprite-id fれもr das item (oben links anzeigen)
local meat_dialog_completed = false

-- variablen fuer fisch
local in_fish_zone = false
local fish_dialog_active = false
local fish_dialog_text = "druecke x um fisch zu nehmen"
local fish_dialog_completed = false
local fish_zone_x, fish_zone_y, fish_zone_w, fish_zone_h = 42, 17, 3, 3  -- zone fれもr fisch
local fish_taken = false
local fish_sprite = 28  -- sprite-id fれもr das fisch-item

-- variablen fuer brot
local bread_dialog_active = false
local bread_dialog_completed = false  -- gibt an, ob der brot-dialog abgeschlossen wurde
local bread_dialog_text = {
    "es ist brot!!!",
    "das meinte sie\naber wahrscheinlich\nnicht.",
    "ich zumindest\nmag brot nicht\nsonderlich..."
}local bread_dialog_stage = 1  -- aktuelle zeile des dialogs
local bread_zone_x, bread_zone_y, bread_zone_w, bread_zone_h = 68, 39, 5, 2  -- die zone f'rem brot

-- variablen fれもr die tischzone
local table_zone_x, table_zone_y, table_zone_w, table_zone_h = 59, 12, 5, 3
local table_dialog_active = false
local table_dialog_text = "druecke x um auf tisch zu legen"
local fish_on_table = false
local meat_on_table = false

-- variablen fれもr cat_dialog_2
cat_dialog_2_active = false  -- flag fれもr cat_dialog_2
cat_dialog_2_stage = 1  -- aktuelle zeile des cat_dialog_2
cat_dialog_2_completed = false  -- ob cat_dialog_2 abgeschlossen ist
local cat_coin_sprite = 68  -- sprite-id fれもr das neue item
local cat_coin_obtained = false  -- ob das item bereits erhalten wurde

-- dialog-texte fれもr cat_dialog_2
cat_dialog_2 = {
    "nanu!?", 
    "oh, wie wunderbar!",
    "endlich etwas, das schmeckt!",
    "ich wuenschte,\nich koennte dir\nmehr bieten,", 
    "aber als kleines\ndankeschoen nimm\ndas hier.", 
    "es stammt noch\naus dem schloss...", 
    "vielleicht kannst du\nja etwas damit anfangen.", 
    "du solltest mal\nan einen ort schauen,\n nicht weit von hier.", 
    "reisende machen dort\ngerne halt.", 
    "aber pass auf -\nder koeter hat dort\ninzwischen das sagen.", 
    "sein besitzer ist weg, \nund jetzt laeuft da\ndieser nervige\nklaeffer rum!"
}

-- update-funktion fuer stage 2
function stage2_update()

-- ueberpruefe, ob die kachelanimation fortgesetzt werden muss
    if tile_animated and not fish_dialog_completed and not fish_taken then
        -- animierte kachel in stage 2 fortsetzen
        local sprite_index = 123 + flr((t() * 5) % 2)
        mset(43, 18, sprite_index)  -- aktualisiere die animierte kachel
    else
    if fish_taken and fish_dialog_completed then
        mset(43, 18, 24)  -- fisch-kachel setzen
    end 
end   
  
-- teleportation metzger
    if flr(px / 8) == 69 and flr(py / 8) == 15 then
        px = 125 * 8
        py = 21 * 8
    elseif flr(px / 8) == 125 and flr(py / 8) == 23 then
        px = 69 * 8
        py = 17 * 8
    end
    
-- teleportation baecker
    if flr(px / 8) == 76 and flr(py / 8) == 15 then
        px = 71 * 8
        py = 43 * 8
    elseif flr(px / 8) == 71 and flr(py / 8) == 45 then
        px = 76 * 8
        py = 17 * 8
    end 
   
-- teleportation  schloss
    if flr(px / 8) == 45 and flr(py / 8) == 7 then
        px = 120 * 8
        py = 61 * 8
    elseif flr(px / 8) == 120 and flr(py / 8) == 63 then
            px = 45 * 8
            py = 9 * 8   
    end
   
   
-- れうberprれもfe, ob der spieler in der fleisch-zone ist
    local player_in_meat_zone = flr(px / 8) >= meat_zone_x and flr(px / 8) < meat_zone_x + meat_zone_w and
                                flr(py / 8) >= meat_zone_y and flr(py / 8) < meat_zone_y + meat_zone_h
-- れうberprれもfe, ob der spieler in der fisch-zone ist
    local player_in_fish_zone = flr(px / 8) >= fish_zone_x and flr(px / 8) < fish_zone_x + fish_zone_w and
                                flr(py / 8) >= fish_zone_y and flr(py / 8) < fish_zone_y + fish_zone_h                             
-- れうberprれもfe, ob der spieler in der brot-zone ist
    local player_in_bread_zone = flr(px / 8) >= bread_zone_x and flr(px / 8) < bread_zone_x + bread_zone_w and
                                 flr(py / 8) >= bread_zone_y and flr(py / 8) < bread_zone_y + bread_zone_h

-------------
-- dialoge
-------------


-- fleisch-dialog 
    if player_in_meat_zone and not meat_taken and not meat_dialog_completed then
        in_meat_zone = true
        meat_dialog_active = true
        
        -- prれもfe, ob "x" gedrれもckt wird
        if btnp(5) then  -- taste "x"
            meat_taken = true
            meat_dialog_completed = true  -- dialog abgeschlossen
            mset(124, 16, 12)  -- tile-sprite れさndern (fleisch aufnehmen)
        end
    else
        in_meat_zone = false
        meat_dialog_active = false
    end
    
-- fisch-dialog
    if player_in_fish_zone and not fish_taken and not fish_dialog_completed then
        in_fish_zone = true
        fish_dialog_active = true

        if btnp(5) then  -- taste "x"
            fish_taken = true
            fish_dialog_completed = true  -- dialog abgeschlossen
            mset(43, 18, 24)  -- aktualisiere die animierte kachel
        end
    else
        in_fish_zone = false
        fish_dialog_active = false
    end
    
-- brot-dialog
if player_in_bread_zone and not bread_dialog_completed then
    if not bread_dialog_active then
        bread_dialog_active = true  -- brot-dialog aktivieren
    elseif bread_dialog_active and btnp(5) then  -- taste "x", um weiterzugehen
        bread_dialog_stage = bread_dialog_stage + 1
        if bread_dialog_stage > #bread_dialog_text then
            bread_dialog_stage = 1  -- zurれもck zur ersten zeile, falls notwendig
            bread_dialog_active = false  -- dialog deaktivieren
            bread_dialog_completed = true  -- dialog als abgeschlossen markieren
        end
    end
else
    bread_dialog_active = false  -- brot-dialog deaktivieren, wenn die zone verlassen wird
    if not bread_dialog_completed then
        bread_dialog_stage = 1  -- sicherstellen, dass die stage zurれもckgesetzt wird, wenn der dialog noch nicht abgeschlossen ist
    end
end
  
    
-- tisch-interaktion
local player_in_table_zone = flr(px / 8) >= table_zone_x and flr(px / 8) < table_zone_x + table_zone_w and
                             flr(py / 8) >= table_zone_y and flr(py / 8) < table_zone_y + table_zone_h

if player_in_table_zone and (fish_taken or meat_taken) then
    table_dialog_active = true
    if btnp(5) then  -- taste "x"
        if fish_taken and not fish_on_table then
            fish_on_table = true
            fish_taken = false
            mset(60, 13, 22)  -- fisch auf tisch legen
        elseif meat_taken and not meat_on_table then
            meat_on_table = true
            meat_taken = false
            mset(61, 13, 18)  -- fleisch auf tisch legen
        end
    end
else
    table_dialog_active = false
end
    
    
-- pruefung, ob beide items abgelegt wurden
if meat_on_table and fish_on_table and not cat_dialog_2_active and not cat_dialog_2_completed then
    cat_dialog_2_active = true  -- dialog starten
    cat_dialog_2_stage = 1  -- dialog von anfang an
end

  
-- dialogfortschritt
if cat_dialog_2_active then
    if btnp(5) then  -- taste "x", um weiterzugehen
        cat_dialog_2_stage = cat_dialog_2_stage + 1
        if cat_dialog_2_stage > #cat_dialog_2 then
            cat_dialog_2_active = false  -- dialog beenden
            cat_dialog_2_completed = true  -- dialog als abgeschlossen markieren
            cat_coin_obtained = true
            mset(72, 7, 111) 
            mset(72, 8, 107) 
            mset(29, 21, 111) 
            mset(29, 22, 107) 
            current_stage = 3           
        end
    end
end



update_camera()

end
    

 
    
-- draw-funktion fれもr stage 2
function stage2_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)  -- karte zeichnen

    -- spieler-sprite immer zeichnen
    spr(sprite, px, py)

    -- animierte kachel (falls aktiv)
    if tile_animated then
        local sprite_index = 123 + flr((t() * 5) % 2)
        mset(43, 18, sprite_index) -- animiere die kachel weiterhin
    end
    
    
    ---------------------
    -- dialoge 
    ---------------------
    
    
    -- tisch-dialog
    if table_dialog_active then
        draw_dialog_near_player(table_dialog_text, 10)
    end


    -- fleisch-dialog
    if meat_dialog_active and in_meat_zone then
        draw_dialog_near_player(meat_dialog_text, 10)
    end


    -- fisch-dialog
    if fish_dialog_active and in_fish_zone then
        draw_dialog_near_player(fish_dialog_text, 10)
    end

    
    -- brot-dialog
    if bread_dialog_active then
        draw_textbox(bread_dialog_text[bread_dialog_stage], px, py, 120, 40)
    end
    
    
    -- katze-dialog (cat_dialog_2)
    if cat_dialog_2_active then
        draw_textbox(cat_dialog_2[cat_dialog_2_stage], px, py - 5, 120, 30)
    end
    
    
    ---------------------
    -- item-bar 
    ---------------------
    
    
    -- fleisch-item anzeigen (falls genommen, aber noch nicht abgelegt)
    if meat_taken and not meat_on_table then
        draw_item_in_ui(meat_sprite, -7)
    end
    
    
    -- fisch-item anzeigen (falls genommen, aber noch nicht abgelegt)
    if fish_taken and not fish_on_table then
        draw_item_in_ui(fish_sprite, -5)
    end


    -- mれもnzen-item anzeigen, wenn sie erhalten wurde
    if cat_coin_obtained then
    draw_item_in_ui(cat_coin_sprite, -7)
    end
    
-- zeichnet einen dialog in der nれさhe des spielers
function draw_dialog_near_player(dialog_text, offset_y)
    if flr(time() * 2) % 2 == 0 then
        local camera_x = stat(26)
        local camera_y = stat(27)
        local textbox_x = px - camera_x
        local textbox_y = py - camera_y - offset_y -- textbox れもber dem spieler
        draw_textbox(dialog_text, textbox_x, textbox_y, 120, 20)
    end
end
end


local coin_count = 1 -- startwert: katze hat eine mれもnze gegeben
local stage3_coin_obtained = false -- neue variable zum halten des mれもnzenzustands
local hide_coin_ui = false -- steuert, ob die mれもnze oben links angezeigt wird

-- allgemeine variablen fれもr mれもnzen und ihre zonen
local coin_zones = {
    {taken = false, sprite = 68, x = 83, y = 41, w = 3, h = 3},
    {taken = false, sprite = 68, x = 118, y = 53, w = 3, h = 3},
    {taken = false, sprite = 68, x = 113, y = 3, w = 3, h = 3}
}

-- teleportationsdaten: {x1, y1, x2, y2}
local teleports = {
    {29, 21, 86, 43}, -- haus
    {69, 15, 125, 21}, -- metzger
    {76, 15, 71, 43}, -- bれさrsacker
    {45, 7, 120, 61}, -- schloss
    {72, 7, 117, 9} -- taverne
}

-- variablen fれもr den hundedialog
dog_dialog_active = false -- ob der hundedialog aktiv ist
dog_dialog_stage = 1 -- aktuelle dialogzeile
dog_dialog_completed = false -- ob der dialog abgeschlossen ist
local dog_dialog_text = {
    "moin, moin!\nwat geiht, miezchen?",
    "kiek mol,\nwat haett' ich\ndenn huet foer dich!",
    "ein glas warme milch\n-frisch gemolken,\nkraeftig foer de\nschnurrhaare!",
    "und dat beste:\nkost' dich bloss\n4 muenz!\nein richtiger\nschnapper, wa?",
    "glas milch kaufen?\n\nja"
}

local post_dog_dialog_text = {
    "och nee,\nreicht dat etwa nich?\nna wunderbar...",
    "ick hab' hier\nnich den ganzen\ntag zeit",
    "kannste dir vielleicht\nwoanders 'ne billigere\nmilch holen,\noder komm wieder,\nwenn de wat mehr\nmuenz in der\ntasche hast",
    "ah, fein! hier is deine milch!\ndirekt aus der kanne! un pass auf,\nnik kleckern, sonst gibbet nasse pfoten!"
}

local dog_zone = {x = 122, y = 5, w = 3, h = 3} -- zone fれもr den hund

-- variablen fれもr den post-dialog
post_dog_dialog_active = false
post_dog_dialog_stage = 0

function stage3_update()
    -- verhindern der bewegung wれさhrend des dialogs
    if dog_dialog_active then
        -- fortschritt im dialog
        if btnp(5) then -- "x"-taste gedrれもckt
            dog_dialog_stage += 1

            -- wenn der dialog abgeschlossen ist
            if dog_dialog_stage > #dog_dialog_text then
                dog_dialog_active = false -- dialog beenden
                dog_dialog_completed = true -- dialog abgeschlossen

                -- bestimmen, welcher post-dialog angezeigt wird
                if coin_count < 4 then
                    post_dog_dialog_stage = 1 -- zeige den text fれもr weniger als 4 mれもnzen
                else
                    post_dog_dialog_stage = 4 -- zeige den text fれもr genau 4 oder mehr mれもnzen
                    coin_count -= 4 -- mれもnzen abziehen
                    stage3_coin_obtained = false -- mれもnze zurれもcksetzen
                end
                post_dog_dialog_active = true -- aktiviere den post-dialog
            end
        end
        return -- blockiere bewegung und alle anderen aktionen wれさhrend des dialogs
    end

if post_dog_dialog_active then
    -- fortschritt im post-dialog
    if btnp(5) then -- "x"-taste gedrれもckt
        post_dog_dialog_active = false -- post-dialog beenden
        if post_dog_dialog_stage == 4 then
            hide_coin_ui = true -- mれもnzenanzeige deaktivieren
            current_stage = 4           
        end
 
        end
    
    return -- blockiere bewegung und andere aktionen wれさhrend des post-dialogs
end

    -- れもberprれもfen, ob der spieler in der hund-zone ist
    player_in_dog_zone = flr(px / 8) >= dog_zone.x and flr(px / 8) < dog_zone.x + dog_zone.w and
                         flr(py / 8) >= dog_zone.y and flr(py / 8) < dog_zone.y + dog_zone.h

    -- dialog aktivieren, wenn der spieler in der hund-zone ist und der dialog noch nicht abgeschlossen ist
    if player_in_dog_zone and not dog_dialog_active and not dog_dialog_completed then
        dog_dialog_active = true
        dog_dialog_stage = 1 -- starte den dialog von vorne
    end

    -- wenn die erste mれもnze in stage 3 erhalten wurde, wird coin_count nur einmal auf 1 gesetzt
    if cat_coin_obtained and not stage3_coin_obtained then
        stage3_coin_obtained = true -- markiere, dass die mれもnze in stage 3 erhalten wurde
    end

    -- teleportation prれもfen
    for _, teleport in pairs(teleports) do
        -- hinteleportation
        if flr(px / 8) == teleport[1] and flr(py / 8) == teleport[2] then
            px = teleport[3] * 8  -- teleportiere den spieler zum ziel
            py = teleport[4] * 8

            -- dialog zurれもcksetzen
            dog_dialog_completed = false
            dog_dialog_active = false
            dog_dialog_stage = 1

        -- rれもckteleportation
        elseif flr(px / 8) == teleport[3] and flr(py / 8) == teleport[4] then
            px = teleport[1] * 8  -- teleportiere den spieler zurれもck zum startpunkt
            py = (teleport[2] + 2) * 8  -- verschiebe den rれもckteleport um y=2 nach unten

            -- dialog zurれもcksetzen
            dog_dialog_completed = false
            dog_dialog_active = false
            dog_dialog_stage = 1
        end
    end

    -- れもberprれもfen und aktualisieren der mれもnzen-zonen
    for _, zone in pairs(coin_zones) do
        local player_in_zone = flr(px / 8) >= zone.x and flr(px / 8) < zone.x + zone.w and
                               flr(py / 8) >= zone.y and flr(py / 8) < zone.y + zone.h

        if player_in_zone and not zone.taken then
            if btnp(5) then
                zone.taken = true
                coin_count += 1
                stage3_coin_obtained = true
                mset(zone.x + 1, zone.y + 1, 20) -- tile れさndern
            end
        end
    end
end

function stage3_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)  -- karte fれもr stage 3 laden

    -- mれもnze und anzahl nur anzeigen, wenn `hide_coin_ui` nicht aktiv ist
    if stage3_coin_obtained and not hide_coin_ui then
        draw_item_in_ui(68, -7, coin_count) -- mれもnze im ui anzeigen
    end

    -- spieler-sprite immer zeichnen
    spr(sprite, px, py)

    -- zeige den normalen dog-dialog, wenn er aktiv ist
    if dog_dialog_active then
        draw_dog_dialog()
    end

    -- zeige den post-dialog an, wenn er aktiv ist
    if post_dog_dialog_active then
        draw_post_dog_dialog()
    end
end

function draw_item_in_ui(sprite_id, x_offset, count)
    local camera_x = stat(26)
    local camera_y = stat(27)
    local item_x = px - camera_x + (x_offset * 8) -- verschiebung von der linken ecke
    local item_y = py - camera_y - 7 * 8
    -- hintergrundrechteck
    rectfill(item_x, item_y, item_x + 16, item_y + 16, 0)
    rect(item_x, item_y, item_x + 16, item_y + 16, 7)
    -- sprite zentriert im rechteck zeichnen
    spr(sprite_id, item_x + 4, item_y + 4)
    -- coin count innerhalb des rechtecks zeichnen
    if count then
        print(count, item_x + 8, item_y + 8, 7)
    end
end

function draw_dog_dialog()
    local camera_x = stat(26)
    local camera_y = stat(27)
    local textbox_x = px - camera_x
    local textbox_y = py - camera_y  -- oder beliebiger offset
    draw_textbox(dog_dialog_text[dog_dialog_stage], textbox_x, textbox_y, 120, 40)
end

function draw_post_dog_dialog()
    local camera_x = stat(26)
    local camera_y = stat(27)
    local textbox_x = px - camera_x
    local textbox_y = py - camera_y  -- oder beliebiger offset
    draw_textbox(post_dog_dialog_text[post_dog_dialog_stage], textbox_x, textbox_y, 120, 40)

     -- wenn der dialog abgeschlossen ist und die mれもnzen abgezogen wurden, zeichne sprite 78
   
end


-- tab 4: stage 4 - spezifische spiellogik

local teleports = {
    {29, 21, 86, 43}, -- haus
    {69, 15, 125, 21}, -- metzger
    {76, 15, 71, 43}, -- bれさrsacker
    {45, 7, 120, 61}, -- schloss
    {72, 7, 117, 9}, -- taverne
    {{16, 8, 4, 1}, {76, 63, 2, 1}, {16, 9}} -- taverne
}

local sprite_97_position = {x = 64 * 8, y = 11 * 8} -- startposition von sprite 97
local sprite_97_target = {x = 18 * 8, y = 10 * 8} -- zielposition von sprite 97
local sprite_97_moving = false -- flag, um die bewegung von sprite 97 zu steuern
local sprite_97_speed = 1 -- geschwindigkeit von sprite 97
local player_zone = {x = 71, y = 10, w = 4, h = 2} -- zone, die der spieler betreten muss

function stage4_update()
    -- hier kannst du deine update-logik fれもr stage 4 hinzufれもgen
    if not sprite_78_drawn then
        sprite_78_drawn = true -- flag setzen, damit es nur einmal ausgefれもhrt wird
    end

    -- prれもfen, ob der spieler die definierte zone betritt
    if not sprite_97_moving and
       flr(px / 8) >= player_zone.x and flr(px / 8) < player_zone.x + player_zone.w and
       flr(py / 8) >= player_zone.y and flr(py / 8) < player_zone.y + player_zone.h then
        sprite_97_moving = true
    end

    -- wenn sprite 97 sich bewegen soll
    if sprite_97_moving then
        if sprite_97_position.x < sprite_97_target.x then
            sprite_97_position.x += sprite_97_speed
        elseif sprite_97_position.x > sprite_97_target.x then
            sprite_97_position.x -= sprite_97_speed
        end

        if sprite_97_position.y < sprite_97_target.y then
            sprite_97_position.y += sprite_97_speed
        elseif sprite_97_position.y > sprite_97_target.y then
            sprite_97_position.y -= sprite_97_speed
        end

        -- bewegung stoppen, wenn das ziel erreicht ist
        if sprite_97_position.x == sprite_97_target.x and sprite_97_position.y == sprite_97_target.y then
            sprite_97_moving = false
        end
    end

    -- teleportation prれもfen
    for _, teleport in pairs(teleports) do
        if type(teleport[1]) == "table" then
            -- zonen-teleport: hin- und rれもckteleport prれもfen
            local zone = teleport[1]
            local dest = teleport[2]

            -- hinteleportation: spieler betritt die zone
            if flr(px / 8) >= zone[1] and flr(px / 8) < zone[1] + zone[3] and
               flr(py / 8) >= zone[2] and flr(py / 8) < zone[2] + zone[4] then
                px = dest[1] * 8 -- ziel x
                py = dest[2] * 8 -- ziel y
            end

            -- rれもckteleportation: spieler befindet sich im zielbereich
            if flr(px / 8) == dest[1] and flr(py / 8) == dest[2] then
                px = zone[1] * 8 -- zurれもck x (startpunkt der zone)
                py = (zone[2] + zone[4]) * 8 -- zurれもck y (unterhalb der zone)
            end
        else
            -- punkte-teleport: standard-logik
            -- hinteleportation
            if flr(px / 8) == teleport[1] and flr(py / 8) == teleport[2] then
                px = teleport[3] * 8 -- ziel x
                py = teleport[4] * 8

            -- rれもckteleportation
            elseif flr(px / 8) == teleport[3] and flr(py / 8) == teleport[4] then
                px = teleport[1] * 8 -- zurれもck x
                py = (teleport[2] + 2) * 8 -- zurれもck y
            end
        end
    end
end

function stage4_draw()
    cls()
    map(0, 0, 0, 0, 128, 64) -- karte fれもr stage 4 laden

    -- sprite 78 zeichnen, wenn es markiert ist
    if sprite_78_drawn then
        draw_item_in_ui(78, -7, nil) -- sprite 78 im ui anzeigen
    end

    -- sprite 97 zeichnen
    spr(97, sprite_97_position.x, sprite_97_position.y)

    -- hier kannst du andere ui-elemente oder spieler-position zeichnen
    spr(sprite, px, py) -- spieler zeichnen
end   










-- tab 6: stage 6 - spezifische spiellogik

local current_stage = 6 -- aktuelle stage
local teleports = {
    {29, 21, 86, 43}, {69, 15, 125, 21}, {76, 15, 71, 43}, {45, 7, 120, 61}, {72, 7, 117, 9}, {28, 7, 99, 61},{29, 15, 103, 8} 
}

-- dialogsystem
local dialog_system = {
    
    grimreaper = {
        active = false,
        stage = 1,
        completed = false,
        text = {
            "die glocken klagen\nnah und fern,\nihr widerhall\ngefaellt dem herrn.",
            "das grab ruft laut,\ndie erde schreit,\nzu viele fielen\njuengst im leid.",
            "der schwarze tod\nbringt seelen mir,\ndoch schuldige\nverweilen hier.",
            "im thronsaal\nsind sie eingesperrt,\nder koenig\nwurde fortgezehrt.",
            "bald wirst du\ndorthin gelangen,\nnur unterwelt\nwird dich empfangen.",
            "drum bete still\nfuer deinen leib,\ndie entscheidung wird\nnicht einfach sein."},
        trigger_zone = {74, 79, 53, 56}},
    
    bible = {
        active = false,
        stage = 1,
        completed = false,
        text = {
            "und der herr sprach:\nwer das leben sucht,\nder soll hinabsteigen\nwo das licht verborgen ist.",
            "denn in der dunkelheit\noffenbart sich die wahrheit,\ndie den mutigen allein gehoert."},
        trigger_zone = {98, 101, 52, 55}},
    
    diary = {
        active = false,
        stage = 1,
        completed = false,
        text = {
            "nicht alle,\ndie dunkelheit bringen,\nsind selbst\nvon dunkelheit erfuellt."
        },
        trigger_zone = {103, 105, 2, 4}}}

local zone_entered = false

function start_dialog(dialog)
    if not dialog.active and not dialog.completed then
        dialog.active = true
        dialog.stage = 1
    end
end

function update_dialog(dialog)
    if dialog.active then
        if btnp(5) then
            dialog.stage += 1
            if dialog.stage > #dialog.text then
                dialog.active = false
                dialog.completed = true
            end
        end
    end
end    

function draw_dialog(dialog, player_x, player_y)
    if dialog.active then
        draw_textbox(dialog.text[dialog.stage], player_x, player_y, 120, 40)
    end
end

function player_in_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) < zone[2] and
           flr(py / 8) >= zone[3] and flr(py / 8) < zone[4]
end

-- stage 6 update-logik
function stage6_update()
    if current_stage ~= 6 then return end -- only update if current_stage is 6

    -- initial setup for stage 6
    mset(29, 15, 111) 
    mset(29, 16, 107) 
    mset(28, 6, 93) 
    mset(28, 7, 109)
    mset(28, 8, 109)
 
    if not grim_reaper.moving then
        grim_reaper.moving = true
    end

    if grim_reaper.moving then
        if grim_reaper.phase == 1 and grim_reaper.pos.x < grim_reaper.target.x then
            grim_reaper.pos.x += grim_reaper.speed
        elseif grim_reaper.phase == 1 then
            grim_reaper.phase = 2 -- switch to phase 2
        end

        if grim_reaper.phase == 2 then
            grim_reaper.moving = false -- grim reaper stops moving
        end
    end

    for _, teleport in pairs(teleports) do
        if flr(px / 8) == teleport[1] and flr(py / 8) == teleport[2] then
            px, py = teleport[3] * 8, teleport[4] * 8
        elseif flr(px / 8) == teleport[3] and flr(py / 8) - 2 == teleport[4] then
            px, py = teleport[1] * 8, (teleport[2] + 2) * 8
        end
    end

    if flr(px / 8) >= 16 and flr(px / 8) < 20 and flr(py / 8) >= 8 and flr(py / 8) < 9 then
        px, py = 76 * 8, 61 * 8
    elseif flr(px / 8) >= 76 and flr(px / 8) < 78 and flr(py / 8) >= 63 and flr(py / 8) < 65 then
        px, py = 16 * 8, 10 * 8
        graveyard_returned = true
    end
    
    if player_in_zone(dialog_system.grimreaper.trigger_zone) then
        start_dialog(dialog_system.grimreaper)
    elseif player_in_zone(dialog_system.bible.trigger_zone) then
        start_dialog(dialog_system.bible)
    elseif player_in_zone(dialog_system.diary.trigger_zone) then
        start_dialog(dialog_system.diary)
    end

    update_dialog(dialog_system.grimreaper)
    update_dialog(dialog_system.bible)
    update_dialog(dialog_system.diary)
    update_camera()
end

-- stage 6 draw logic
function stage6_draw()
    if current_stage ~= 6 then return end -- only draw if current_stage is 6

    cls()
    map(0, 0, 0, 0, 128, 64)

    if not grim_reaper.disappear then
        spr(96, grim_reaper.pos.x, grim_reaper.pos.y)
    end

    draw_dialog(dialog_system.grimreaper, px, py)
    draw_dialog(dialog_system.bible, px, py)
    draw_dialog(dialog_system.diary, px, py)

    spr(sprite, px, py)
end












-- kollisions 

local blocking_sprites = { 44, 23, 26, 27, 15, 62, 63, 77, 85, 86, 110, 126, 7, 8, 9, 24, 118, 102, 40, 53, 21, 22, 18, 12, 5, 19, 46      }
local blocking_zones = { {16, 19, 9, 1}, {27, 19, 6, 1}, {5, 18, 9, 3}, {66, 13, 5, 1}, {73, 13, 5, 1}, {80, 13, 6, 1}, {80, 19, 6, 1}, {72, 19, 5, 1}, {64, 19, 5, 1}, {56, 19, 5, 1}, {26, 13, 10, 1}, {16, 13, 7, 1}, {2, 7, 88, 1}             }
local free_zones = { {2, 8, 62, 1}, {15, 16, 23, 1}, {53, 16, 37, 1}, {5, 22, 13, 1}, {24, 22, 14, 1}, {55, 22, 33, 1}, {40, 22, 9, 1}, {70, 8, 20, 1}, {65, 9, 5, 1}, {19, 23, 5, 1}, {38, 20, 2, 1}, {49, 21, 2, 1}, {51, 20, 1, 1}, {40, 21, 1, 1}                    }
local roof_zones = { {5, 16, 9, 2}, {16, 12, 7, 2}, {27, 18, 6, 2}, {16, 18, 9, 2}, {26, 12, 10, 2}, {66, 11, 5, 3}, {73, 12, 5, 2}, {80, 12, 6, 2}, {80, 18, 6, 2}, {72, 18, 5, 2}, {57, 8, 3, 2}, {64, 18, 5, 2}, {56, 18, 5, 2} }

-- kollisionsprれもfung
function check_collision(player_x, player_y)
    for _, corner in ipairs({
        {player_x, player_y},          -- oben links
        {player_x + 7, player_y},      -- oben rechts
        {player_x, player_y + 7},      -- unten links
        {player_x + 7, player_y + 7},  -- unten rechts
    }) do
        local tile_x = flr(corner[1] / 8)
        local tile_y = flr(corner[2] / 8)

        for _, zone in ipairs(free_zones) do
            if tile_x >= zone[1] and tile_x < zone[1] + zone[3] and
               tile_y >= zone[2] and tile_y < zone[2] + zone[4] then
                return false
            end
        end

        for _, zone in ipairs(blocking_zones) do
            if tile_x >= zone[1] and tile_x < zone[1] + zone[3] and
               tile_y >= zone[2] and tile_y < zone[2] + zone[4] then
                return true
            end
        end

        local tile_id = mget(tile_x, tile_y)
        for _, sprite in ipairs(blocking_sprites) do
            if tile_id == sprite then
                return true
            end
        end
    end
    return false
end    
     
-update

-- kollision れもberprれもfen
    if not check_collision(new_px, new_py) then
        px, py = new_px, new_py
    end

-- draw 

-- dれさcher zeichnen, falls der spieler darunter ist
    for _, zone in ipairs(roof_zones) do
        for y = zone[2], zone[2] + zone[4] - 1 do
            if py + 7 >= y * 8 then  -- zeichne das dach nur, wenn es unter dem charakter ist
                for x = zone[1], zone[1] + zone[3] - 1 do
                    spr(mget(x, y), x * 8, y * 8)
                end
            end
        end
    end
end


function update_player()
    local move_x, move_y = 0, 0

    if btn(0) then move_x = -speed end  -- links
    if btn(1) then move_x = speed end   -- rechts
    if btn(2) then move_y = -speed end  -- hoch
    if btn(3) then move_y = speed end   -- runter

    local new_px, new_py = px + move_x, py + move_y

    -- れうberprれもfe kollision bevor position aktualisiert wird
    if not check_collision(new_px, new_py) then
        px, py = new_px, new_py
    end
end
