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

    flagsWindow = ui.ExtraCanvas(vec2(windowWidth, windowHeight))
    flagsWindow:setName("FlagWindow")

    --dosn't exist in ac but in app exist
    lastLapRace = ui.ExtraCanvas(vec2(windowWidth, windowHeight))
    lastLapRace:setName("lastLapRace")
    lastLapRace:update(function(dt)
        ui.drawRaceFlag(ac.FlagType.OneLapLeft)
    end)

    flagsWindow = ui.ExtraCanvas(vec2(windowWidth, windowHeight))
    flagsWindow:setName("FlagWindow")

    -- cria uma tabela passa o valor boleano e a bandeira correspondente, para facilitar a manipulação das bandeiras
    NoOver = { false, slipperyFlag }
    Slow = { false, whiteFlag }
    Meatball = { false, meatballFlag }
    Code60 = { false, code60Flag }

    currentFlags = { NoOver, Slow, Meatball, Code60 }
end

makeFlags()

function script.update(dt)
    ac.debug("batt", currentFlags)

    
    -- ac.SurfaceExtendedType.Grass
    local fl = CAR.wheels[0]    
    --ac.debug("setordapista", fl.surfaceSectorID)
    --ac.debug("nivel de sujeira", fl.tyreDirty)
    --ac.debug("tipo da superficie", fl.surfaceType)
    --ac.debug("contador de cortes", CAR.lapCutsCount)
    regraSafetyCar()
   
    
    

    if CAR.wheelsOutside > 3 then
        ac.debug("Wheels Outside", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(5, 0, 0, 1))
        
        --pegamos o nover e o valor boleano da tabela, e o valor true
        currentFlags[1][1] = true
        --physics.setCarPenalty(ac.PenaltyType.MandatoryPits, 1)

        
    elseif CAR.wheelsOutside == 0 then
        ac.debug("Wheels onTrack", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))
        currentFlags[1][1] = false
    end
end

--minhas functions
function regraSafetyCar()

    ac.debug("velocidade", CAR.velocity:length() * 3.6)
    ac.debug("isInPitlane", CAR.isInPitlane)
    ac.debug("isRacingCar", CAR.isRacingCar)

    if CAR.isInPitlane then
        ac.debug("isInPitlane", CAR.isInPitlane)
        currentFlags[1][1] = true
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

--da pra usar esse para fazer a regra de deltatime para cut
--function ac.getTrackSectorName(trackProgress)

--ac.onTrackPointCrossed(carIndex, progress, callback)