; =====================================================
; lib\globals.ahk — Estado global da aplicação
; =====================================================

global configFile := "config.ini"
global myGui      := 0
global cfgAberta  := false

; Atalho para obter a fonte atual do INI.
GF() {
    global configFile
    return IniRead(configFile, "Geral", "fonte", "Courier New")
}

; Estado de execução dos macros
global interromperCombo    := false
global executandoCooldown  := false

; Mapa de macros ativos (nome => bool)
global macros := Map(
    "comboPrincipal",  false,
    "comboSecundario", false,
    "revive",          false,
    "cooldown",        false,
    "comboRevive",     false
)

; Mapa de ícones usados na interface principal
global icons := Map(
    "comboPrincipal",  "icons\combo_principal.png",
    "comboSecundario", "icons\combo_secundario.png",
    "revive",          "icons\revive.png",
    "cooldown",        "icons\cooldown.png",
    "comboRevive",     "icons\combo_revive.png"
)

; Referências de controles de UI (preenchidas em CriarInterface)
global uiRefs := Map()

; Anti-double-click
global lastClick := 0

; Controles de UI do Cooldown
global radiosCooldown    := []
global editsCooldown     := []
global txtHotkeyCooldown := 0
global txtPosicaoClique  := 0

; ─── Modo compacto ────────────────────────────────────
global modoCompacto := false

; ─── Sistema de temas ────────────────────────────────
; Retorna o nome do tema atual do INI
GetTema() {
    global configFile
    return IniRead(configFile, "Geral", "tema", "Pokédex Vermelho")
}

; Retorna o Map de cores do tema atual
; Uso: T()["BG"] , T()["ACCENT"] etc.
T() {
    switch GetTema() {
        case "Night Blue":
            return Map(
                "BG",        "0x0D1B2A",   ; fundo principal
                "BG2",       "0x1B2A3B",   ; fundo slot/campo
                "BG3",       "0x243447",   ; hover / ativo
                "ACCENT",    "0x4FC3F7",   ; azul claro
                "ACCENT2",   "0x0288D1",   ; azul médio
                "TEXT",      "0xE0F7FA",   ; texto principal
                "MUTED",     "0x607D8B",   ; texto secundário
                "SEP",       "0x263B4E",   ; separadores
                "DANGER",    "0xE53935",   ; botão reset
                "STRIPE1",   "0x0D47A1",   ; faixa 1
                "STRIPE2",   "0x1565C0",   ; faixa 2
                "STRIPE3",   "0x1976D2"    ; faixa 3
            )
        case "Gold":
            return Map(
                "BG",        "0x1A1400",
                "BG2",       "0x2A2200",
                "BG3",       "0x3A3000",
                "ACCENT",    "0xFFD600",
                "ACCENT2",   "0xFFA000",
                "TEXT",      "0xFFF9C4",
                "MUTED",     "0x9E8C00",
                "SEP",       "0x4A3F00",
                "DANGER",    "0xD32F2F",
                "STRIPE1",   "0xFFD600",
                "STRIPE2",   "0xFFA000",
                "STRIPE3",   "0xFF6F00"
            )
        case "Minimal":
            return Map(
                "BG",        "0x1C1C1C",
                "BG2",       "0x2A2A2A",
                "BG3",       "0x383838",
                "ACCENT",    "0xE0E0E0",
                "ACCENT2",   "0x9E9E9E",
                "TEXT",      "0xF5F5F5",
                "MUTED",     "0x757575",
                "SEP",       "0x424242",
                "DANGER",    "0xE53935",
                "STRIPE1",   "0x424242",
                "STRIPE2",   "0x616161",
                "STRIPE3",   "0x757575"
            )
        default: ; "Pokédex Vermelho"
            return Map(
                "BG",        "0x1A1A2E",
                "BG2",       "0x2D2D44",
                "BG3",       "0x3D3D5C",
                "ACCENT",    "0xFFCC00",
                "ACCENT2",   "0x6060AA",
                "TEXT",      "0xF5F5F5",
                "MUTED",     "0xAAAACC",
                "SEP",       "0x6060AA",
                "DANGER",    "0xCC0000",
                "STRIPE1",   "0xCC0000",
                "STRIPE2",   "0xFFCC00",
                "STRIPE3",   "0x3B4CCA"
            )
    }
}
