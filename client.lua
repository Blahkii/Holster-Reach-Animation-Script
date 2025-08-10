local isReaching = false

local function loadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local t0 = GetGameTimer()
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() - t0 > 5000 then
                break
            end
            Wait(10)
        end
    end
end

local function playAnim(ped, anim)
    loadAnimDict(anim.dict)
    if not HasAnimDictLoaded(anim.dict) then
        if Config.Debug then print(("[reach_anim] failed to load dict: %s"):format(anim.dict)) end
        return false
    end

    TaskPlayAnim(ped, anim.dict, anim.name, 8.0, -8.0, anim.duration or -1, anim.flag or 49, 0.0, false, false, false)
    Wait(200)

    local playing = IsEntityPlayingAnim(ped, anim.dict, anim.name, 3)
    if Config.Debug then
        print(("[reach_anim] tried %s/%s -> playing=%s"):format(anim.dict, anim.name, tostring(playing)))
    end
    return playing
end

local function startReach()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) or IsPedRagdoll(ped) then
        if Config.Debug then print("[reach_anim] cannot play - vehicle/dead/ragdoll") end
        return
    end

    if playAnim(ped, Config.PrimaryAnim) then
        isReaching = true
        return
    end

    if playAnim(ped, Config.FallbackAnim) then
        isReaching = true
        return
    end

    if Config.Debug then print("[reach_anim] no animation played (both primary+fallback failed)") end
end

local function stopReach()
    ClearPedTasks(PlayerPedId())
    isReaching = false
    if Config.Debug then print("[reach_anim] stopped/cleared") end
end

-- Command for toggling
RegisterCommand("reach_toggle", function()
    if not isReaching then
        startReach()
    else
        stopReach()
    end
end, false)

-- Per-player key mapping (default E)
RegisterKeyMapping("reach_toggle", "Toggle holster reach stance", "keyboard", "E")
