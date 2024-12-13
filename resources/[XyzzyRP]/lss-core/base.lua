--[[ 
    @author Lukasz Biegaj <wielebny@bestplay.pl>
    @author Karer <karer.programmer@gmail.com>
    @author WUBE <wube@lss-rp.pl>
    @copyright 2011-2013 Lukasz Biegaj <wielebny@bestplay.pl>
    @license Dual GPLv2/MIT
]]

-- W związku z aktywnością cheaterów na platformie MTA, postanowiłem dodać do tego repozytorium podstawowe zabezpieczenia.

local TRIGGER_MAX = 30 -- optymalna ilość

function antyspamTrigger()
	kickPlayer(source,"Zbyt duża ilość przesyłanych pakietów.")
end
addEventHandler("onPlayerTriggerEventThreshold", root, antyspamTrigger)

addEventHandler("onElementDataChange", root, function(dataName, oldValue, newValue)
    if dataName == "id" then
        if oldValue and newValue and oldValue ~= newValue then
            kickPlayer(player, "Połącz się ponownie.")
        end
    end
    if dataName == "character" then
        if oldValue and newValue and oldValue ~= newValue then
            kickPlayer(player, "Połącz się ponownie.")
        end
    end
    if dataName == "auth:uid" then
         if oldValue and newValue and oldValue ~= newValue then
              kickPlayer(player, "Połącz się ponownie.")
         end
     end
end)

function spawn(plr)
    local character = getElementData(plr, "character")
    if (not character or not character.skin) then
        kickPlayer(plr, "Nie udalo sie odnalezc Twojej postaci.")
        return
    end

    local nnick = string.gsub(character.imie .. "_" .. character.nazwisko, " ", "_")
    setPlayerName(plr, nnick)

    if (tonumber(character.newplayer) > 0) then
        local query = string.format("UPDATE lss_characters SET newplayer=0 WHERE id=%d LIMIT 1", character.id)
        exports.DB:zapytanie(query)
        character.newplayer = 0
        setElementData(plr, "character", character)

        outputChatBox("(( Witaj nowy mieszkańcu Los Santos. Wciśnij klawisz F1 aby zobaczyć krótki przewodnik po serwerze. ))", plr)
        outputChatBox("(( Prawie wszystkie interakcje wykonuje się za pomocą myszki. Aby aktywować kursor, wciśnij TAB. ))", plr)
        outputChatBox("(( Jako nowy mieszkaniec, powinieneś udać się do urzędu aby wyrobić dokumenty i poszukać pracy. ))", plr)
    end

    triggerEvent("onPlayerRequestEQSync", plr)

    local blokada_aj = getElementData(plr, "kary:blokada_aj")
    if (blokada_aj and tonumber(blokada_aj) > 0) then
        outputChatBox("Posiadasz nałożony AJ, ilość minut: " .. blokada_aj, plr, 255, 0, 0, true)
        repeat until spawnPlayer(plr, 215.53, 109.52, 999.02, 0.1, tonumber(character.skin), 10, 2000 + tonumber(character.id))
    else
        repeat until spawnPlayer(plr, character.lastpos[1], character.lastpos[2], character.lastpos[3], character.lastpos[4], character.co_skin and tonumber(character.co_skin) or tonumber(character.skin), character.lastpos[5], character.lastpos[6])
    end

    setPedArmor(plr, tonumber(character.ar))
    local hp = tonumber(character.hp)
    if hp < 1 then hp = 1 end
    setElementHealth(plr, hp)

    setPlayerMoney(plr, tonumber(character.money))

    setPedStat(plr, 22, tonumber(character.stamina))
    setPedStat(plr, 225, tonumber(character.stamina))
    setPedStat(plr, 23, tonumber(character.energy))
    setPedStat(plr, 164, tonumber(character.energy))
    setPedStat(plr, 165, tonumber(character.energy))

    fadeCamera(plr, true)
    setCameraTarget(plr, plr)
    showChat(plr, true)
    showPlayerHudComponent(plr, "all", true)

    if (eq_getItem(plr, 16) or eq_getItem(plr, 4)) then
        showPlayerHudComponent(plr, "radar", true)
    else
        showPlayerHudComponent(plr, "radar", false)
    end

    showPlayerHudComponent(plr, "radio", false)
    showPlayerHudComponent(plr, "weapon", false)
    showPlayerHudComponent(plr, "vehicle_name", false)

    toggleAllControls(plr, true)
    toggleControl(plr, "next_weapon", false)
    toggleControl(plr, "previous_weapon", false)
    toggleControl(plr, "radar", false)
    toggleControl(plr, "action", false)

    if (tonumber(character.stamina) < 250) then
        toggleControl(plr, "sprint", false)
    else
        toggleControl(plr, "sprint", true)
    end

    local blokada_bicia = getElementData(plr, "kary:blokada_bicia")
    if (blokada_bicia) then
        outputChatBox("Posiadasz blokadę bicia i atakowania, aktywną do #FFFFFF" .. blokada_bicia, plr, 255, 0, 0, true)
        toggleControl(plr, "fire", false)
        toggleControl(plr, "aim_weapon", false)
    end

    setTimer(usunBronieGracza, 5000, 1, plr)
end

addEvent("introCompleted", true)
addEventHandler("introCompleted", root, function()
    triggerClientEvent(source, "onGUIOptionChange", getRootElement(), "cinematic", false)
    spawn(source)
end)

addEventHandler("onPlayerConnect", root, function(playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber)
    if (string.find(playerNick, "#") ~= nil) then
        cancelEvent(true, "Twoj nick zawiera niedozwolony znak (#). Na tym serwerze nie mozna miec nickow z kolorami. Zmien go w ustawieniach i polacz sie znowu.")
    end
end)

addEventHandler("onResourceStart", resourceRoot, function()
    setJetpackMaxHeight(101.82230377197)
    setWaveHeight(0)
    setFPSLimit(75)
    setMapName("XyzzyRP")
    setGameType("XyzzyRP")
    setRuleValue("Gamemode", "XyzzyRP")
    setRuleValue("WWW", "http://github.com/lpiob/MTA-XyzzyRP")
    setServerConfigSetting("max_player_triggered_events_per_interval", TRIGGER_MAX)

    local realtime = getRealTime()
    setTime(realtime.hour, realtime.minute)
    setMinuteDuration(60000)  -- 60000 milliseconds (1 minute)
    setTimer(every1min, 60000, 0)
end)

function every1min()
    setJetpackMaxHeight(101.82230377197)
    local time = getRealTime()
    setTime(time.hour, time.minute)

    if (time.minute == 0) then
        triggerClientEvent("onPelnaGodzina", getRootElement())
    end
end

addEventHandler("onPlayerChangeNick", getRootElement(), function() cancelEvent() end)
