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
