# BetterFlags / FlagSystem

Sistema de gerenciamento de bandeiras para Assetto Corsa.

## Descrição

Este projeto fornece um sistema avançado de exibição de bandeiras de corrida para Assetto Corsa, com detecção automática de condições como:
- Zonas de não ultrapassagem
- Carros lentos na pista
- Danos mecânicos (bandeira "meatball")
- E outras condições de corrida

## Versões

### BetterFlags (app.lua)
- Versão original v0.51
- Sistema básico de bandeiras

### FlagSystem (app2.lua) 
- Versão refatorada v1.0
- Código mais modular e organizado
- Melhor estrutura de configuração
- API mais limpa

## Instalação

1. Copie o arquivo `.lua` desejado para a pasta `apps/lua` do Assetto Corsa
2. Inicie o jogo e o script será carregado automaticamente
3. Acesse as configurações através do menu online extras (ícone de bandeira)

## Configuração

O sistema pode ser configurado através do servidor online com as seguintes opções:

- `NO_OVERTAKE_ZONE_1`, `NO_OVERTAKE_ZONE_2`, `NO_OVERTAKE_ZONE_3`: Zonas de não ultrapassagem (início e fim)
- `MEATBALL_THRESHOLD`: Limite de dano para bandeira meatball (padrão: 0.10)
- `SLOW_CAR_FLAG_PERSIST`: Tempo de persistência da bandeira de carro lento (padrão: 1.1s)
- `SLOW_CAR_WARN_DISTANCE`: Distância para warning de carro lento (padrão: 0.1)

## Licença

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

Copyright (c) 2026 Rubens Pereira

## Autor

Rubens Pereira

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## Histórico de Versões

- **v0.51** (BetterFlags): Versão inicial com funcionalidades básicas
- **v1.0** (FlagSystem): Refatoração completa com melhor arquitetura e modularidade