-- MIT License - Copyright (c) 2026 Rubens Pereira
-- testeDeMensagem.lua - App para enviar mensagem no chat do Assetto Corsa
-- Envia "app LAM funcionando" automaticamente ao carregar

-- Variável para controlar se a mensagem já foi enviada
local mensagemEnviada = false

-- Função para enviar mensagem no chat
local function enviarMensagemChat(texto)
    -- Método 1: Tentar usar ac.sendChatMessage se disponível
    if ac.sendChatMessage then
        ac.sendChatMessage(texto)
        return true
    end
    
    -- Método 2: Tentar usar ac.chat se disponível  
    if ac.chat then
        ac.chat(texto)
        return true
    end
    
    -- Método 3: Usar ac.debug como fallback (apenas para debug)
    ac.debug("testeDeMensagem", "Mensagem que seria enviada no chat: " .. texto)
    ac.debug("testeDeMensagem", "Função de envio de chat não encontrada na API")
    return false
end

-- Função principal de inicialização
local function inicializarApp()
    if not mensagemEnviada then
        ac.debug("testeDeMensagem", "Inicializando app...")
        
        -- Envia a mensagem no chat
        local sucesso = enviarMensagemChat("app LAM funcionando")
        
        if sucesso then
            ac.debug("testeDeMensagem", "Mensagem enviada com sucesso!")
        else
            ac.debug("testeDeMensagem", "Não foi possível enviar a mensagem no chat")
            ac.debug("testeDeMensagem", "Verifique se a API do CSP suporta envio de mensagens")
        end
        
        mensagemEnviada = true
    end
end

-- Evento quando o script é carregado
function script.init()
    ac.debug("testeDeMensagem", "Script carregado")
    inicializarApp()
end

-- Evento quando a sessão começa (alternativa)
ac.onSessionStart(function()
    ac.debug("testeDeMensagem", "Sessão iniciada")
    inicializarApp()
end)

-- Função update (obrigatória para scripts Lua do AC)
function script.update(dt)
    -- Nada a fazer aqui, apenas mantém o script ativo
end

-- Função drawUI (opcional)
function script.drawUI()
    -- Pode ser usada para mostrar status na UI
    ui.setCursor(vec2(10, 10))
    ui.label("testeDeMensagem.lua - Status: " .. (mensagemEnviada and "Mensagem enviada" or "Aguardando..."))
end

-- Handler para mensagens de chat recebidas (opcional)
ac.onChatMessage(function(sender, message)
    ac.debug("testeDeMensagem", "Chat recebido de " .. (sender or "sistema") .. ": " .. message)
end)

-- Informações de debug
ac.debug("testeDeMensagem", "Script testeDeMensagem.lua carregado")
ac.debug("!version", "testeDeMensagem v1.0")