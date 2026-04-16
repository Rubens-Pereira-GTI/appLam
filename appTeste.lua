

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

ac.setDriverChatNameColor(CAR.index, rgbm(0, 5, 0, 1))

ac.registerOnlineExtra('Meu Menu de Admin', function()
    ui.text("Olá, Admin!")
    if ui.button("Dar Kick em alguém") then
        ac.sendChatMessage("/kick 1") 
    end
end, ui.OnlineExtraFlags.Admin + ui.OnlineExtraFlags.Tool)

function script.update(dt)
   
    
end

