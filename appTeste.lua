

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))

ui.registerOnlineExtra(ui.Icons.Settings, "Meu Menu", nil, function()
    ui.text("Olá!")
end)

function script.update(dt)
   
    
end

