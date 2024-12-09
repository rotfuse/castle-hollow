-- tab 0: allgemeine spiellogik

function start_music()
    music(1, 0, 1) 
end

function _update()
    update_music_loop() 
end

function update_music_loop()
    if stat(52) > 7 then 
        music(1)          
    end
end

-- globale variablen

px, py = 31 * 8, 31 * 8
speed = 2  
direction = "right"
sprite = 64  
animating = false 

-- kollisionen

free_sprites = {1, 2, 11, 13, 20, 24, 25, 29, 31, 36, 37, 41, 42, 57, 91, 93, 101, 107, 108, 109, 111, 117, 121, 123, 124}
blocking_zones = { {16, 19, 9, 1}, {27, 19, 6, 1}, {5, 18, 9, 3}, {66, 13, 5, 1}, {73, 13, 5, 1}, {80, 13, 6, 1}, {80, 19, 6, 1}, {72, 19, 5, 1}, {64, 19, 5, 1}, {56, 19, 5, 1}, {26, 13, 10, 1}, {16, 13, 7, 1}, {2, 7, 88, 1} }
free_zones = { {2, 8, 62, 1}, {15, 16, 23, 1}, {53, 16, 37, 1}, {5, 22, 13, 1}, {24, 22, 14, 1}, {55, 22, 33, 1}, {40, 22, 9, 1}, {70, 8, 20, 1}, {65, 9, 5, 1}, {19, 23, 5, 1}, {38, 20, 2, 1}, {49, 21, 2, 1}, {51, 20, 1, 1}, {40, 21, 1, 1}, {72, 7, 1, 1}, {45, 6, 1, 3}, {16, 7, 3, 1}, {125, 42, 1, 1}, {104, 31, 22, 1}, {76, 63, 2, 2}, }

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

function draw_textbox(text, width, height, fixed_x, fixed_y)
    local camera_x = stat(26)  -- kamera-x-offset
    local camera_y = stat(27)  -- kamera-y-offset

    -- fixed position within the camera view
    local x = camera_x + fixed_x
    local y = camera_y + fixed_y

    -- draw the textbox background
    rectfill(x, y, x + width, y + height, 0)

    -- split the text into lines and draw each line inside the textbox
    local lines = split(text, "\n")
    for i, line in ipairs(lines) do
        print(line, x + 4, y + 4 + (i - 1) * 6, 7)
    end
end

function draw_item_in_ui(sprite_id,  y_offset, count)
    local camera_x = stat(26)
    local camera_y = stat(27)
    local item_x = px - camera_x - 1 
    local item_y = py - camera_y + (y_offset) 
    spr(sprite_id, item_x, item_y)
    -- coin count innerhalb des rechtecks zeichnen
    if count then
        print(count, item_x + 6, item_y - 3, 7)
    end
end

-- spielerbewegung

function player_movement()
   
    
      
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
    [10] = {2, 39, 34, 66, nil, nil}, -- brunnen (dynamisch)
    [11] = {32, 61, 35, 48, nil, nil}, -- kerker (dynamisch)
    [12] = {44, 60, 49, 66, nil, nil}, -- treppe (dynamisch)
    [13] = {102, 128, 28, 48, nil, nil}, -- thronsaal (dynamisch)

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


-- daecher ueber spielr zeichnen

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
    elseif current_stage == 8 then
        stage8_update()
    elseif current_stage == 9 then
        stage9_update()    
    end
end

-- globale draw funktion


function _draw()
    cls()
    
    -- wenn die karte gelれへscht ist, nur den schwarzen bildschirm anzeigen
    if map_cleared then
        cls(0)
        return
    end

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
    elseif current_stage == 8 then
        stage8_draw()
    elseif current_stage == 9 then
        stage9_draw()
    end        
end





-- tab 1: stage 1 - spezifische spiellogik

local roof_zones = { {5, 16, 9, 2}, {16, 12, 7, 2}, {27, 18, 6, 2}, {16, 18, 9, 2}, {26, 12, 10, 2}, {66, 11, 5, 3}, {73, 12, 5, 2}, {80, 12, 6, 2}, {80, 18, 6, 2}, {72, 18, 5, 2}, {64, 18, 5, 2}, {56, 18, 5, 2}}

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

monolog_text = {
    "nanu?\n\nein offenes tor.\n\nwie seltsam...\n\nwarum ist niemand hier,\num es zu bewachen?\n\n\n❎ zum uerberspringen"
}

castletable_monolog_texts = {
    "seltsam...",
    "die teller und tassen\nsind noch halb voll",
    "haben sie das festmahl ab-\ngebrochen oder ist das\nhier ihre art\nvon gastfreundschaft?",
    "diese menschen sind\nso verschwenderisch..."
}

cat_dialog_1 = {
    "oh? wer bist denn du?",  -- erste zeile
    "bist du etwa von hier?",  -- zweite zeile
    "mein herrchen hat mich\neinfach zurueckgelassen…\nund jetzt finde ich\nnichts mehr zu fressen.", 
    "nicht einmal die\nkleinen nager streunen\nnoch umher.\nalles, was ich hier finde,\nist dieses menschenzeug.", 
    "koerner! brot!\nunertraeglich!",  -- siebte zeile
    "sag, hast du nicht\nirgendwo fleisch\noder fisch gesehen?",  -- achte zeile
    "irgendetwas, das wir\nkatzen essen koennen?",  -- neunte zeile
    "ich verhungere sonst..."  -- zehnte zeile
}

function _init()
    animating = true  -- animation starten
    tile_changed = false  -- kachelれさnderung als false setzen
    tile_animated = false  -- kachel-animation als false setzen
    current_area = 1   -- initialisiert als nil
    current_stage = 1 -- start in stage 1
    monolog_active = true -- monolog aktivieren beim start
    px, py = 31*8, 31*8
    sfx(0)
end

local zone_entered = false

function stage1_update()

    current_area = get_area_by_coordinates(px, py)  -- ermittelt die stage des spielers basierend auf den koordinaten
    update_camera()    
        
    if monolog_active then
        if btnp(❎) then
            sfx(1)
            monolog_stage += 1
            if monolog_stage > #monolog_text then
                monolog_active = false
                start_music()
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
        
        -- zone fuer 2. dialog
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

            -- katze am marktplatz
            
            if not tile_changed then
                mset(58, 13, 98) 
                tile_changed = true
            end
            
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
                    
                    -- tueren aufmahcen
                    mset(69, 15, 111)   
                    mset(69, 16, 107)  
                    mset(76, 15, 111)  
                    mset(76, 16, 107)  
           
                    -- blubbern
                    mset(43, 18, 124)
                    tile_animated = true          
                    current_stage = 2
                end
            end
        end
    end
end

function stage1_draw()
    
    cls()
    map(0, 0, 0, 0, 128, 64)  -- karte zeichnen
    spr(sprite, px, py)
   
    draw_roofs(player_x, player_y)


    if monolog_active then
        draw_textbox(monolog_text[monolog_stage], 16*8, 16*8, 23 * 8, 16 * 8)  
    elseif castletable_monolog_active then
        draw_textbox(castletable_monolog_texts[castletable_monolog_stage], 115, 40, 113 * 8, 51 * 8)
    elseif cat_dialog_1_active then
        draw_textbox(cat_dialog_1[cat_dialog_1_stage], 115, 40, 51 * 8, 7 * 8)
    
    if tile_animated then
        local sprite_index = 123 + flr((t() * 5) % 2) 
        mset(43, 18, sprite_index)  
        
        end
    end
    if monolog_active then
        return 
    end
end







-- tab 2: stage 2 - spezifische spiellogik

local roof_zones = { {5, 16, 9, 2}, {16, 12, 7, 2}, {27, 18, 6, 2}, {16, 18, 9, 2}, {26, 12, 10, 2}, {66, 11, 5, 3}, {73, 12, 5, 2}, {80, 12, 6, 2}, {80, 18, 6, 2}, {72, 18, 5, 2}, {64, 18, 5, 2}, {56, 18, 5, 2}}
local zones = {
    meat = {active = false, completed = false, taken = false, text = "❎ um fleisch zu nehmen", zone = {122, 17, 3, 2}, sprite = 34},
    fish = {active = false, completed = false, taken = false, text = "❎ um fisch zu nehmen", zone = {42, 17, 3, 3}, sprite = 28},
    bread = {active = false, completed = false, text = {
        "es ist brot!!!", "das meinte sie\naber wahrscheinlich\nnicht.", "ich zumindest\nmag brot nicht\nsonderlich..."
    }, stage = 1, zone = {68, 39, 5, 2}},
    table = {zone = {59, 12, 5, 3}, active = false, text = "❎ um auf tisch zu legen", fish_on = false, meat_on = false},
    cat_dialog = {active = false, stage = 1, completed = false, text = {
        "nanu!?", "oh, wie wunderbar!", "endlich etwas, das schmeckt!", "ich wuenschte,\nich koennte dir\nmehr bieten,", 
        "aber als kleines\ndankeschoen nimm\ndas hier.", "es stammt noch\naus dem schloss...", "vielleicht kannst du\nja etwas damit anfangen.", 
        "du solltest mal\nan einen ort schauen,\nnicht weit von hier.", "reisende machen dort\ngerne halt.", 
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

local function check_zone(px, py, zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) < zone[1] + zone[3] and flr(py / 8) >= zone[2] and flr(py / 8) < zone[2] + zone[4]
end

function stage2_update()
    -- blubberblasen
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
    for _, item in pairs({"meat", "fish"}) do
        local zone = zones[item]
        if check_zone(px, py, zone.zone) and not zone.taken and not zone.completed then
            zone.active = true
            if btnp(5) then
                sfx (0)
                zone.taken = true
                zone.completed = true
                if item == "meat" then
                    mset(zone.zone[1] + 2, zone.zone[2], 12)
                end
            end
        else
            zone.active = false
        end
    end

    local bread_zone = zones.bread
    if check_zone(px, py, bread_zone.zone) and not bread_zone.completed then
        bread_zone.active = true
        if btnp(5) then
            bread_zone.stage = bread_zone.stage + 1
            if bread_zone.stage > #bread_zone.text then
                bread_zone.stage = 1
                bread_zone.active = false
                bread_zone.completed = true
            end
        end
    else
        bread_zone.active = false
        if not bread_zone.completed then bread_zone.stage = 1 end
    end

    local table_zone = zones.table
    if check_zone(px, py, table_zone.zone) and (zones.fish.taken or zones.meat.taken) then
        table_zone.active = true
        if btnp(5) then
            if zones.fish.taken and not table_zone.fish_on then
                table_zone.fish_on = true
                zones.fish.taken = false
                sfx (0)
                mset(60, 13, 22)
            elseif zones.meat.taken and not table_zone.meat_on then
                table_zone.meat_on = true
                zones.meat.taken = false
                sfx (0)
                mset(61, 13, 18)
            end
        end
    else
        table_zone.active = false
    end

    local cat_zone = zones.cat_dialog
    if cat_zone.active then
        if btnp(5) then
            cat_zone.stage = cat_zone.stage + 1
            if cat_zone.stage > #cat_zone.text then
                cat_zone.active = false
                cat_zone.completed = true
                cat_zone.coin_obtained = true
                sfx(1)
                mset(72, 7, 111) 
                mset(72, 8, 107) 
                mset(29, 21, 111) 
                mset(29, 22, 107)
                current_stage = 3
            end
        end
    elseif table_zone.meat_on and table_zone.fish_on and not cat_zone.completed then
        cat_zone.active = true
        cat_zone.stage = 1
    end

    update_camera()
end

function stage2_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)
    draw_roofs(player_x, player_y)

    -- draw dialogs using draw_textbox
    if zones.meat.active then
        draw_textbox(zones.meat.text, 90, 15, 118 * 8, 14 * 8)
    end
    if zones.fish.active then
        draw_textbox(zones.fish.text, 90, 15, 38 * 8, 14 * 8)
    end
    if zones.bread.active then
        draw_textbox(zones.bread.text[zones.bread.stage], 115, 30, 65 * 8, 35 * 8)
    end
    if zones.table.active then
        draw_textbox(zones.table.text, 12*8, 15, 56 * 8, 11 * 8)
    end
    if zones.cat_dialog.active then
        draw_textbox(zones.cat_dialog.text[zones.cat_dialog.stage], 115, 40, 51 * 8, 7 * 8)
    end
    
    -- items in der leiste
    for _, item in pairs({"meat", "fish"}) do
        if zones[item].taken and not zones.table[item .. "_on"] then
            draw_item_in_ui(zones[item].sprite, item == "meat" and -6 or -12)
        end
    end
    if zones.cat_dialog.coin_obtained then draw_item_in_ui(zones.cat_dialog.coin_sprite, -6) end
end








-- stage 3 specific logic

local roof_zones = { {5, 16, 9, 2}, {16, 12, 7, 2}, {27, 18, 6, 2}, {16, 18, 9, 2}, {26, 12, 10, 2}, {66, 11, 5, 3}, {73, 12, 5, 2}, {80, 12, 6, 2}, {80, 18, 6, 2}, {72, 18, 5, 2}, {64, 18, 5, 2}, {56, 18, 5, 2}}
local coin_count = 1
local stage3_coin_obtained = false 
local hide_coin_ui = false 
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

local dog_dialog_active = false -- ob der hundedialog aktiv ist
local dog_dialog_stage = 1 -- aktuelle dialogzeile
local dog_dialog_completed = false -- ob der dialog abgeschlossen ist
local dog_dialog_text = {
    "moin, moin!\nwat geiht, miezchen?",
    "kiek mol,\nwat haett' ich\ndenn huet foer dich!",
    "ein glas warme milch\n-frisch gemolken,\nkraeftig foer de\nschnurrhaare!",
    "und dat beste:\nkost' dich bloss\n4 muenz!\nein richtiger\nschnapper, wa?",
    "glas milch kaufen?\n\nja"
}
local dog_zone = {x = 122, y = 5, w = 3, h = 3} -- zone fれもr den hund

local post_dog_dialog_text = {
    "och nee,\nreicht dat etwa nich?\nna wunderbar...",
    "ick hab' hier\nnich den ganzen\ntag zeit",
    "kannste dir vielleicht\nwoanders 'ne billigere\nmilch holen,\noder komm wieder,\nwenn de wat mehr\nmuenz in der\ntasche hast",
    "ah, fein! hier is deine milch!\ndirekt aus der kanne! un pass auf,\nnik kleckern, sonst gibbet nasse pfoten!"
}
local post_dog_dialog_active = false
local post_dog_dialog_stage = 0

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
    end

    if post_dog_dialog_active then
        if btnp(5) then
            post_dog_dialog_active = false 
            if post_dog_dialog_stage == 4 then
                hide_coin_ui = true
                sfx(5)
                current_stage = 4
            end
        end
    end

    player_in_dog_zone = flr(px / 8) >= dog_zone.x and flr(px / 8) < dog_zone.x + dog_zone.w and
                         flr(py / 8) >= dog_zone.y and flr(py / 8) < dog_zone.y + dog_zone.h

    if player_in_dog_zone and not dog_dialog_active and not dog_dialog_completed then
        dog_dialog_active = true
        dog_dialog_stage = 1 -- starte den dialog von vorne
    end

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

    for _, zone in pairs(coin_zones) do
        local player_in_zone = flr(px / 8) >= zone.x and flr(px / 8) < zone.x + zone.w and
                               flr(py / 8) >= zone.y and flr(py / 8) < zone.y + zone.h

        if player_in_zone and not zone.taken then
            if btnp(5) then
                zone.taken = true
                coin_count += 1
                sfx (1)
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
    spr(sprite, px, py)
    draw_roofs(player_x, player_y)

    if stage3_coin_obtained and not hide_coin_ui then
        draw_item_in_ui(68, -6, coin_count) 
    end

    if dog_dialog_active then
        draw_textbox(dog_dialog_text[dog_dialog_stage], 95, 40, 113 * 8, 1 * 8)
    end

    if post_dog_dialog_active then
        draw_textbox(post_dog_dialog_text[post_dog_dialog_stage], 115, 30, 114 * 8, 1 * 8)
    end
end











-- stage 4
local roof_zones = { {5, 16, 9, 2}, {16, 12, 7, 2}, {27, 18, 6, 2}, {16, 18, 9, 2}, {26, 12, 10, 2}, {66, 11, 5, 3}, {73, 12, 5, 2}, {80, 12, 6, 2}, {80, 18, 6, 2}, {72, 18, 5, 2}, {64, 18, 5, 2}, {56, 18, 5, 2}}
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
        sfx(2)
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
        sprite_78_drawn = false
    end

    check_graveyard_monolog()
    check_graveyard_monolog_2()
    check_tile_interaction()
end

-- stage 4 draw
function stage4_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)
    spr(sprite, px, py)
    draw_roofs(player_x, player_y)

    if graveyard_monolog.active then
       draw_textbox(graveyard_monolog.text[graveyard_monolog.stage], 14*8, 4*8, 70 * 8, 54 * 8)
    end    

    if graveyard_monolog_2.active then
       draw_textbox(graveyard_monolog_2.text[graveyard_monolog_2.stage],14*8, 4*8, 70 * 8, 54 * 8)
    end

    if sprite_78_drawn then
        draw_item_in_ui(78, -6, nil)
    end
    
    if not grim_reaper.disappear then
        spr(97, grim_reaper.pos.x, grim_reaper.pos.y)
    end
    
    print("x " .. flower_count, 20, 5, 7)  -- zeichne den flower_count neben sprite 57
     
    if graveyard_returned then
        draw_item_in_ui(116, -6, flower_count) 
    end
end






-- stage 5
local flower_count = 24
local flower_sprites = {117, 57} -- ids der sprites mit flagge 7

-- gegner-definition und animation
local enemies = {
    {pos = {x = 70 * 8, y = 54 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
    {pos = {x = 83 * 8, y = 54 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
  --  {pos = {x = 70 * 8, y = 60 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
   -- {pos = {x = 83 * 8, y = 60 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},

}

local grim_reaper = {
    pos = {x = 69 * 8, y = 59 * 8}, -- startposition
    target = {x = 76 * 8, y = 59 * 8}, -- zielposition
    moving = false, -- gibt an, ob er sich bewegt
    speed = 1, -- geschwindigkeit
    disappear = true, -- gibt an, ob er verschwinden soll
    phase = 1 -- phase der bewegung
}

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
        trigger_zone = {74, 79, 58, 61}
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

function player_in_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) < zone[2] and
           flr(py / 8) >= zone[3] and flr(py / 8) < zone[4]
end

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

function reset_stage5()
    px, py = 77 * 8, 61 * 8
    flower_count = 24
    reset_flowers()

    print("stage 5 reset", 73 * 8, 55 * 8, 7) -- print text at coordinates 73, 55
end

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

function check_enemy_collision()
    for _, enemy in pairs(enemies) do
        if px < enemy.pos.x + 8 and px + 8 > enemy.pos.x and py < enemy.pos.y + 8 and py + 8 > enemy.pos.y then
            sfx (3)
            reset_stage5()
            break
        end
    end
end

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
                sfx(7)
                flower_count = flower_count - 1
            end
        end
    end
end

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

function move_grim_reaper()
    if grim_reaper.moving then
        if grim_reaper.pos.x < grim_reaper.target.x then
            grim_reaper.pos.x += grim_reaper.speed
        else
            grim_reaper.moving = false -- bewegung stoppen
        end
    end
end


-- check if grim reaper reached destination
function grim_reaper_reached_destination()
    return grim_reaper.pos.x >= grim_reaper.target.x and not grim_reaper.moving
end

function stage5_update()

    for _, enemy in pairs(enemies) do
        update_enemy_movement(enemy)
    end

    check_enemy_collision()
    place_flower_under_tile()

    if flower_count == 0 then
        handle_enemies_disappearance()
    end

    if enemies_disappearing and all_enemies_gone() then
        enemies_disappearing = false
        grim_reaper.moving = true
        grim_reaper.disappear = false -- grim reaper ist sichtbar
    end

    if grim_reaper.moving then
        move_grim_reaper()
    end

    if grim_reaper_reached_destination() and player_in_zone(dialog_system.grimreaper.trigger_zone) and not dialog_system.grimreaper.completed then
        start_dialog(dialog_system.grimreaper)
    end

    update_dialog(dialog_system.grimreaper)
end

function stage5_draw()
  
    draw_item_in_ui(57, -6, flower_count)
    print("x " .. flower_count, 20, 5, 7)

    for _, enemy in pairs(enemies) do
        spr(enemy.sprite, enemy.pos.x, enemy.pos.y)
    end

    if not grim_reaper.disappear then
        spr(96, grim_reaper.pos.x, grim_reaper.pos.y)
    end

    if dialog_system.grimreaper.active then
    draw_textbox(dialog_system.grimreaper.text[dialog_system.grimreaper.stage], 14*8, 5*8, 70 * 8, 54 * 8)
    end
end










-- stage 6

-- stage 5
local flower_count = 24
local flower_sprites = {117, 57} -- ids der sprites mit flagge 7

-- gegner-definition und animation
local enemies = {
    {pos = {x = 70 * 8, y = 54 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
    {pos = {x = 83 * 8, y = 54 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
  --  {pos = {x = 70 * 8, y = 60 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},
   -- {pos = {x = 83 * 8, y = 60 * 8}, sprite = 80, animation_stage = 1, anim_timer = 0, dx = 0, dy = 0},

}

local grim_reaper = {
    pos = {x = 69 * 8, y = 59 * 8}, -- startposition
    target = {x = 76 * 8, y = 59 * 8}, -- zielposition
    moving = false, -- gibt an, ob er sich bewegt
    speed = 1, -- geschwindigkeit
    disappear = true, -- gibt an, ob er verschwinden soll
    phase = 1 -- phase der bewegung
}

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
        trigger_zone = {74, 79, 58, 61}
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

function player_in_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) < zone[2] and
           flr(py / 8) >= zone[3] and flr(py / 8) < zone[4]
end

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

function reset_stage5()
    px, py = 77 * 8, 61 * 8
    flower_count = 24
    reset_flowers()

    print("stage 5 reset", 73 * 8, 55 * 8, 7) -- print text at coordinates 73, 55
end

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

function check_enemy_collision()
    for _, enemy in pairs(enemies) do
        if px < enemy.pos.x + 8 and px + 8 > enemy.pos.x and py < enemy.pos.y + 8 and py + 8 > enemy.pos.y then
            sfx (3)
            reset_stage5()
            break
        end
    end
end

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
                sfx(7)
                flower_count = flower_count - 1
            end
        end
    end
end

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

function move_grim_reaper()
    if grim_reaper.moving then
        if grim_reaper.pos.x < grim_reaper.target.x then
            grim_reaper.pos.x += grim_reaper.speed
        else
            grim_reaper.moving = false -- bewegung stoppen
        end
    end
end


-- check if grim reaper reached destination
function grim_reaper_reached_destination()
    return grim_reaper.pos.x >= grim_reaper.target.x and not grim_reaper.moving
end

function stage5_update()

    for _, enemy in pairs(enemies) do
        update_enemy_movement(enemy)
    end

    check_enemy_collision()
    place_flower_under_tile()

    if flower_count == 0 then
        handle_enemies_disappearance()
    end

    if enemies_disappearing and all_enemies_gone() then
        enemies_disappearing = false
        grim_reaper.moving = true
        grim_reaper.disappear = false -- grim reaper ist sichtbar
    end

    if grim_reaper.moving then
        move_grim_reaper()
    end

    if grim_reaper_reached_destination() and player_in_zone(dialog_system.grimreaper.trigger_zone) and not dialog_system.grimreaper.completed then
        start_dialog(dialog_system.grimreaper)
    end

    update_dialog(dialog_system.grimreaper)
end

function stage5_draw()
  
    draw_item_in_ui(57, -6, flower_count)
    print("x " .. flower_count, 20, 5, 7)

    for _, enemy in pairs(enemies) do
        spr(enemy.sprite, enemy.pos.x, enemy.pos.y)
    end

    if not grim_reaper.disappear then
        spr(96, grim_reaper.pos.x, grim_reaper.pos.y)
    end

    if dialog_system.grimreaper.active then
    draw_textbox(dialog_system.grimreaper.text[dialog_system.grimreaper.stage], 14*8, 5*8, 70 * 8, 54 * 8)
    end
end





-- stage 6

local roof_zones = { {5, 16, 9, 2}, {16, 12, 7, 2}, {27, 18, 6, 2}, {16, 18, 9, 2}, {26, 12, 10, 2}, {66, 11, 5, 3}, {73, 12, 5, 2}, {80, 12, 6, 2}, {80, 18, 6, 2}, {72, 18, 5, 2}, {64, 18, 5, 2}, {56, 18, 5, 2}}
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

local graveyard_zone = {x = 75, y = 58, w = 4, h = 4}

-- dialogsystem
local dialog_system = {
    
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
            current_area = 10
            update_camera()
        else
            well_system.animation = false
            sfx (6)
            current_stage = 7
        end
    end
end

function draw_well_dialog(player_x, player_y)
    if well_system.active then
        draw_textbox(well_system.text, 11*8, 5*8, 53 * 8, 3 * 8)

        local ja_color = well_system.choice == 1 and 7 or 6
        local nein_color = well_system.choice == 2 and 7 or 6

        print("ja", 55*8 , 7*8, ja_color)
        print("nein", 60*8, 7*8, nein_color)
    end
end


function stage6_update()
    
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

    if player_in_zone(dialog_system.bible.trigger_zone) then
        start_dialog(dialog_system.bible)
    elseif player_in_zone(dialog_system.diary.trigger_zone) then
        start_dialog(dialog_system.diary)
    end
    
    update_dialog(dialog_system.bible)
    update_dialog(dialog_system.diary)
    update_well_dialog()
    update_camera()
end


function stage6_draw()
    if not well_system.animation or well_system.anim_timer < 30 then
        cls()
        map(0, 0, 0, 0, 128, 64)
        spr(sprite, px, py)
        draw_roofs(player_x, player_y)

        spr(96, 76 * 8, 59 * 8)

        if dialog_system.bible.active then
            draw_textbox(dialog_system.bible.text[dialog_system.bible.stage], 14*8, 4*8, 92 * 8, 57 * 8)
        end
     
        if dialog_system.diary.active then
            draw_textbox(dialog_system.diary.text[dialog_system.diary.stage], 14*8, 4*8, 96 * 8, 6 * 8)
        end
     
        draw_well_dialog(px, py)
    elseif well_system.anim_timer >= 30 and well_system.anim_timer < 60 then
        cls(0) -- blackout screen
    end
end









-- stage 7
local teleport_zones = {
        {from = {22, 39}, to = {35, 42}, area_id = 11}, 
        {from = {35, 44}, to = {22, 41}, area_id = 10}, 
        {from = {61, 42}, to = {46, 59}, area_id = 12},  
        {from = {44, 59}, to = {59, 42}, area_id = 11}, 

}
local door_zone_1 = {x = 21, y = 39, w = 3, h = 3}
local door_zone_2 = {x = 124, y = 43, w = 3, h = 3}
local door_zone_3 = {x = 42, y = 40, w = 3, h = 3}
local door_zone_4 = {x = 49, y = 40, w = 3, h = 3}
local door_zone_5 = {x = 56, y = 40, w = 3, h = 3}

local key_item = {
    x = 36, -- tile-x-koordinate
    y = 58, -- tile-y-koordinate
    sprite_id = 104, -- sprite-id fれもr den schlれもssel
    trigger_zone = {35, 38, 57, 60}, -- trigger-zone fれもr einsammeln
    collected = false -- status: wurde der schlれもssel eingesammelt?
}
local key_count = 0 -- anzahl der schlれもssel (fれもr die ui)

local rat_sprite_id = 114 -- die ratte wird mit sprite-id 114 gezeichnet
local rat_x, rat_y = 115, 33 -- position der ratte
local rat_dialog_trigger_zone = {113, 33, 5, 3} -- die zone vor der ratte
local rat_dialog_text = "was in aller welt!? \nwie bist du\nhier reingekommen?!"
local rat_dialog_shown = false -- status, ob der dialog schon gezeigt wurde

function player_in_rat_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) <= zone[1] + zone[3] and
           flr(py / 8) >= zone[2] and flr(py / 8) <= zone[2] + zone[4]
end

function player_in_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) <= zone[2] and
           flr(py / 8) >= zone[3] and flr(py / 8) <= zone[4]
end

function player_in_door_zone(door_zone)
    return flr(px / 8) >= door_zone.x and flr(px / 8) < door_zone.x + door_zone.w and
           flr(py / 8) >= door_zone.y and flr(py / 8) < door_zone.y + door_zone.h
end

function stage7_update()

    if not key_item.collected and player_in_zone(key_item.trigger_zone) then
        if btnp(5) then
            key_item.collected = true
            sfx (5)
            key_count = key_count + 1
        end
    end

    local door_zones = {door_zone_1, door_zone_2, door_zone_3, door_zone_4, door_zone_5}

    for _, door_zone in pairs(door_zones) do
    if key_item.collected and player_in_door_zone(door_zone) then
        if btnp(5) then
            sfx (8)
            mset(door_zone.x + 1, door_zone.y, 111)
            mset(door_zone.x + 1, door_zone.y + 1, 107)
        end
    end
   
    for _, zone in pairs(teleport_zones) do
        if flr(px / 8) == zone.from[1] and flr(py / 8) == zone.from[2] then
            px = zone.to[1] * 8
            py = zone.to[2] * 8
            current_area = zone.area_id  -- setze die aktuelle area id basierend auf dem teleportationsziel
            update_camera()  -- kamera aktualisieren
        end
    end

    -- treppe teleportation
    
    if flr(px / 8) >= 56 and flr(px / 8) < 58 and flr(py / 8) >= 50 and flr(py / 8) < 51 then
    px, py = 126 * 8, 47 * 8
    current_area = 13
    update_camera()
    elseif flr(px / 8) >= 125 and flr(px / 8) < 127 and flr(py / 8) >= 48 and flr(py / 8) < 49 then
    px, py = 57 * 8, 52 * 8
    current_area = 12
    update_camera()
    end

    if player_in_rat_zone(rat_dialog_trigger_zone) and not rat_dialog_shown then
            rat_dialog_shown = true            
    end        
    
    if rat_dialog_shown and btnp(5) then
        rat_dialog_shown = false  -- setze den dialogstatus zurれもck
        current_stage = 8  -- setze die finale stage auf 8
    end
  end
end

function stage7_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)

    spr(rat_sprite_id, rat_x * 8, rat_y * 8)

    if not key_item.collected then
        spr(key_item.sprite_id, key_item.x * 8, key_item.y * 8)
    end

    if key_count > 0 then
        draw_item_in_ui(104, -7)
    end

    if rat_dialog_shown then
        draw_textbox(rat_dialog_text,11*8,3*8,111*8,29*8) 
    end
    spr(sprite, px, py)


end










-- stage 7


local teleport_zones = {
        {from = {22, 39}, to = {35, 42}, area_id = 11}, 
        {from = {35, 44}, to = {22, 41}, area_id = 10}, 
        {from = {61, 42}, to = {46, 59}, area_id = 12},  
        {from = {44, 59}, to = {59, 42}, area_id = 11}, 

}
local door_zone_1 = {x = 21, y = 39, w = 3, h = 3}
local door_zone_2 = {x = 124, y = 43, w = 3, h = 3}
local door_zone_3 = {x = 42, y = 40, w = 3, h = 3}
local door_zone_4 = {x = 49, y = 40, w = 3, h = 3}
local door_zone_5 = {x = 56, y = 40, w = 3, h = 3}

local key_item = {
    x = 36, -- tile-x-koordinate
    y = 58, -- tile-y-koordinate
    sprite_id = 104, -- sprite-id fれもr den schlれもssel
    trigger_zone = {35, 38, 57, 60}, -- trigger-zone fれもr einsammeln
    collected = false -- status: wurde der schlれもssel eingesammelt?
}
local key_count = 0 -- anzahl der schlれもssel (fれもr die ui)

local rat_sprite_id = 114 -- die ratte wird mit sprite-id 114 gezeichnet
local rat_x, rat_y = 115, 33 -- position der ratte
local rat_dialog_trigger_zone = {113, 33, 5, 3} -- die zone vor der ratte
local rat_dialog_text = "was in aller welt!? \nwie bist du\nhier reingekommen?!"
local rat_dialog_shown = false -- status, ob der dialog schon gezeigt wurde

function player_in_rat_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) <= zone[1] + zone[3] and
           flr(py / 8) >= zone[2] and flr(py / 8) <= zone[2] + zone[4]
end

function player_in_zone(zone)
    return flr(px / 8) >= zone[1] and flr(px / 8) <= zone[2] and
           flr(py / 8) >= zone[3] and flr(py / 8) <= zone[4]
end

function player_in_door_zone(door_zone)
    return flr(px / 8) >= door_zone.x and flr(px / 8) < door_zone.x + door_zone.w and
           flr(py / 8) >= door_zone.y and flr(py / 8) < door_zone.y + door_zone.h
end

function stage7_update()

    if not key_item.collected and player_in_zone(key_item.trigger_zone) then
        if btnp(5) then
            key_item.collected = true
            sfx (5)
            key_count = key_count + 1
        end
    end

    local door_zones = {door_zone_1, door_zone_2, door_zone_3, door_zone_4, door_zone_5}

    for _, door_zone in pairs(door_zones) do
    if key_item.collected and player_in_door_zone(door_zone) then
        if btnp(5) then
            sfx (8)
            mset(door_zone.x + 1, door_zone.y, 111)
            mset(door_zone.x + 1, door_zone.y + 1, 107)
        end
    end
   
    for _, zone in pairs(teleport_zones) do
        if flr(px / 8) == zone.from[1] and flr(py / 8) == zone.from[2] then
            px = zone.to[1] * 8
            py = zone.to[2] * 8
            current_area = zone.area_id  -- setze die aktuelle area id basierend auf dem teleportationsziel
            update_camera()  -- kamera aktualisieren
        end
    end

    -- treppe teleportation
    
    if flr(px / 8) >= 56 and flr(px / 8) < 58 and flr(py / 8) >= 50 and flr(py / 8) < 51 then
    px, py = 126 * 8, 47 * 8
    current_area = 13
    update_camera()
    elseif flr(px / 8) >= 125 and flr(px / 8) < 127 and flr(py / 8) >= 48 and flr(py / 8) < 49 then
    px, py = 57 * 8, 52 * 8
    current_area = 12
    update_camera()
    end

    if player_in_rat_zone(rat_dialog_trigger_zone) and not rat_dialog_shown then
            rat_dialog_shown = true            
    end        
    
    if rat_dialog_shown and btnp(5) then
        rat_dialog_shown = false  -- setze den dialogstatus zurれもck
        current_stage = 8  -- setze die finale stage auf 8
    end
  end
end

function stage7_draw()
    cls()
    map(0, 0, 0, 0, 128, 64)

    spr(rat_sprite_id, rat_x * 8, rat_y * 8)

    if not key_item.collected then
        spr(key_item.sprite_id, key_item.x * 8, key_item.y * 8)
    end

    if key_count > 0 then
        draw_item_in_ui(104, -7)
    end

    if rat_dialog_shown then
        draw_textbox(rat_dialog_text,11*8,3*8,111*8,29*8) 
    end
    spr(sprite, px, py)


end








local roof_zones = {{105, 37, 7, 1}, {105, 39, 7, 1}, {118, 37, 7, 1}, {118, 39, 7, 1} }


rat = {
    pos = {x = 115 * 8, y = 33 * 8},
    sprite = 114,
    direction = "left",
    anim_timer = 0,
    anim_stage = 1,
    speed = 0.75,  -- initial speed set to 0.75
    dx = 0,
    dy = 0,
    move_area = {x1 = 109 * 8, y1 = 32 * 8, x2 = 121 * 8, y2 = 40 * 8},
    collision_timer = 0, 
    collision_count = 0, 
    last_collision_time = 0,  
    blackout_timer = 0,
    in_blackout = false 
}

function sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function distance(x1, y1, x2, y2)
    return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function update_rat_movement()
    if rat.in_blackout then
        return
    end

    local player_distance = distance(px, py, rat.pos.x, rat.pos.y)

    if player_distance < 32 then -- if player is too close, rat runs away
        rat.dx = sign(rat.pos.x - px)
        rat.dy = sign(rat.pos.y - py)
    elseif player_distance > 64 then -- if far enough away, rat stops
        rat.dx = 0
        rat.dy = 0
    else -- randomly move within the move_area
        if rnd() > 0.9 then
            rat.dx = flr(rnd(3)) - 1 -- random x-direction (-1, 0, 1)
            rat.dy = flr(rnd(3)) - 1 -- random y-direction (-1, 0, 1)
        end
    end

    local new_x = rat.pos.x + rat.dx * rat.speed
    local new_y = rat.pos.y + rat.dy * rat.speed

    -- ensure the rat stays within its designated area
    new_x = mid(rat.move_area.x1, new_x, rat.move_area.x2)
    new_y = mid(rat.move_area.y1, new_y, rat.move_area.y2)

    rat.pos.x = new_x
    rat.pos.y = new_y

    -- update animation
    if rat.dx > 0 then
        rat.direction = "right"
        rat.sprite = rat.anim_stage == 1 and 112 or 113
    elseif rat.dx < 0 then
        rat.direction = "left"
        rat.sprite = rat.anim_stage == 1 and 114 or 115
    elseif rat.dy ~= 0 then
        rat.sprite = rat.direction == "right" and (rat.anim_stage == 1 and 112 or 113) or (rat.anim_stage == 1 and 114 or 115)
    end

    rat.anim_timer += 1
    if rat.anim_timer % 10 == 0 then
        rat.anim_stage = 3 - rat.anim_stage  -- toggle between 1 and 2
    end
end

function check_rat_collision()
    local current_time = time()
    if current_time - rat.last_collision_time > 1 and px < rat.pos.x + 8 and px + 8 > rat.pos.x and py < rat.pos.y + 8 and py + 8 > rat.pos.y then
        rat.collision_timer = 30
        sfx (3)
        rat.collision_count += 1
        rat.speed += 0.125  -- increase speed by 0.125 after each collision
        rat.last_collision_time = current_time  -- update last collision time
        if rat.collision_count >= 4 then
            rat.in_blackout = true
            rat.blackout_timer = 2 * 30  -- 2 seconds worth of frames assuming 30 fps
        end
        rat.sprite = 81
    end
end

function stage8_update()
    if rat.in_blackout then
        rat.blackout_timer -= 1
        if rat.blackout_timer <= 0 then
            px, py = 115 * 8, 37 * 8
            current_stage = 9
        end
        return
    end

    update_rat_movement()
    check_rat_collision()

    -- reduce collision timer
    if rat.collision_timer > 0 then
        rat.collision_timer -= 1
        if rat.collision_timer == 0 then
            -- resume normal animation
            if rat.direction == "right" then
                rat.sprite = rat.anim_stage == 1 and 112 or 113
            else
                rat.sprite = rat.anim_stage == 1 and 114 or 115
            end
        end
    end
end

function stage8_draw()
    if rat.in_blackout then
        cls(0)  
        return
    end

    cls()
    map(0, 0, 0, 0, 128, 64)
    spr(rat.sprite, rat.pos.x, rat.pos.y)
    if rat.in_blackout then
        return 
    end
    spr(sprite, px, py)
end







local roof_zones = {{105, 37, 7, 1}, {105, 39, 7, 1}, {118, 37, 7, 1}, {118, 39, 7, 1} }


final_dialog_active = true -- ob der hundedialog aktiv ist
final_dialog_stage = 1 -- aktuelle dialogzeile
final_dialog_completed = false -- ob der dialog abgeschlossen ist
final_dialog_text = {
    "ratte:\n\nbitte, toete mich nicht...\nich wollte das alles nicht!\n\ndie menschen nannten uns\nungeziefer. sie jagten uns\nwie schatten.\n\nhunger, verstecken, ueberleben\ndas war alles, was wir kannten.\n\njetzt bin ich hier,\nals letzte meiner art.\n\nwillst du mich auch\nnoch ausloeschen?",
    "katze:\n\nihr seid der grund,\nwarum die menschen flohen.\n\nwarum sie sterben mussten!",
    "ratte:\n\nsie starben nicht unsertwegen!\ndie pest hat sie geholt,\nihr eigener schmutz, ihre gier!\n\nich war die einzig infizierte,\naber sie jagten uns alle,\nbis niemand mehr uebrig war.\n\nwenn du mich verschonst,\ngehoert die stadt uns tieren.\n\nich halte die menschen fern,\nund wir alle haben genug\nzu fressen!",
    "katze:\n\nund was ist mit den unschuldigen,\ndie wegen euch starben?\n\nmit den tieren,\ndie ihre besitzer verloren?",
    "ratte:\n\ndu weisst, wie es ist,\nhungrig zu sein...\n\ndie menschen sahen uns nie\nals lebewesen.\n\nnun sind fort...\n\nkoennen wir nicht\nohne sie leben?",
    "katze:\n\nvielleicht...\n\naber sie werden zurueckkehren.\n\nmit waffen, feuer und tod.\n\nwillst du, dass noch\nmehr von uns leiden?",
    "ratte:\n\nich will ein besseres\nleben fuer uns.\n\naber fein. sieh mich an...\n\nich kann kaum noch\nstehen nach deinem\nblutrausch eben.\n\nich verstehe nun, dass ich\nhier nicht willkommen bin\n\nmach es schnell.\n\naber sobald du mich toetest...\nwird der teufelskreis\nvon vorne beginnen.",
    "was wirst du tun?"
}

choices = {
    text_2 = "katze:\n\nes tut mir leid,\ndass ich dich so\nvoreilig angriff.\n\nich habe mich entschieden.\n\ntrink diese heilung,\nwir haben eine stadt\nzu versorgen.",
    text_1 = "katze:\n\nes tut mir leid,\naber das kann ich\neinfach nicht unterstuetzen...\n\n\nratte:\n\nwarte!!\n\nnein geh nicht!\n\ndu kannst mich hier\ndoch nicht einfach\nzuruecklassen...",
    zone_1 = {x = 111, y = 35, w = 4, h = 3},
    zone_2 = {x = 116, y = 35, w = 4, h = 3},
    active_text = nil, -- current text to display
    active = false,    -- whether a zone text is active
    blackscreen = false, -- show blackscreen before text
    blackscreen_timer = 0, -- duration of blackscreen
}

blackout_after_choice = false -- ob der bildschirm nach der wahl schwarz wird
blackout_timer = 0 -- countdown fれもr den blackout


-- handle blackscreen timer and teleportation
if choices.blackscreen then
    choices.blackscreen_timer -= 1
    if choices.blackscreen_timer <= 0 then
        choices.blackscreen = false
        choices.active = true
        px, py = 115 * 8, 37 * 8 -- teleport player
        map_cleared = true -- karte lれへschen
    end
end

-- function to check if player is in a zone
function is_in_zone(zone)
    return px / 8 >= zone.x and px / 8 < zone.x + zone.w and
           py / 8 >= zone.y and py / 8 < zone.y + zone.h
end

-- update function
function stage9_update()
    

    
    -- handle zone-interaktionen
    if not choices.active and not choices.blackscreen then
        if is_in_zone(choices.zone_1) and btnp(5) then
            sfx (0)
            choices.active_text = choices.text_1
            choices.blackscreen = true
            choices.blackscreen_timer = 30 -- 30 frames fれもr blackscreen
        elseif is_in_zone(choices.zone_2) and btnp(5) then
            choices.active_text = choices.text_2
            choices.blackscreen = true
            choices.blackscreen_timer = 30
        end
    end

    -- handle blackscreen-timer wれさhrend einer wahl
    if choices.blackscreen then
        choices.blackscreen_timer -= 1
        if choices.blackscreen_timer <= 0 then
            choices.blackscreen = false
            choices.active = true
            px, py = 115 * 8, 37 * 8 -- spieler zurれもcksetzen
        end
    elseif choices.active and btnp(5) then
        choices.active = false
        choices.active_text = nil

        -- starte blackout nach abschluss des texts
        blackout_after_choice = true
        blackout_timer = 5 * 30 -- 5 sekunden (30 fps)
    end

    if blackout_after_choice then
        blackout_timer -= 1
        if blackout_timer <= 0 then
            blackout_after_choice = false
            px, py = 31*8, 31*8
            current_stage = 1 
        end
    end
    
    if final_dialog_active then
        if btnp(5) then 
            final_dialog_stage += 1
            if final_dialog_stage > #final_dialog_text then
                final_dialog_active = false
                final_dialog_completed = true
            end
        end
    end
end


function stage9_draw()

    if blackout_after_choice then
        cls(0) -- schwarzer bildschirm
        return
    end

    if choices.blackscreen then
        cls(0) -- schwarzer bildschirm
        return
    end

    cls()
    map(0, 0, 0, 0, 128, 64)

    spr(114, 115 * 8, 33 * 8)

    spr(104, 112 * 8, 36 * 8)
    spr(78, 118 * 8, 36 * 8)

    -- finalen dialog anzeigen
    if final_dialog_active then
        draw_textbox(final_dialog_text[final_dialog_stage], 17 * 8, 17 * 8, 107 * 8, 29 * 8)
    elseif choices.active and choices.active_text then
        draw_textbox(choices.active_text, 17 * 8, 17 * 8, 107 * 8, 29 * 8)
    end

    if blackout_after_choice or final_dialog_active or choices.active or choices.blackscreen then
        return 
    end
    spr(sprite, px, py)
end

