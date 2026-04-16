

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))



function makeFlags()

    startFlag = ui.ExtraCanvas(vec2(256,256)) 
    startFlag:setName("startFlag")
    startFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.Start)
    end)

    cautionFlag = ui.ExtraCanvas(vec2(256,256)) 
    cautionFlag:setName("cautionFlag")
    cautionFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.Caution)
    end)

    slipperyFlag = ui.ExtraCanvas(vec2(256,256)) 
    slipperyFlag:setName("slipperyFlag")
    slipperyFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.Slippery)
    end)

    blackFlag = ui.ExtraCanvas(vec2(256,256)) 
    blackFlag:setName("blackFlag")
    blackFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.Stop)
    end)

    whiteFlag = ui.ExtraCanvas(vec2(256,256)) 
    whiteFlag:setName("whiteFlag")
    whiteFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.SlowVehicle)
    end)

    ambulanceFlag = ui.ExtraCanvas(vec2(256,256)) 
    ambulanceFlag:setName("ambulanceFlag")
    ambulanceFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.Ambulance)
    end)

    blackWhiteFlag = ui.ExtraCanvas(vec2(256,256)) 
    blackWhiteFlag:setName("blackWhiteFlag")
    blackWhiteFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.ReturnToPits)
    end)

    meatballFlag = ui.ExtraCanvas(vec2(256,256)) 
    meatballFlag:setName("meatballFlag")
    meatballFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.MechanicalFailure)
    end)

    blueFlag = ui.ExtraCanvas(vec2(256,256)) 
    blueFlag:setName("blueFlag")
    blueFlag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.FasterCar)
    end)

    code60Flag = ui.ExtraCanvas(vec2(256,256)) 
    code60Flag:setName("code60Flag")
    code60Flag:update(function (dt)
        ui.drawRaceFlag(ac.FlagType.Code60)
    end)

    flagsWindow = ui.ExtraCanvas(vec2(windowWidth,windowHeight))
    flagsWindow:setName("FlagWindow")

    NoOver = {true,slipperyFlag}
    Slow = {true, whiteFlag}
    Meatball = {true, meatballFlag}
    Code60 = {false , code60Flag}

    currentFlags = {NoOver,Slow,Meatball,Code60}


end

makeFlags()


function script.update(dt)    

    ac.debug("batt", currentFlags)
   
    if CAR.wheelsOutside > 3 then
           
        ac.debug("Wheels Outside", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(5, 0, 0, 1))       
        
        

    elseif CAR.wheelsOutside == 0 then
        ac.debug("Wheels onTrack", CAR.wheelsOutside)
        ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))
        
    end

    
end

