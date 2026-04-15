SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

local totalElapsedTime = SIM.currentSessionTime
local trackProgress = CAR.splinePosition

local lastReadTime = 0
local lastReadPoints = 0
local currentReadPoints = 0 --declare rate of change variables for good measure
local pointsRateOfChange = 0

local isWarning = false
local timeWarningStarted = 0 --Warning Variables

local targetRateOfChange = 50
local sampleTime = 0.5
local displayWarningFor = 5 --Config Defaults.

local slowCarCooldown = 1000
local lastSlowCarBroadcastAttempt = 0
local lastSlowCarRecieve = 0
local slowCarDistance = 0.1

local settingsOverride = false
local windowWidth, windowHeight = ac.getSim().windowWidth, ac.getSim().windowHeight
local uiScale = ac.getUI().uiScale
local testGameState = false

local betterFlagSettings = ac.storage({
    flagWindowX = 0, flagWindowY = 0, flagWindowScale = 1
})

local tempSettings = {
    flagWindowX = betterFlagSettings.flagWindowX,
    flagWindowY = betterFlagSettings.flagWindowY,
    flagWindowScale = betterFlagSettings.flagWindowScale
}

local noOvertake1_S, noOvertake1_E
local noOvertake2_S, noOvertake2_E
local noOvertake3_S, noOvertake3_E
local meatballThreshold
local slowCarFlagPersist

local flagsWindow
local currentFlags

local totalElapsedTime
local trackProgress

BetterFlags = BetterFlags or {}

-- Inicialização das variáveis em BetterFlags
BetterFlags.totalElapsedTime = 0
BetterFlags.trackProgress = 0
BetterFlags.noOvertake1_S = 0
BetterFlags.noOvertake1_E = 0
BetterFlags.noOvertake2_S = 0
BetterFlags.noOvertake2_E = 0
BetterFlags.noOvertake3_S = 0
BetterFlags.noOvertake3_E = 0
BetterFlags.meatballThreshold = 0
BetterFlags.slowCarFlagPersist = 0
BetterFlags.slowCarDistance = 0.1
BetterFlags.lastSlowCarBroadcastAttempt = 0
BetterFlags.lastSlowCarRecieve = 0
BetterFlags.slowCarCooldown = 1000

-- VARIAVEIS PARA DEBUG
local parsedConfig

-- chamadas de funções #################################################
BetterFlags.start()


-- funções ##############################################################

function BetterFlags.start()
    ac.blockSystemMessages("$CSP0:")
    BetterFlags.mensagemDeBoasVindas()
    BetterFlags.makeFlags()
end

function BetterFlags.mensagemDeBoasVindas()
    ac.onOnlineWelcome(function(message, config) --Reads the script config from the extra options
        BetterFlags.parsedConfig = tostring(config)
        local configCheck = config:mapSection("BETTERFLAGS",
            { NO_OVERTAKE_ZONE_1 = { 0, 0 }, NO_OVERTAKE_ZONE_2 = { 0, 0 }, NO_OVERTAKE_ZONE_3 = { 0, 0 } })

        ac.debug("config", configCheck)

        BetterFlags.noOvertake1_S, BetterFlags.noOvertake1_E = config:get("BETTERFLAGS", "NO_OVERTAKE_ZONE_1", 0),
            config:get("BETTERFLAGS", "NO_OVERTAKE_ZONE_1", 0, 2)
        BetterFlags.noOvertake2_S, BetterFlags.noOvertake2_E = config:get("BETTERFLAGS", "NO_OVERTAKE_ZONE_2", 0),
            config:get("BETTERFLAGS", "NO_OVERTAKE_ZONE_2", 0, 2)
        BetterFlags.noOvertake3_S, BetterFlags.noOvertake3_E = config:get("BETTERFLAGS", "NO_OVERTAKE_ZONE_3", 0),
            config:get("BETTERFLAGS", "NO_OVERTAKE_ZONE_3", 0, 2)
        BetterFlags.meatballThreshold = config:get("BETTERFLAGS", "MEATBALL_THRESHOLD", 0.10)
        BetterFlags.slowCarFlagPersist = (config:get("BETTERFLAGS", "SLOW_CAR_FLAG_PERSIST", 1.1)) * 1000
        BetterFlags.slowCarDistance = (config:get("BETTERFLAGS", "SLOW_CAR_WARN_DISTANCE", 0.1))
    end)
end

function BetterFlags.flagHandler()
    if ((BetterFlags.trackProgress > BetterFlags.noOvertake1_S) and (BetterFlags.trackProgress < BetterFlags.noOvertake1_E)) or 
       ((BetterFlags.trackProgress > BetterFlags.noOvertake2_S) and (BetterFlags.trackProgress < BetterFlags.noOvertake2_E)) or 
       ((BetterFlags.trackProgress > BetterFlags.noOvertake3_S) and (BetterFlags.trackProgress < BetterFlags.noOvertake3_E)) or 
       settingsOverride then
        currentFlags[1][1] = true
    else
        currentFlags[1][1] = false
    end

    if BetterFlags.shouldSlowCar() or settingsOverride then
        currentFlags[2][1] = true
    else
        currentFlags[2][1] = false
    end

    if BetterFlags.shouldMeatball() or settingsOverride then
        currentFlags[3][1] = true
    else
        currentFlags[3][1] = false
    end
end

function BetterFlags.shouldSlowCar()
    if (CAR.speedKmh < 30) and not (CAR.isInPitlane) and (CAR.wheelsOutside < 3) and (SIM.timeToSessionStart < -10000) then
        if BetterFlags.lastSlowCarBroadcastAttempt + BetterFlags.slowCarCooldown < BetterFlags.totalElapsedTime then
            BetterFlags.lastSlowCarBroadcastAttempt = BetterFlags.totalElapsedTime
            --ac.broadcastSharedEvent("broadcastSlowCar", BetterFlags.trackProgress)
            slowCarEvent({ slowCarProgress = BetterFlags.trackProgress })
        end

        return true
    elseif BetterFlags.lastSlowCarRecieve + BetterFlags.slowCarFlagPersist > BetterFlags.totalElapsedTime then
        return true
    else
        return false
    end
end

function BetterFlags.shouldMeatball()
    if (CAR.wheels[0].suspensionDamage > BetterFlags.meatballThreshold) or
        (CAR.wheels[1].suspensionDamage > BetterFlags.meatballThreshold) or
        (CAR.wheels[2].suspensionDamage > BetterFlags.meatballThreshold) or
        (CAR.wheels[3].suspensionDamage > BetterFlags.meatballThreshold) or
        CAR.wheels[0].isBlown or
        CAR.wheels[1].isBlown or
        CAR.wheels[2].isBlown or
        CAR.wheels[3].isBlown
    --CAR.wheels[4].isBlown

    then
        return true
    else
        return false
    end
end

slowCarEvent = ac.OnlineEvent({
    -- message structure layout:
    key = ac.StructItem.key('slowCarEvent'),
    slowCarProgress = ac.StructItem.float(),
}, function(sender, data)
    ac.debug('Got message: from', sender and sender.index or -1)
    ac.debug('Got message: text', data.slowCarProgress)
    if ((data.slowCarProgress + 0.01) > BetterFlags.trackProgress - math.floor((BetterFlags.trackProgress + BetterFlags.slowCarDistance)) and (data.slowCarProgress < ((BetterFlags.trackProgress + BetterFlags.slowCarDistance) - math.floor((BetterFlags.trackProgress + BetterFlags.slowCarDistance))))) then
        BetterFlags.lastSlowCarRecieve = BetterFlags.totalElapsedTime
    end
end, ac.SharedNamespace.ServerScript)
    ac.debug("!version", "betterflags v0.51")


function BetterFlags.makeFlags()
    local startFlag = ui.ExtraCanvas(vec2(256, 256))
    startFlag:setName("startFlag")
    startFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Start)
    end)

    local cautionFlag = ui.ExtraCanvas(vec2(256, 256))
    cautionFlag:setName("cautionFlag")
    cautionFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Caution)
    end)

    local slipperyFlag = ui.ExtraCanvas(vec2(256, 256))
    slipperyFlag:setName("slipperyFlag")
    slipperyFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Slippery)
    end)

    local blackFlag = ui.ExtraCanvas(vec2(256, 256))
    blackFlag:setName("blackFlag")
    blackFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Stop)
    end)

    local whiteFlag = ui.ExtraCanvas(vec2(256, 256))
    whiteFlag:setName("whiteFlag")
    whiteFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.SlowVehicle)
    end)

    local ambulanceFlag = ui.ExtraCanvas(vec2(256, 256))
    ambulanceFlag:setName("ambulanceFlag")
    ambulanceFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Ambulance)
    end)

    local blackWhiteFlag = ui.ExtraCanvas(vec2(256, 256))
    blackWhiteFlag:setName("blackWhiteFlag")
    blackWhiteFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.ReturnToPits)
    end)

    local meatballFlag = ui.ExtraCanvas(vec2(256, 256))
    meatballFlag:setName("meatballFlag")
    meatballFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.MechanicalFailure)
    end)

    local blueFlag = ui.ExtraCanvas(vec2(256, 256))
    blueFlag:setName("blueFlag")
    blueFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.FasterCar)
    end)

    local code60Flag = ui.ExtraCanvas(vec2(256, 256))
    code60Flag:setName("code60Flag")
    code60Flag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Code60)
    end)

    flagsWindow = ui.ExtraCanvas(vec2(windowWidth, windowHeight))
    flagsWindow:setName("FlagWindow")

    local NoOver = { true, slipperyFlag }
    local Slow = { true, whiteFlag }
    local Meatball = { true, meatballFlag }
    local Code60 = { false, code60Flag }

    currentFlags = { NoOver, Slow, Meatball, Code60 }
end

function script.update(dt)
    BetterFlags.totalElapsedTime = SIM.currentSessionTime
    BetterFlags.trackProgress = CAR.splinePosition

    ac.debug('Elapsed totalElapsedTime', BetterFlags.totalElapsedTime)
    --ac.debug('asconfig', parsedConfig)
    --        ac.debug('Progress', ac.flagType.Ambulance)
    --ac.debug('speed', CAR.wheels[1].suspensionDamage)
    --ac.debug('whatever', configChecks)
    --ac.debug('uiScale', uiScale)
    --ac.debug('mirrorscale', mirrorScale)
    --ac.debug('windowHeight', image1posy)

    ac.debug("batt", currentFlags)
    ac.debug("dm", SIM.directMessagingAvailable)
    ac.debug("udp", SIM.directUDPMessagingAvailable)

    BetterFlags.flagHandler()
end

--###############################################################################

--sending
ac.onChatMessage(function()
    --ac.broadcastSharedEvent("broadcastSlowCar", 0.3)
    ac.store("testGameState", "false")
end)


--UI FUNCTIONSSS
ac.onResolutionChange(function()
    windowWidth, windowHeight = ac.getSim().windowWidth, ac.getSim().windowHeight

    local mirrorScale = windowHeight / 1800


    local vmirrorTop = (85 / uiScale)
    local vmirrorLeft = ((windowWidth / 2) - (425.45525 * mirrorScale) - 2) / uiScale
    local vmirrorBottom = ((213.78521 * mirrorScale + 83.3) / uiScale)
    local vmirrorRight = ((windowWidth / 2) + (425.45525 * mirrorScale) + 2) / uiScale
    flagsWindow = ui.ExtraCanvas(vec2(windowWidth, windowHeight))
end)

ui.registerOnlineExtra(ui.Icons.Flag, "BetterFlags Settings", function() return true end,

    function() --UiCallback
        settingsOverride = true

        tempSettings.flagWindowX = ui.slider("Flag Left/Right", tempSettings.flagWindowX, 0, 1)
        tempSettings.flagWindowY = ui.slider("Flag Up/Down", tempSettings.flagWindowY, 0, 1)



        if ui.modernButton("Apply Settings", vec2(200, 50), ui.ButtonFlags.None, ui.Icons.Save) then
            betterFlagSettings = tempSettings
            return true
        else
            return false
        end
    end,
    function(cancel) --CloseCallback
        settingsOverride = false
    end, ui.OnlineExtraFlags.Tool)



function script.drawUI() --Draws a shitty UI for it.
    if settingsOverride then
        ui.setCursor(vec2(tempSettings.flagWindowX * windowWidth, tempSettings.flagWindowY * windowHeight))
    else
        ui.setCursor(vec2(betterFlagSettings.flagWindowX * windowWidth, betterFlagSettings.flagWindowY * windowHeight))
    end

    flagsWindow:clear()
    flagsWindow:update(function(dt)
        local blanks = 0
        for i = 1, #currentFlags do
            if currentFlags[i][1] then
                ui.drawImage(currentFlags[i][2], vec2((120 * (i - blanks)), 0), vec2(256 + (120 * (i - blanks)), 256))
            else
                blanks = blanks + 1
            end
        end
    end)
    ui.image(flagsWindow, vec2(windowWidth, windowHeight))

    ui.setCursor(vec2(0, 0))
end
