

SIM = ac.getSim()
CAR = ac.getCar(SIM.focusedCar)

SIM.speedLimitKmh = 200
ac.setDriverChatNameColor(CAR, rgbm(0, 5, 0, 1))

-- Registrando uma ferramenta extra no chat
-- Registrando uma ferramenta extra no chat
ac.registerOnlineExtra('Meu Menu de Admin', function()
    -- Aqui vai o código da interface (UI)
    ui.text("Olá, Admin!")
    ui.button("Dar Kick em alguém")
        -- Lógica de kick
end, ui.OnlineExtraFlags.Admin + ui.OnlineExtraFlags.Tool)



