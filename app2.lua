--[[
    FlagSystem v1.0 - Sistema de Gerenciamento de Bandeiras para Assetto Corsa
    Autor: Rubens Pereira
    Baseado no código original BetterFlags v0.51
    
    Este módulo gerencia a exibição de bandeiras de corrida baseado em condições
    como zonas de não ultrapassagem, carros lentos, danos mecânicos, etc.
]]

local FlagSystem = {}

--==============================================================================
-- CONSTANTES DE CONFIGURAÇÃO
--==============================================================================

local CONFIG = {
    -- Limites para carro lento
    SLOW_CAR_SPEED_THRESHOLD = 30,           -- km/h
    SLOW_CAR_COOLDOWN = 1000,                -- ms
    SLOW_CAR_DISTANCE = 0.1,                 -- distância para warning
    SLOW_CAR_FLAG_PERSIST = 1.1,             -- segundos (convertido para ms depois)
    
    -- Limite para bandeira meatball (danos)
    MEATBALL_DAMAGE_THRESHOLD = 0.10,
    
    -- Configurações de amostragem
    SAMPLE_TIME = 0.5,                       -- segundos
    DISPLAY_WARNING_FOR = 5,                 -- segundos
    
    -- Configurações de UI
    FLAG_CANVAS_SIZE = 256,                  -- pixels
    FLAG_SPACING = 120,                      -- pixels entre bandeiras
    DEFAULT_WINDOW_SCALE = 1,
    
    -- Limites de sessão
    SESSION_START_THRESHOLD = -10000,        -- ms
    WHEELS_OUTSIDE_LIMIT = 3,                -- máximo de rodas fora da pista
}

--==============================================================================
-- VARIÁVEIS DO SISTEMA
--==============================================================================

-- Referências para objetos da API do AC (cache para performance)
local sim = nil
local car = nil
local ui = nil

-- Estado do sistema
local system_initialized = false
local settings_override = false

-- Configurações de UI persistentes
local ui_settings = {
    flag_window_x = 0,
    flag_window_y = 0,
    flag_window_scale = CONFIG.DEFAULT_WINDOW_SCALE
}

-- Configurações temporárias (durante edição)
local temp_settings = {}

-- Zonas de não ultrapassagem
local no_overtake_zones = {
    { start = 0, end_pos = 0 },
    { start = 0, end_pos = 0 },
    { start = 0, end_pos = 0 }
}

-- Estado das bandeiras
local active_flags = {
    no_overtake = false,
    slow_car = false,
    meatball = false,
    code60 = false
}

-- Canvases das bandeiras
local flag_canvases = {}
local flags_window = nil

-- Timers e contadores
local last_slow_car_broadcast = 0
local last_slow_car_received = 0
local total_elapsed_time = 0
local track_progress = 0

--==============================================================================
-- FUNÇÕES PRIVADAS (UTILITÁRIAS)
--==============================================================================

--- Verifica se o carro está em uma zona de não ultrapassagem
-- @return boolean True se estiver em zona de não ultrapassagem
local function is_in_no_overtake_zone()
    for _, zone in ipairs(no_overtake_zones) do
        if zone.start > 0 and zone.end_pos > 0 then
            if track_progress > zone.start and track_progress < zone.end_pos then
                return true
            end
        end
    end
    return false
end

--- Verifica se deve mostrar bandeira de carro lento
-- @return boolean True se deve mostrar bandeira de carro lento
local function should_show_slow_car_flag()
    -- Condições para carro lento
    local is_slow = car.speedKmh < CONFIG.SLOW_CAR_SPEED_THRESHOLD
    local not_in_pitlane = not car.isInPitlane
    local wheels_ok = car.wheelsOutside < CONFIG.WHEELS_OUTSIDE_LIMIT
    local session_started = sim.timeToSessionStart < CONFIG.SESSION_START_THRESHOLD
    
    if is_slow and not_in_pitlane and wheels_ok and session_started then
        -- Verifica cooldown para broadcast
        if last_slow_car_broadcast + CONFIG.SLOW_CAR_COOLDOWN < total_elapsed_time then
            last_slow_car_broadcast = total_elapsed_time
            -- Envia evento de carro lento
            slow_car_event({ slow_car_progress = track_progress })
        end
        return true
    elseif last_slow_car_received + (CONFIG.SLOW_CAR_FLAG_PERSIST * 1000) > total_elapsed_time then
        return true
    end
    
    return false
end

--- Verifica se deve mostrar bandeira meatball (danos mecânicos)
-- @return boolean True se deve mostrar bandeira meatball
local function should_show_meatball_flag()
    -- Verifica danos na suspensão
    for i = 0, 3 do
        if car.wheels[i].suspensionDamage > CONFIG.MEATBALL_DAMAGE_THRESHOLD then
            return true
        end
    end
    
    -- Verifica pneus estourados
    for i = 0, 3 do
        if car.wheels[i].isBlown then
            return true
        end
    end
    
    return false
end

--- Atualiza o estado de todas as bandeiras
local function update_flags_state()
    active_flags.no_overtake = is_in_no_overtake_zone() or settings_override
    active_flags.slow_car = should_show_slow_car_flag() or settings_override
    active_flags.meatball = should_show_meatball_flag() or settings_override
    active_flags.code60 = false  -- Placeholder para funcionalidade futura
end

--- Cria os canvases para cada tipo de bandeira
local function create_flag_canvases()
    local canvas_size = vec2(CONFIG.FLAG_CANVAS_SIZE, CONFIG.FLAG_CANVAS_SIZE)
    
    -- Mapeamento de tipos de bandeira para seus canvases
    local flag_types = {
        start = ac.FlagType.Start,
        caution = ac.FlagType.Caution,
        slippery = ac.FlagType.Slippery,
        black = ac.FlagType.Stop,
        white = ac.FlagType.SlowVehicle,
        ambulance = ac.FlagType.Ambulance,
        black_white = ac.FlagType.ReturnToPits,
        meatball = ac.FlagType.MechanicalFailure,
        blue = ac.FlagType.FasterCar,
        code60 = ac.FlagType.Code60
    }
    
    for flag_name, flag_type in pairs(flag_types) do
        local canvas = ui.ExtraCanvas(canvas_size)
        canvas:setName(flag_name .. "_flag")
        canvas:update(function(dt)
            ui.drawRaceFlag(flag_type)
        end)
        flag_canvases[flag_name] = canvas
    end
    
    -- Cria janela principal para exibição das bandeiras
    local window_width, window_height = sim.windowWidth, sim.windowHeight
    flags_window = ui.ExtraCanvas(vec2(window_width, window_height))
    flags_window:setName("FlagsWindow")
end

--- Carrega configurações do servidor online
local function load_server_config(config)
    if not config then return end
    
    -- Carrega zonas de não ultrapassagem
    for i = 1, 3 do
        local zone_key = "NO_OVERTAKE_ZONE_" .. i
        local start_val = config:get("BETTERFLAGS", zone_key, 0)
        local end_val = config:get("BETTERFLAGS", zone_key, 0, 2)
        
        if no_overtake_zones[i] then
            no_overtake_zones[i].start = start_val
            no_overtake_zones[i].end_pos = end_val
        end
    end
    
    -- Carrega outras configurações
    CONFIG.MEATBALL_DAMAGE_THRESHOLD = config:get("BETTERFLAGS", "MEATBALL_THRESHOLD", 0.10)
    CONFIG.SLOW_CAR_FLAG_PERSIST = config:get("BETTERFLAGS", "SLOW_CAR_FLAG_PERSIST", 1.1)
    CONFIG.SLOW_CAR_DISTANCE = config:get("BETTERFLAGS", "SLOW_CAR_WARN_DISTANCE", 0.1)
    
    -- Debug: log das configurações carregadas
    ac.debug("FlagSystem", "Configurações carregadas do servidor")
end

--- Handler para evento de carro lento recebido de outros jogadores
slow_car_event = ac.OnlineEvent({
    key = ac.StructItem.key('slowCarEvent'),
    slow_car_progress = ac.StructItem.float(),
}, function(sender, data)
    ac.debug('FlagSystem', 'Evento de carro lento recebido de', sender and sender.index or -1)
    
    -- Verifica se o carro lento está próximo o suficiente
    local received_progress = data.slow_car_progress
    local distance_threshold = CONFIG.SLOW_CAR_DISTANCE
    
    local min_bound = track_progress - math.floor(track_progress + distance_threshold)
    local max_bound = (track_progress + distance_threshold) - math.floor(track_progress + distance_threshold)
    
    if (received_progress + 0.01) > min_bound and received_progress < max_bound then
        last_slow_car_received = total_elapsed_time
        ac.debug('FlagSystem', 'Carro lento detectado nas proximidades')
    end
end, ac.SharedNamespace.ServerScript)

--==============================================================================
-- FUNÇÕES PÚBLICAS (API DO MÓDULO)
--==============================================================================

--- Inicializa o sistema de bandeiras
function FlagSystem.initialize()
    if system_initialized then
        ac.debug("FlagSystem", "Sistema já inicializado")
        return
    end
    
    -- Obtém referências da API
    sim = ac.getSim()
    car = ac.getCar(sim.focusedCar)
    ui = ac.getUI()
    
    -- Carrega configurações persistentes
    local storage = ac.storage({
        flag_window_x = 0,
        flag_window_y = 0,
        flag_window_scale = CONFIG.DEFAULT_WINDOW_SCALE
    })
    
    ui_settings.flag_window_x = storage.flag_window_x
    ui_settings.flag_window_y = storage.flag_window_y
    ui_settings.flag_window_scale = storage.flag_window_scale
    
    temp_settings = {
        flag_window_x = ui_settings.flag_window_x,
        flag_window_y = ui_settings.flag_window_y,
        flag_window_scale = ui_settings.flag_window_scale
    }
    
    -- Configura handlers de eventos
    ac.onOnlineWelcome(function(message, config)
        load_server_config(config)
    end)
    
    -- Cria elementos visuais
    create_flag_canvases()
    
    -- Bloqueia mensagens do sistema relacionadas ao CSP
    ac.blockSystemMessages("$CSP0:")
    
    system_initialized = true
    ac.debug("FlagSystem", "Sistema inicializado com sucesso")
    ac.debug("!version", "FlagSystem v1.0")
end

--- Atualiza o estado do sistema (chamado a cada frame)
-- @param dt Delta time desde a última atualização
function FlagSystem.update(dt)
    if not system_initialized then return end
    
    -- Atualiza variáveis de tempo e posição
    total_elapsed_time = sim.currentSessionTime
    track_progress = car.splinePosition
    
    -- Atualiza estado das bandeiras
    update_flags_state()
    
    -- Debug informações (opcional)
    ac.debug("FlagSystem:time", total_elapsed_time)
    ac.debug("FlagSystem:flags", active_flags)
end

--- Renderiza a interface de usuário
function FlagSystem.render_ui()
    if not flags_window then return end
    
    -- Define posição da janela
    local window_width, window_height = sim.windowWidth, sim.windowHeight
    local x_pos, y_pos
    
    if settings_override then
        x_pos = temp_settings.flag_window_x * window_width
        y_pos = temp_settings.flag_window_y * window_height
    else
        x_pos = ui_settings.flag_window_x * window_width
        y_pos = ui_settings.flag_window_y * window_height
    end
    
    ui.setCursor(vec2(x_pos, y_pos))
    
    -- Renderiza as bandeiras ativas
    flags_window:clear()
    flags_window:update(function(dt)
        local x_offset = 0
        local flags_displayed = 0
        
        -- Ordem de exibição das bandeiras
        local display_order = {
            { key = "no_overtake", canvas = "slippery" },
            { key = "slow_car", canvas = "white" },
            { key = "meatball", canvas = "meatball" },
            { key = "code60", canvas = "code60" }
        }
        
        for _, flag_info in ipairs(display_order) do
            if active_flags[flag_info.key] and flag_canvases[flag_info.canvas] then
                local start_x = CONFIG.FLAG_SPACING * flags_displayed
                local end_x = CONFIG.FLAG_CANVAS_SIZE + (CONFIG.FLAG_SPACING * flags_displayed)
                
                ui.drawImage(
                    flag_canvases[flag_info.canvas],
                    vec2(start_x, 0),
                    vec2(end_x, CONFIG.FLAG_CANVAS_SIZE)
                )
                
                flags_displayed = flags_displayed + 1
            end
        end
    end)
    
    ui.image(flags_window, vec2(window_width, window_height))
    ui.setCursor(vec2(0, 0))
end

--==============================================================================
-- HANDLERS DE EVENTOS E CALLBACKS
--==============================================================================

--- Handler para mudança de resolução
ac.onResolutionChange(function()
    local window_width, window_height = sim.windowWidth, sim.windowHeight
    flags_window = ui.ExtraCanvas(vec2(window_width, window_height))
end)

--- Handler para mensagens de chat (debug)
ac.onChatMessage(function()
    ac.store("test_game_state", "false")
end)

--- Registra o extra online para configurações
ui.registerOnlineExtra(
    ui.Icons.Flag,
    "FlagSystem Settings",
    function() return true end,
    
    -- Callback de UI
    function()
        settings_override = true
        
        temp_settings.flag_window_x = ui.slider(
            "Posição Horizontal",
            temp_settings.flag_window_x,
            0, 1
        )
        
        temp_settings.flag_window_y = ui.slider(
            "Posição Vertical", 
            temp_settings.flag_window_y,
            0, 1
        )
        
        if ui.modernButton("Aplicar Configurações", vec2(200, 50), ui.ButtonFlags.None, ui.Icons.Save) then
            ui_settings = {
                flag_window_x = temp_settings.flag_window_x,
                flag_window_y = temp_settings.flag_window_y,
                flag_window_scale = temp_settings.flag_window_scale
            }
            
            -- Salva configurações persistentes
            local storage = ac.storage({
                flag_window_x = ui_settings.flag_window_x,
                flag_window_y = ui_settings.flag_window_y,
                flag_window_scale = ui_settings.flag_window_scale
            })
            
            storage.flag_window_x = ui_settings.flag_window_x
            storage.flag_window_y = ui_settings.flag_window_y
            storage.flag_window_scale = ui_settings.flag_window_scale
            
            return true
        end
        
        return false
    end,
    
    -- Callback de fechamento
    function(cancel)
        settings_override = false
    end,
    
    ui.OnlineExtraFlags.Tool
)

--==============================================================================
-- INICIALIZAÇÃO DO SCRIPT
--==============================================================================

-- Inicializa o sistema
FlagSystem.initialize()

-- Funções do script principal do AC
function script.update(dt)
    FlagSystem.update(dt)
end

function script.drawUI()
    FlagSystem.render_ui()
end

-- Exporta o módulo (para uso por outros scripts se necessário)
return FlagSystem