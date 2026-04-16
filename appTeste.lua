SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))




--ui init
settingsOverride = false
windowWidth, windowHeight = ac.getSim().windowWidth, ac.getSim().windowHeight
uiScale = ac.getUI().uiScale
testGameState = false


betterFlagSettings = ac.storage({
    flagWindowX = 0, flagWindowY = 0, flagWindowScale = 1
})

tempSettings = betterFlagSettings

function makeFlags()
    startFlag = ui.ExtraCanvas(vec2(256, 256))
    startFlag:setName("startFlag")
    startFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Start)
    end)

    cautionFlag = ui.ExtraCanvas(vec2(256, 256))
    cautionFlag:setName("cautionFlag")
    cautionFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Caution)
    end)

    slipperyFlag = ui.ExtraCanvas(vec2(256, 256))
    slipperyFlag:setName("slipperyFlag")
    slipperyFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Slippery)
    end)

    blackFlag = ui.ExtraCanvas(vec2(256, 256))
    blackFlag:setName("blackFlag")
    blackFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Stop)
    end)

    whiteFlag = ui.ExtraCanvas(vec2(256, 256))
    whiteFlag:setName("whiteFlag")
    whiteFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.SlowVehicle)
    end)

    ambulanceFlag = ui.ExtraCanvas(vec2(256, 256))
    ambulanceFlag:setName("ambulanceFlag")
    ambulanceFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Ambulance)
    end)

    blackWhiteFlag = ui.ExtraCanvas(vec2(256, 256))
    blackWhiteFlag:setName("blackWhiteFlag")
    blackWhiteFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.ReturnToPits)
    end)

    meatballFlag = ui.ExtraCanvas(vec2(256, 256))
    meatballFlag:setName("meatballFlag")
    meatballFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.MechanicalFailure)
    end)

    blueFlag = ui.ExtraCanvas(vec2(256, 256))
    blueFlag:setName("blueFlag")
    blueFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.FasterCar)
    end)

    code60Flag = ui.ExtraCanvas(vec2(256, 256))
    code60Flag:setName("code60Flag")
    code60Flag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Code60)
    end)

    --dosn't exist in ac but in app exist
    stopCanceled = ui.ExtraCanvas(vec2(256, 256))
    stopCanceled:setName("stopCanceled")
    stopCanceled:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.StopCancel)
    end)

    --dosn't exist in ac but in app exist
    coutionFlag = ui.ExtraCanvas(vec2(256, 256))
    coutionFlag:setName("coutionFlag")
    coutionFlag:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.Caution)
    end)

    flagsWindow = ui.ExtraCanvas(vec2(windowWidth, windowHeight))
    flagsWindow:setName("FlagWindow")

    NoOver = { true, slipperyFlag }
    Slow = { true, whiteFlag }
    Meatball = { true, meatballFlag }
    Code60 = { false, code60Flag }

    currentFlags = { NoOver, Slow, Meatball, Code60 }
end

makeFlags()


function script.update(dt)
    ac.debug("batt", currentFlags)

    if CAR.wheelsOutside > 3 then
        ac.debug("Wheels Outside", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(5, 0, 0, 1))

        currentFlags[1][1] = true
        currentFlags[2][1] = true
        currentFlags[3][1] = true
        currentFlags[4][1] = true

    elseif CAR.wheelsOutside == 0 then
        ac.debug("Wheels onTrack", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))
        currentFlags[1][1] = false
        currentFlags[2][1] = false
        currentFlags[3][1] = false
        currentFlags[4][1] = false
    end
end

--UI functions
--UI FUNCTIONSSS
-- ajusta a resolução da janela e reposiciona a janela de bandeiras de acordo com a resolução, mantendo o mesmo tamanho relativo
ac.onResolutionChange(function()
    windowWidth, windowHeight = ac.getSim().windowWidth, ac.getSim().windowHeight

    mirrorScale = windowHeight / 1800


    vmirrorTop = (85 / uiScale)
    vmirrorLeft = ((windowWidth / 2) - (425.45525 * mirrorScale) - 2) / uiScale
    vmirrorBottom = ((213.78521 * mirrorScale + 83.3) / uiScale)
    vmirrorRight = ((windowWidth / 2) + (425.45525 * mirrorScale) + 2) / uiScale
    flagsWindow = ui.ExtraCanvas(vec2(windowWidth, windowHeight))
end)


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
