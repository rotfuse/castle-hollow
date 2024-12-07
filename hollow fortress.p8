-- tab 0: allgemeine spiellogik


-- globale variablen

px, py = 31 * 8, 31 * 8
speed = 2  
direction = "right"
sprite = 64  
animating = false 

-- daecher ueber char

roof_zones = { {5, 16, 9, 2}, {16, 12, 7, 2}, {27, 18, 6, 2}, {16, 18, 9, 2}, {26, 12, 10, 2}, {66, 11, 5, 3}, {73, 12, 5, 2}, {80, 12, 6, 2}, {80, 18, 6, 2}, {72, 18, 5, 2}, {57, 8, 3, 2}, {64, 18, 5, 2}, {56, 18, 5, 2} }

function draw_roofs(player_x, player_y)
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

-- kollisionen

free_sprites = {0, 1, 2, 11, 12, 13, 20, 24, 25, 29, 31, 37, 41, 42, 57, 91, 101, 107, 108, 109, 111, 117, 123, 124}
blocking_zones = { {16, 19, 9, 1}, {27, 19, 6, 1}, {5, 18, 9, 3}, {66, 13, 5, 1}, {73, 13, 5, 1}, {80, 13, 6, 1}, {80, 19, 6, 1}, {72, 19, 5, 1}, {64, 19, 5, 1}, {56, 19, 5, 1}, {26, 13, 10, 1}, {16, 13, 7, 1}, {2, 7, 88, 1} }
free_zones = { {2, 8, 62, 1}, {15, 16, 23, 1}, {53, 16, 37, 1}, {5, 22, 13, 1}, {24, 22, 14, 1}, {55, 22, 33, 1}, {40, 22, 9, 1}, {70, 8, 20, 1}, {65, 9, 5, 1}, {19, 23, 5, 1}, {38, 20, 2, 1}, {49, 21, 2, 1}, {51, 20, 1, 1}, {40, 21, 1, 1}, {72, 7, 1, 1}, {45, 6, 1, 3}, {16, 7, 3, 1}, }

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
        local is_free = false
        for _, sprite in ipairs(free_sprites) do
            if tile_id == sprite then
                is_free = true
                break
            end
        end
        if not is_free then
            return true
        end
    end
    return false
end

-- textboxen und item bar

function draw_textbox(text, player_x, player_y, width, height)
    local camera_x = stat(26)  -- kamera-x-offset
    local camera_y = stat(27)  -- kamera-y-offset

    -- calculate the player's position relative to the camera
    local relative_x = player_x - camera_x 
    local relative_y = player_y - camera_y

    -- center the textbox above the player's head
    local center_x = relative_x + 59
    local center_y = relative_y - 20  -- adjust the y-offset to position above the player's head

    -- calculate the top-left corner of the textbox
    local x = center_x - width // 2
    local y = center_y - height // 2

    rectfill(x, y, x + width, y + height, 0)
    local lines = split(text, "\n")
    for i, line in ipairs(lines) do
        print(line, x + 4, y + 4 + (i - 1) * 6, 7)
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


-- spielerbewegung

function player_movement()
    -- keine bewegung bei dialogs
    if well_system.active or monolog_active or castletable_monolog_active or cat_dialog_1_active or cat_dialog_2_active then
        return  
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

    if not check_collision(new_px, new_py) then
        px, py = new_px, new_py
    end
    check_and_update_sprite()
end

-- schwimmen lol
function check_and_update_sprite()

    local sprite_x = flr(px / 8)
    local sprite_y = flr(py / 8)
    local target_sprite = mget(sprite_x, sprite_y)  
    
    if target_sprite == 24 then
        if direction == "right" then
            sprite = 83
        elseif direction == "left" then
            sprite = 84
        end
        animating = false  
    end
end



-- kameraeinstellungen

camera_bounds = {
    -- [area_id] = {x_min, x_max, y_min, y_max, cam_x, cam_y}
    [1] = {0, 93, 0, 32, nil, nil}, -- main map (dynamisch)
    [2] = {110, 126, 50, 63, 120, 57}, -- schloss (statisch)
    [3] = {67, 73, 37, 45, 70, 41}, -- baecker (statisch)
    [4] = {121, 127, 14, 23, 124, 20}, -- metzger (statisch)   
    [5] = {112, 127, 0, 11, 120, 6}, -- taverne (statisch)
    [6] = {81, 88, 38, 45, 84, 42}, -- haus (statisch)
    [7] = {69, 84, 52, 62, 77, 57}, -- freidhof (statisch)
    [8] = {95, 103, 50, 63, 99, 57}, -- kirche (statisch)
    [9] = {99, 107, 0, 10, 103, 5}, -- pfarrerzimmer (statisch)

}

function update_camera()
    local bounds = camera_bounds[current_area]  -- nutze jetzt `current_area` anstelle von `current_stage`
    
    if bounds then
        local x_min, x_max, y_min, y_max, cam_x, cam_y = unpack(bounds)
        
        -- dynamischer modus: kamera folgt dem spieler
        if cam_x == nil and cam_y == nil then
            local cam_x = px - 64
            local cam_y = py - 64
            
            -- stelle sicher, dass die kamera innerhalb der grenzen bleibt
            cam_x = mid(x_min * 8, cam_x, (x_max * 8) - 128)  -- -128 wegen der kamera-breite
            cam_y = mid(y_min * 8, cam_y, (y_max * 8) - 128)  -- -128 wegen der kamera-hれへhe
            
            camera(cam_x, cam_y)
        
        -- statischer modus: kamera bleibt an einer festen position
        else
            camera(cam_x * 8 - 64, cam_y * 8 - 64)  -- feste kamera-position
        end
    else
        -- standardkamera auf den spieler setzen, wenn keine bounds fれもr die area gefunden werden
        camera(px - 64, py - 64)
    end
end


for _, teleport in pairs(teleports) do
    -- hinteleportation
    if flr(px / 8) == teleport[1] and flr(py / 8) == teleport[2] then
        px = teleport[3] * 8  -- teleportiere den spieler zum ziel
        py = teleport[4] * 8

        -- area wechseln (z.b. schloss oder raum)
        current_area = get_area_by_coordinates(px, py)  -- hol dir die area basierend auf den koordinaten

        -- kamera wird automatisch angepasst, wenn `update_camera` aufgerufen wird
        update_camera()
    end
end


function get_area_by_coordinates(x, y)
    for area_id, bounds in pairs(camera_bounds) do
        local x_min, x_max, y_min, y_max = unpack(bounds)
        -- れうberprれもft, ob die aktuellen koordinaten innerhalb des bounds fれもr eine area liegen
        if x >= x_min * 8 and x <= x_max * 8 and y >= y_min * 8 and y <= y_max * 8 then
            return area_id  -- gibt die area_id zurれもck, wenn die koordinaten innerhalb des bereichs liegen
        end
    end
    return 1  -- standardwert (z.b. hauptkarte, falls keine area gefunden wird)
end


-- globale update funktion


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
    elseif current_stage == 5 then
        stage5_update()
    elseif current_stage == 6 then
        stage6_update()
    elseif current_stage == 7 then
        stage7_update()
    end
end

-- globale draw funktion


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
    elseif current_stage == 5 then
        stage5_draw()
    elseif current_stage == 6 then
        stage6_draw()
    elseif current_stage == 7 then
        stage7_draw()
    end

    spr(sprite, px, py)
    draw_roofs(px, py)
end











-- tab 1: stage 1 - spezifische spiellogik
local current_map_area = 1  -- standardwert, z.b. fれもr die hauptkarte

-- variablen und flags fれもr stage 1
monolog_active = false
monolog_stage = 1  -- monologstufe
monolog_completed = false
castletable_monolog_active = false  -- flag fれもr zweite textbox
castletable_monolog_stage = 1  -- monologstufe fれもr zweite textbox
castletable_monolog_completed = false  -- monolog abgeschlossen
tile_changed = false  -- flag fれもr kachelれさnderung
tile_animated = false  -- flag fれもr tile-animation
cat_dialog_1_active = false  -- flag fれもr katzen-monolog
cat_dialog_1_stage = 1  -- monologstufe fれもr katzen-monolog
cat_dialog_1_completed = false  -- monolog abgeschlossen

-- monologtexte fれもr stage 1
monolog_text = {
    "ein offenes tor?\ndas fuehlt sich\nnicht richtig an … ",
    "warum ist niemand\nhier, um es zu\nbewachen?"
}

castletable_monolog_texts = {
    "seltsam...",
    "die teller und tassen\nsind noch halb voll",
    "haben sie das festmahl ab-\ngebrochen oder ist das\nhier ihre art\nvon gastfreundschaft?",
    "diese menschen sind\nso verschwenderisch..."
}

-- monolog fれもr die katze (stage 1)
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

function _init()
    animating = true  -- animation starten
    tile_changed = false  -- kachelれさnderung als false setzen
    tile_animated = false  -- kachel-animation als false setzen
    current_room = nil  -- initialisiert als nil
    current_stage = 1 -- start in stage 1
    monolog_active = true -- monolog aktivieren beim start
end

-- flagge, die speichert, ob der spieler die zone betreten hat
local zone_entered = false

-- update-funktion fれもr stage 1
function stage1_update()

    current_area = get_area_by_coordinates(px, py)  -- ermittelt die stage des spielers basierend auf den koordinaten
    update_camera()    
    
    
    
    -- monolog fれもr stage 1
    if monolog_active then
        if btnp(❎) then
            monolog_stage += 1
            if monolog_stage > #monolog_text then
                monolog_active = false
                animating = true  -- starte die animation    
            end
        end
        
    elseif castletable_monolog_active then
        if btnp(❎) then
            castletable_monolog_stage += 1
            if castletable_monolog_stage > #castletable_monolog_texts then
                castletable_monolog_active = false
                castletable_monolog_completed = true  -- monolog abgeschlossen
            end
        end
        
    elseif animating then
        -- animation, wenn spieler auf der karte ist
        if py > 28 * 8 then
            py = py - speed
            sprite = direction == "right" and 64 + flr((t() % 0.2) * 10) or 66 + flr((t() % 0.2) * 10)
        else
            animating = false
            initial_monolog_active = false  -- ende der animation, bewegung freigeben
        end
    else
        -- zone betreten, um zweiten monolog zu starten
        if not castletable_monolog_active and not castletable_monolog_completed and
           flr(px / 8) >= 115 and flr(px / 8) < 115 + 10 and
           flr(py / 8) == 59 then
            castletable_monolog_active = true
            castletable_monolog_stage = 1
        end

        -- teleportation zu schloss
        if flr(px / 8) == 45 and flr(py / 8) == 7 then
            px = 120 * 8
            py = 61 * 8
            current_area = 2
            update_camera()
        end

        -- zurueckteleportation von schloss
        if flr(px / 8) == 120 and flr(py / 8) == 63 then
            px = 45 * 8
            py = 9 * 8
            current_area = 1  -- setze die area zurれもck auf die ursprれもngliche area
            update_camera()

            -- kachelれさnderung an (58, 13) und animation starten
            if not tile_changed then
                mset(58, 13, 98)  -- れさndere kachel-sprite
                tile_changed = true
            end
            
            -- setze flag fれもr zone_entered
            zone_entered = true
        end
        
        -- katzen-monolog stage 1 starten (zone angepasst auf 57, 12, 3, 3) und nur wenn zone_entered wahr ist
        if zone_entered and not cat_dialog_1_active and not cat_dialog_1_completed and
           flr(px / 8) >= 57 and flr(px / 8) < 60 and
           flr(py / 8) >= 12 and flr(py / 8) < 15 then
            cat_dialog_1_active = true
            cat_dialog_1_stage = 1
        end

        -- katzen-monolog fortsetzen (stage 1)
        if cat_dialog_1_active then
            if btnp(❎) then
                cat_dialog_1_stage += 1
                if cat_dialog_1_stage > #cat_dialog_1 then
                    cat_dialog_1_active = false
                    cat_dialog_1_completed = true  -- monolog abgeschlossen
                    
                    -- kacheln れさndern nach monolog_1
                    mset(69, 15, 111)   -- れ░ndere sprite von kachel 45, 8 zu 77
                    mset(69, 16, 107)   -- れ░ndere sprite von kachel 45, 8 zu
                    mset(76, 15, 111)   -- れ░ndere sprite von kachel 45, 8 zu 77
                    mset(76, 16, 107)   -- れ░ndere sprite von kachel 45, 8 zu
           
                    -- kachel an (43, 18) れさndern und animation starten
                    mset(43, 18, 124) -- beispiel-kachelれさnderung
                    tile_animated = true  -- animation starten
                    
                    current_stage = 2
                end
            end
        end
    end
end

-- draw-funktion fれもr stage 1
function stage1_draw()
    
    cls()
    map(0, 0, 0, 0, 128, 64)  -- karte zeichnen

    -- zeichnen der monologe
    if monolog_active then
        draw_textbox(monolog_text[monolog_stage], px, py, 120, 40)
    elseif castletable_monolog_active then
        draw_textbox(castletable_monolog_texts[castletable_monolog_stage], px, py, 120, 40)
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

-- allgemeine variablen
local zones = {
    meat = {active = false, completed = false, taken = false, text = "druecke x um fleisch zu nehmen", zone = {122, 17, 3, 2}, sprite = 34},
    fish = {active = false, completed = false, taken = false, text = "druecke x um fisch zu nehmen", zone = {42, 17, 3, 3}, sprite = 28},
    bread = {active = false, completed = false, text = {
        "es ist brot!!!", "das meinte sie\naber wahrscheinlich\nnicht.", "ich zumindest\nmag brot nicht\nsonderlich..."
    }, stage = 1, zone = {68, 39, 5, 2}},
    table = {zone = {59, 12, 5, 3}, active = false, text = "druecke x um auf tisch zu legen", fish_on = false, meat_on = false},
    cat_dialog = {active = false, stage = 1, completed = false, text = {
        "nanu!?", "oh, wie wunderbar!", "endlich etwas, das schmeckt!", "ich wuenschte,\nich koennte dir\nmehr bieten,", 
        "aber als kleines\ndankeschoen nimm\ndas hier.", "es stammt noch\naus dem schloss...", "vielleicht kannst du\nja etwas damit anfangen.", 
        "du solltest mal\nan einen ort schauen,\n nicht weit von hier.", "reisende machen dort\ngerne halt.", 
        "aber pass auf -\nder koeter hat dort\ninzwischen das sagen.", "sein besitzer ist weg, \nund jetzt laeuft da\ndieser nervige\nklaeffer rum!"
    }, coin_sprite = 68, coin_obtained = false}
}

local teleport_zones = {
    {from = {69, 15}, to = {125, 21}, area_id = 4},  -- metzger
    {from = {125, 23}, to = {69, 17}, area_id = 1},  -- back to main map
    {from = {76, 15}, to = {71, 43}, area_id = 3},   -- bれさckerei
    {from = {71, 45}, to = {76, 17}, area_id = 1},   -- back to main map
    {from = {45, 7}, to = {120, 61}, area_id = 2},   -- schloss
    {from = {120, 63}, to = {45, 9}, area_id = 1}    -- back to main map
}

-- funktionen
local function check_zone(px, py, zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) < zone[1] + zone[3] and flr(py / 8) >= zone[2] and flr(py / 8) < zone[2] + zone[4]
end

local function handle_item_dialog(item)
    local zone = zones[item]
    if check_zone(px, py, zone.zone) and not zone.taken and not zone.completed then
        zone.active = true
        if btnp(5) then
            zone.taken = true
            zone.completed = true
            -- fix: only update tile for meat, not fish
            if item == "meat" then
                mset(zone.zone[1] + 2, zone.zone[2], 12)
            end
        end
    else
        zone.active = false
    end
end

local function handle_bread_dialog()
    local zone = zones.bread
    if check_zone(px, py, zone.zone) and not zone.completed then
        zone.active = true
        if btnp(5) then
            zone.stage = zone.stage + 1
            if zone.stage > #zone.text then
                zone.stage = 1
                zone.active = false
                zone.completed = true
            end
        end
    else
        zone.active = false
        if not zone.completed then zone.stage = 1 end
    end
end

local function handle_table_interaction()
    local zone = zones.table
    if check_zone(px, py, zone.zone) and (zones.fish.taken or zones.meat.taken) then
        zone.active = true
        if btnp(5) then
            if zones.fish.taken and not zone.fish_on then
                zone.fish_on = true
                zones.fish.taken = false
                mset(60, 13, 22)
            elseif zones.meat.taken and not zone.meat_on then
                zone.meat_on = true
                zones.meat.taken = false
                mset(61, 13, 18)
            end
        end
    else
        zone.active = false
    end
end

local function handle_cat_dialog()
    local zone = zones.cat_dialog
    if zone.active then
        if btnp(5) then
            zone.stage = zone.stage + 1
            if zone.stage > #zone.text then
                zone.active = false
                zone.completed = true
                zone.coin_obtained = true
                mset(72, 7, 111) mset(72, 8, 107) mset(29, 21, 111) mset(29, 22, 107)
                current_stage = 3
            end
        end
    elseif zones.table.meat_on and zones.table.fish_on and not zone.completed then
        zone.active = true
        zone.stage = 1
    end
end

function stage2_update()
    
    
    -- kachelanimation
    if tile_animated and not zones.fish.completed and not zones.fish.taken then
        mset(43, 18, 123 + flr((t() * 5) % 2))
    elseif zones.fish.taken and zones.fish.completed then
        mset(43, 18, 24)
    end

    -- teleportation
    for _, zone in pairs(teleport_zones) do
        if flr(px / 8) == zone.from[1] and flr(py / 8) == zone.from[2] then
            px = zone.to[1] * 8
            py = zone.to[2] * 8
            current_area = zone.area_id  -- setze die aktuelle area id basierend auf dem teleportationsziel
            update_camera()  -- kamera aktualisieren
        end
    end

    -- dialoge und interaktionen
    handle_item_dialog("meat")
    handle_item_dialog("fish")
    handle_bread_dialog()
    handle_table_interaction()
    handle_cat_dialog()
    update_camera()
end

function stage2_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)
    spr(sprite, px, py)
    if tile_animated then mset(43, 18, 123 + flr((t() * 5) % 2)) end

    -- dialoge zeichnen
    for _, item in pairs({"meat", "fish"}) do
        if zones[item].active then draw_dialog_near_player(zones[item].text, 10) end
    end
    if zones.table.active then draw_dialog_near_player(zones.table.text, 10) end
    if zones.bread.active then draw_textbox(zones.bread.text[zones.bread.stage], px, py, 120, 40) end
    if zones.cat_dialog.active then draw_textbox(zones.cat_dialog.text[zones.cat_dialog.stage], px, py - 5, 120, 30) end

    -- items in der leiste
    for _, item in pairs({"meat", "fish"}) do
        if zones[item].taken and not zones.table[item .. "_on"] then
            draw_item_in_ui(zones[item].sprite, item == "meat" and -7 or -5)
        end
    end
    if zones.cat_dialog.coin_obtained then draw_item_in_ui(zones.cat_dialog.coin_sprite, -7) end
end

function draw_dialog_near_player(dialog_text, offset_y)
    if flr(time() * 2) % 2 == 0 then
        local camera_x, camera_y = stat(26), stat(27)
        draw_textbox(dialog_text, px - camera_x, py - camera_y - offset_y, 120, 20)
    end
end






















-- stage 3 specific logic

local coin_count = 1 -- startwert: katze hat eine mれもnze gegeben
local stage3_coin_obtained = false -- neue variable zum halten des mれもnzenzustands
local hide_coin_ui = false -- steuert, ob die mれもnze oben links angezeigt wird

-- allgemeine variablen fれもr mれもnzen und ihre zonen
local coin_zones = {
    {taken = false, sprite = 68, x = 83, y = 41, w = 3, h = 3},
    {taken = false, sprite = 68, x = 118, y = 53, w = 3, h = 3},
    {taken = false, sprite = 68, x = 113, y = 3, w = 3, h = 3}
}

local teleport_zones = {
        {from = {29, 21}, to = {86, 43}, area_id = 6}, -- haus 
        {from = {86, 45}, to = {29, 23}, area_id = 1}, -- back to map 
        {from = {69, 15}, to = {125, 21}, area_id = 4},  -- metzger
        {from = {125, 23}, to = {69, 17}, area_id = 1},  -- back to main map
        {from = {76, 15}, to = {71, 43}, area_id = 3},   -- bれさckerei
        {from = {71, 45}, to = {76, 17}, area_id = 1},   -- back to main map
        {from = {45, 7}, to = {120, 61}, area_id = 2},   -- schloss
        {from = {120, 63}, to = {45, 9}, area_id = 1},    -- back to main map
        {from = {72, 7}, to = {117, 9}, area_id = 5}, -- taverne
        {from = {117, 11}, to = {72, 9}, area_id = 1} -- back to map
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
    if zones.cat_dialog.coin_obtained and not stage3_coin_obtained then
        stage3_coin_obtained = true -- markiere, dass die mれもnze in stage 3 erhalten wurde
    end

-- teleportation
    for _, zone in pairs(teleport_zones) do
        if flr(px / 8) == zone.from[1] and flr(py / 8) == zone.from[2] then
            px = zone.to[1] * 8
            py = zone.to[2] * 8
            
            dog_dialog_completed = false
            dog_dialog_active = false
            dog_dialog_stage = 1
            current_area = zone.area_id  -- setze die aktuelle area id basierend auf dem teleportationsziel
            update_camera()  -- kamera aktualisieren
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
    update_camera()
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
end

























local teleport_zones = {
        {from = {29, 21}, to = {86, 43}, area_id = 6}, -- haus 
        {from = {86, 45}, to = {29, 23}, area_id = 1}, -- back to map 
        {from = {69, 15}, to = {125, 21}, area_id = 4},  -- metzger
        {from = {125, 23}, to = {69, 17}, area_id = 1},  -- back to main map
        {from = {76, 15}, to = {71, 43}, area_id = 3},   -- bれさckerei
        {from = {71, 45}, to = {76, 17}, area_id = 1},   -- back to main map
        {from = {45, 7}, to = {120, 61}, area_id = 2},   -- schloss
        {from = {120, 63}, to = {45, 9}, area_id = 1},    -- back to main map
        {from = {72, 7}, to = {117, 9}, area_id = 5}, -- taverne
        {from = {117, 11}, to = {72, 9}, area_id = 1} -- back to map
}

local player_zone = {x = 71, y = 10, w = 4, h = 2}
local grim_reaper = {pos = {x = 64 * 8, y = 11 * 8}, target = {x = 18 * 8, y = 10 * 8}, moving = false, speed = 1.5, disappear = false, phase = 1}
local graveyard_zone = {x = 75, y = 58, w = 4, h = 4}
local graveyard_monolog = {
    text = {
        "so viele graeber...\nund niemand kuemmert\nsich darum.",
        "alles ist ueberwuchert,\nkeine blumen,\nkein zeichen von besuch.",
        "das fuehlt sich einfach...\nnicht richtig an.",
        "die verstorbenen\nverdienen respekt.",
        "ich werde\njedem von ihnen\nein letztes geschenk machen-",
        "das mindeste,\nwas ich tun kann."
    },
    stage = 1, active = false, completed = false
}

local flower_count = 0  -- der zれさhler fれもr die blumen
local max_flower_count = 24
local graveyard_returned = false
local floweredup = false
local graveyard_monolog_2 = {
    text = {
        "lege blumen mit x\nvor die graeber.",
        "aber lasse dich\nnicht erwischen!"
    },
    stage = 1, active = false, completed = false
}

-- funktion fれもr die interaktion mit einem tile
function check_tile_interaction()
    -- berechne die tile-koordinaten des spielers
    local player_tile_x = flr(px / 8)
    local player_tile_y = flr(py / 8)
    
    -- れうberprれもfe, ob der spieler auf einem tile mit flagge 7 ist
    local tile_flag = fget(mget(player_tile_x, player_tile_y), 7)  -- fget れもberprれもft, ob ein tile eine bestimmte flagge hat
    if tile_flag and btnp(❎) then  -- wenn die taste x gedrれもckt wurde und das tile flagge 7 hat
        mset(player_tile_x, player_tile_y, 25)        
        flower_count += 1
    end
end

-- monolog-logik fれもr den ersten monolog
function check_graveyard_monolog()
    if not graveyard_monolog.completed and px >= graveyard_zone.x * 8 and px < (graveyard_zone.x + graveyard_zone.w) * 8 and py >= graveyard_zone.y * 8 and py < (graveyard_zone.y + graveyard_zone.h) * 8 then
        graveyard_monolog.active = true
    end
    if graveyard_monolog.active and btnp(❎) then
        graveyard_monolog.stage += 1
        if graveyard_monolog.stage > #graveyard_monolog.text then
            graveyard_monolog.active, graveyard_monolog.completed = false, true
        end
    end
end

-- funktion zum れうberprれもfen des zweiten monologs (graveyard_monolog_2)
function check_graveyard_monolog_2()
    -- aktivierung des zweiten monologs, wenn alle blumen gesammelt wurden
    if floweredup and px >= graveyard_zone.x * 8 and px < (graveyard_zone.x + graveyard_zone.w) * 8 and py >= graveyard_zone.y * 8 and py < (graveyard_zone.y + graveyard_zone.h) * 8  and not graveyard_monolog_2.completed then
        graveyard_monolog_2.active = true
    end

    -- fortschreiten des monologs
    if graveyard_monolog_2.active then
        if btnp(❎) then
            graveyard_monolog_2.stage += 1
            if graveyard_monolog_2.stage > #graveyard_monolog_2.text then
                graveyard_monolog_2.active = false
                graveyard_monolog_2.completed = true
                current_stage = 5  -- wechsel zu stage 5
            end
        end
    end
end

-- funktion zum zeichnen des monologs
function draw_graveyard_monolog()
    if graveyard_monolog.active then
        draw_textbox(graveyard_monolog.text[graveyard_monolog.stage], px - stat(26), py - stat(27), 112, 40)
    end
end

-- funktion zum zeichnen von graveyard_monolog_2
function draw_graveyard_monolog_2()
    if graveyard_monolog_2.active then
        draw_textbox(graveyard_monolog_2.text[graveyard_monolog_2.stage], px - stat(26), py - stat(27), 112, 40)
    end
end


-- stage 4 update
function stage4_update()
      
   
    if flower_count >= 24 then
        floweredup = true
    end
        
    if not sprite_78_drawn then
        sprite_78_drawn = true
    end
     
    if not grim_reaper.moving and flr(px / 8) >= player_zone.x and flr(px / 8) < player_zone.x + player_zone.w and flr(py / 8) >= player_zone.y and flr(py / 8) < player_zone.y + player_zone.h then
        grim_reaper.moving = true
    end

    if grim_reaper.moving then
        if grim_reaper.phase == 1 and grim_reaper.pos.x > grim_reaper.target.x then
            grim_reaper.pos.x -= grim_reaper.speed
        elseif grim_reaper.phase == 1 then
            grim_reaper.phase, grim_reaper.target.y = 2, 7 * 8
        elseif grim_reaper.phase == 2 and grim_reaper.pos.y > grim_reaper.target.y then
            grim_reaper.pos.y -= grim_reaper.speed
        elseif grim_reaper.phase == 2 then
            grim_reaper.moving, grim_reaper.disappear = false, true
        end
    end

    -- teleportation
    for _, zone in pairs(teleport_zones) do
        if flr(px / 8) == zone.from[1] and flr(py / 8) == zone.from[2] then
            px = zone.to[1] * 8
            py = zone.to[2] * 8
            current_area = zone.area_id  -- setze die aktuelle area id basierend auf dem teleportationsziel
            update_camera()  -- kamera aktualisieren
        end
    end


    --  graveyard teleport
    if flr(px / 8) >= 16 and flr(px / 8) < 20 and flr(py / 8) >= 8 and flr(py / 8) < 9 then
        px, py = 76 * 8, 61 * 8
        current_area = 7
        update_camera()
    elseif flr(px / 8) >= 76 and flr(px / 8) < 78 and flr(py / 8) >= 63 and flr(py / 8) < 65 then
        px, py = 16 * 8, 10 * 8
        current_area = 1
        update_camera()
        graveyard_returned = true
    end

    check_graveyard_monolog()
    check_graveyard_monolog_2()
    check_tile_interaction()
end

-- stage 4 draw
function stage4_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)

    draw_graveyard_monolog()  
    draw_graveyard_monolog_2()
    
    
    if sprite_78_drawn then
        draw_item_in_ui(78, -7, nil)
    end
    
    if not grim_reaper.disappear then
        spr(97, grim_reaper.pos.x, grim_reaper.pos.y)
    end
    
    print("x " .. flower_count, 20, 5, 7)  -- zeichne den flower_count neben sprite 57
     
    if graveyard_returned then
        draw_item_in_ui(57, -5, flower_count)  -- hier wird das sprite 57 und der flower_count gezeichnet
    end
end






















-- stage 5
local current_area = 7
local flower_count = 24
local flower_sprites = {117, 57} -- ids der sprites mit flagge 7

-- gegner-definition und animation
local enemies = {
    {pos = {x = 70 * 8, y = 54 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
    {pos = {x = 83 * 8, y = 54 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
}

local grim_reaper = {
    pos = {x = 69 * 8, y = 53 * 8}, -- startposition
    target = {x = 76 * 8, y = 53 * 8}, -- zielposition
    moving = false, -- gibt an, ob er sich bewegt
    speed = 1, -- geschwindigkeit
    disappear = false, -- gibt an, ob er verschwinden soll
    phase = 1 -- phase der bewegung
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
            "drum bete still\nfuer deinen leib,\ndie entscheidung wird\nnicht einfach sein."
        },
        trigger_zone = {74, 79, 53, 56}
    }
}

local enemies_disappearing = false

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
                printh("dialog completed, transition to stage 6") -- log transition to stage 6

                current_stage = 6
            
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

-- funktion, um alle blumen zurれもckzusetzen
function reset_flowers()
    for x = 70, 70 + 13 - 1 do
        for y = 53, 53 + 9 - 1 do
            local tile = mget(x, y)
            for _, flower_sprite in pairs(flower_sprites) do
                if tile == flower_sprite then
                    mset(x, y, 25)
                end
            end
        end
    end
end

-- funktion, um den levelzustand zurれもckzusetzen
function reset_stage5()
    px, py = 77 * 8, 61 * 8
    flower_count = 24
    reset_flowers()

    print("stage 5 reset", 73 * 8, 55 * 8, 7) -- print text at coordinates 73, 55

end

-- funktion, um zufれさllige bewegungsrichtung der gegner zu setzen
function update_enemy_movement(enemy)
    if rnd() > 0.9 then
        enemy.dx = flr(rnd(3)) - 1 -- zufれさllige x-richtung (-1, 0, 1)
        enemy.dy = flr(rnd(3)) - 1 -- zufれさllige y-richtung (-1, 0, 1)
    end

    local new_x = enemy.pos.x + enemy.dx
    local new_y = enemy.pos.y + enemy.dy
    local tile_x = flr(new_x / 8)
    local tile_y = flr(new_y / 8)

    if tile_x >= 70 and tile_x < 70 + 13 and tile_y >= 53 and tile_y < 53 + 8 then
        if fget(mget(tile_x, tile_y), 6) == false then
            enemy.pos.x = new_x
            enemy.pos.y = new_y
        end
    end
end

-- funktion, um kollisionen zwischen dem spieler und den gegnern zu れもberprれもfen
function check_enemy_collision()
    for _, enemy in pairs(enemies) do
        if px < enemy.pos.x + 8 and px + 8 > enemy.pos.x and py < enemy.pos.y + 8 and py + 8 > enemy.pos.y then
            reset_stage5()
            break
        end
    end
end

-- funktion, um blume unter flagge-6-tile zu setzen
function place_flower_under_tile()
    local tile_x = flr(px / 8)
    local tile_y = flr(py / 8)

    if fget(mget(tile_x, tile_y - 1), 6) then
        if btnp(❎) then
            local current_tile = mget(tile_x, tile_y)
            local is_flower = false

            for _, flower_sprite in pairs(flower_sprites) do
                if current_tile == flower_sprite then
                    is_flower = true
                    break
                end
            end

            if not is_flower then
                local flower_tile = flower_sprites[flr(rnd(#flower_sprites)) + 1]
                mset(tile_x, tile_y, flower_tile)
                flower_count = flower_count - 1
            end
        end
    end
end

-- stage 5 update-logik
function stage5_update()

printh("stage 5") -- log transition to stage 6


    for _, enemy in pairs(enemies) do
        update_enemy_movement(enemy)
    end

    check_enemy_collision()
    place_flower_under_tile()

    if flower_count == 0 then
        handle_enemies_disappearance()
    end

    if enemies_disappearing and all_enemies_gone() then
        grim_reaper.moving = true
        move_grim_reaper()
    end

    if grim_reaper_reached_destination() and player_in_zone(dialog_system.grimreaper.trigger_zone) and not dialog_system.grimreaper.completed then
        start_dialog(dialog_system.grimreaper)
    end

    update_dialog(dialog_system.grimreaper)
end

-- stage 5 zeichnen
function stage5_draw()

    draw_item_in_ui(78, -7, nil)
    draw_item_in_ui(57, -5, flower_count)
    print("x " .. flower_count, 20, 5, 7)

    for _, enemy in pairs(enemies) do
        spr(enemy.sprite, enemy.pos.x, enemy.pos.y)
    end

    if not grim_reaper.disappear then
        spr(96, grim_reaper.pos.x, grim_reaper.pos.y)
    end

    draw_dialog(dialog_system.grimreaper, px, py)
end

-- gegner verschwinden lassen
function handle_enemies_disappearance()
    if not enemies_disappearing then
        enemies_disappearing = true
        for _, enemy in pairs(enemies) do
            enemy.disappearing = true
            enemy.anim_timer = 0
        end
    end

    for _, enemy in pairs(enemies) do
        if enemy.disappearing then
            enemy.anim_timer = enemy.anim_timer + 1
            if enemy.anim_timer % 10 < 5 then
                enemy.sprite = 81
            else
                enemy.sprite = 82
            end

            if enemy.anim_timer > 30 then
                enemy.pos.x, enemy.pos.y = -100, -100
            end
        end
    end
end

-- check if all enemies are gone
function all_enemies_gone()
    for _, enemy in pairs(enemies) do
        if enemy.pos.x ~= -100 or enemy.pos.y ~= -100 then
            return false
        end
    end
    return true
end

-- move grim reaper into the scene
function move_grim_reaper()
    if grim_reaper.moving then
        if grim_reaper.pos.x < grim_reaper.target.x then
            grim_reaper.pos.x += grim_reaper.speed
        else
            grim_reaper.moving = false
            grim_reaper.disappear = false -- ensure he does not disappear after reaching the destination
        end
    end
end

-- check if grim reaper reached destination
function grim_reaper_reached_destination()
    return grim_reaper.pos.x >= grim_reaper.target.x and not grim_reaper.moving
end




















local teleport_zones = {
        {from = {29, 21}, to = {86, 43}, area_id = 6}, -- haus 
        {from = {86, 45}, to = {29, 23}, area_id = 1}, -- back to map 
        {from = {69, 15}, to = {125, 21}, area_id = 4},  -- metzger
        {from = {125, 23}, to = {69, 17}, area_id = 1},  -- back to main map
        {from = {76, 15}, to = {71, 43}, area_id = 3},   -- bれさckerei
        {from = {71, 45}, to = {76, 17}, area_id = 1},   -- back to main map
        {from = {45, 7}, to = {120, 61}, area_id = 2},   -- schloss
        {from = {120, 63}, to = {45, 9}, area_id = 1},    -- back to main map
        {from = {72, 7}, to = {117, 9}, area_id = 5}, -- taverne
        {from = {117, 11}, to = {72, 9}, area_id = 1}, -- back to map
        {from = {28, 7}, to = {99, 61}, area_id = 8}, -- kirche
        {from = {99, 63}, to = {28, 9}, area_id = 1}, -- back to map
        {from = {29, 15}, to = {103, 8}, area_id = 9}, -- pfarrertzimmer
        {from = {103, 10}, to = {29, 17}, area_id = 1} -- back to map
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

well_system = {
    active = false,
    choice = 1, -- 1 = ja, 2 = nein
    completed = false,
    text = "du moechtest\nwirklich in den\nbrunnen springen??",
    trigger_zone = {56, 60, 9, 10}, -- bereich des brunnens
    animation = false, -- brunnen-animation aktiv?
    anim_timer = 0 -- timer fれもr animation
}

-- track if the player has entered the well zone
local well_zone_entered = false 

function start_well_dialog()
    if not well_system.active and not well_system.completed then
        well_system.active = true
        well_system.choice = 1 -- default to "yes"
    end
end
function update_well_dialog()
    if well_system.active then
        -- navigate between yes and no
        if btnp(0) then -- left
            well_system.choice = 1
        elseif btnp(1) then -- right
            well_system.choice = 2
        end

        -- confirm with x
        if btnp(5) then
            if well_system.choice == 1 then
                -- player chooses to jump into the well
                well_system.animation = true
                well_system.active = false
                well_system.anim_timer = 0
            else
                -- player declines
                well_system.active = false
            end
            well_system.completed = true -- mark dialog as completed
        end
    end

    -- handle animation
    if well_system.animation then
        well_system.anim_timer += 1
        if well_system.anim_timer < 10 then
            -- black screen
            cls(0)
        elseif well_system.anim_timer < 20 then
            -- teleport player to 15,58
            px, py = 15 * 8, 58 * 8
        else
            well_system.animation = false
            current_stage = 7
        end
    end
end

-- function to draw the well dialog
function draw_well_dialog(player_x, player_y)
    if well_system.active then
        -- draw the main dialog textbox
        draw_textbox(well_system.text, player_x, player_y, 120, 40)

        -- calculate the position inside the textbox
        local camera_x = stat(26)  -- kamera-x-offset
        local camera_y = stat(27)  -- kamera-y-offset

        local relative_x = player_x - camera_x
        local relative_y = player_y - camera_y

        local x = relative_x - 60
        local y = relative_y - 30

        local ja_color = well_system.choice == 1 and 7 or 6
        local nein_color = well_system.choice == 2 and 7 or 6

        -- draw the 'ja' and 'nein' options inside the same textbox
        print("ja", x + 5 , y - 2, ja_color)
        print("nein", x + 95, y - 2, nein_color)
    end
end


function stage6_update()
    
    -- well zone logic
    local in_well_zone = player_in_zone(well_system.trigger_zone)
    if in_well_zone and not well_system.active and not well_zone_entered then
        start_well_dialog()
        well_zone_entered = true
    elseif not in_well_zone and well_zone_entered then
        well_zone_entered = false
        well_system.completed = false -- reset completion status upon leaving the zone
    end

    mset(29, 15, 111) 
    mset(29, 16, 107) 
    mset(28, 6, 93) 
    mset(28, 7, 109)
    mset(28, 8, 109)

     -- teleportation
    for _, zone in pairs(teleport_zones) do
        if flr(px / 8) == zone.from[1] and flr(py / 8) == zone.from[2] then
            px = zone.to[1] * 8
            py = zone.to[2] * 8
            current_area = zone.area_id  -- setze die aktuelle area id basierend auf dem teleportationsziel
            update_camera()  -- kamera aktualisieren
        end
    end

    --  graveyard teleport
    if flr(px / 8) >= 16 and flr(px / 8) < 20 and flr(py / 8) >= 8 and flr(py / 8) < 9 then
        px, py = 76 * 8, 61 * 8
        current_area = 7
        update_camera()
    elseif flr(px / 8) >= 76 and flr(px / 8) < 78 and flr(py / 8) >= 63 and flr(py / 8) < 65 then
        px, py = 16 * 8, 10 * 8
        current_area = 1
        update_camera()
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
    update_well_dialog()
    update_camera()
end


function stage6_draw()
    if not well_system.animation or well_system.anim_timer < 30 then
        cls()
        map(0, 0, 0, 0, 128, 64)

        spr(96, 76 * 8, 53 * 8)

        draw_dialog(dialog_system.grimreaper, px, py)
        draw_dialog(dialog_system.bible, px, py)
        draw_dialog(dialog_system.diary, px, py)
        draw_well_dialog(px, py)
    elseif well_system.anim_timer >= 30 and well_system.anim_timer < 60 then
        cls(0) -- blackout screen
    end
end





















local door_open = false
local door_zone = {x = 21, y = 39, w = 3, h = 3} -- zone fれもr den hund
local snake_active = false
local snake_x, snake_y = 3 * 8, 58 * 8
local snake_target_x, snake_target_y = 11 * 8, 42 * 8
local snake_direction = "up"
local snake_returning = false
local snake_collision_timer = 0
local key_item = {
    x = 36, -- tile-x-koordinate
    y = 58, -- tile-y-koordinate
    sprite_id = 104, -- sprite-id fれもr den schlれもssel
    trigger_zone = {35, 38, 57, 60}, -- trigger-zone fれもr einsammeln
    collected = false -- status: wurde der schlれもssel eingesammelt?
}
local key_count = 0 -- anzahl der schlれもssel (fれもr die ui)

-- funktion zur zone-れうberprれもfung
function player_in_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) <= zone[2] and
           flr(py / 8) >= zone[3] and flr(py / 8) <= zone[4]
end

function stage7_update()
    -- schlれもssel einsammeln
    if not key_item.collected and player_in_zone(key_item.trigger_zone) then
        if btnp(5) then
            key_item.collected = true
            key_count = key_count + 1
        end
    end

    -- spieler in der tれもr-zone
    local player_in_door_zone = flr(px / 8) >= door_zone.x and flr(px / 8) < door_zone.x + door_zone.w and
                                flr(py / 8) >= door_zone.y and flr(py / 8) < door_zone.y + door_zone.h

    if key_item.collected and player_in_door_zone then
        if btnp(5) then
            door_open = true
            mset(22, 39, 111)
            mset(22, 40, 107)
        end
    end

    -- schlange aktivieren
    if flr(px / 8) == 3 and flr(py / 8) == 49 then
        snake_active = true
    end

    -- bewegung der schlange
    if snake_active then
        local snake_speed = 1.8 -- geschwindigkeit auf 1.8

        if not snake_returning then
            if snake_direction == "up" then
                snake_y -= snake_speed
                if snake_y <= 42 * 8 then
                    snake_direction = "right"
                end
            elseif snake_direction == "right" then
                snake_x += snake_speed
                if snake_x >= 11 * 8 then
                    snake_direction = "done"
                end
            end
        else
            if snake_direction == "right" then
                snake_x -= snake_speed
                if snake_x <= 3 * 8 then
                    snake_direction = "down"
                end
            elseif snake_direction == "down" then
                snake_y += snake_speed
                if snake_y >= 55 * 8 then
                    snake_returning = false
                    snake_direction = "up"
                end
            end
        end

        -- kollision mit spieler
        if abs(snake_x - px) < 8 and abs(snake_y - py) < 8 then
            if snake_collision_timer == 0 then -- nur beim ersten kontakt setzen
                snake_collision_timer = 15 -- bildschirm fれもr 15 frames rot
            end
            snake_returning = true
            snake_direction = "right"
        end
    end

    -- timer fれもr roten bildschirm
    if snake_collision_timer > 0 then
        snake_collision_timer -= 1
    end
end

function stage7_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)

    -- schlれもssel zeichnen
    if not key_item.collected then
        spr(key_item.sprite_id, key_item.x * 8, key_item.y * 8)
    end

    -- schlれもssel in der ui
    if key_count > 0 then
        draw_item_in_ui(104, -7)
    end

    -- schlange zeichnen (kachelanimation)
    if snake_active then
        local snake_tile = 123 + flr((t() * 5) % 2) -- animation wechselt zwischen 123 und 124
        spr(snake_tile, snake_x, snake_y)
    end

    -- rot-flash bei kollision (れもber alles gezeichnet)
    if snake_collision_timer > 0 then
        rectfill(0, 0, 127, 127, 8)
    end
end

function stage7_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)

    -- schlれもssel zeichnen
    if not key_item.collected then
        spr(key_item.sprite_id, key_item.x * 8, key_item.y * 8)
    end

    -- schlれもssel in der ui
    if key_count > 0 then
        draw_item_in_ui(104, -7)
    end

    -- schlange zeichnen (kachelanimation)
    if snake_active then
        local snake_tile = 123 + flr((t() * 5) % 2) -- animation wechselt zwischen 123 und 124
        spr(snake_tile, snake_x, snake_y)
    end

    -- rot-flash bei kollision (れもber alles gezeichnet)
    if snake_collision_timer > 0 then
        rectfill(0, 0, 127, 127, 8)
    end
end


