

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

SIM.speedLimitKmh = 200
ac.setDriverChatNameColor(CAR, rgbm(0, 5, 0, 1))

ac.registerOnlineExtra('Meu Menu de Admin', function()
    ui.text("Olá, Admin!")

    -- O 'if' verifica se o botão foi clicado naquele frame
    if ui.button("Dar Kick em alguém") then
        -- Lógica de kick: enviando um comando para o servidor
        ac.sendChatMessage("/kick 1") 
        ac.log("Comando de kick enviado!")
    end
end, ui.OnlineExtraFlags.Admin + ui.OnlineExtraFlags.Tool)

function script.update(dt)
   
    
end

