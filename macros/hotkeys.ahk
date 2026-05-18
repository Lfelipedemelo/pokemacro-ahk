; =====================================================
; macros\hotkeys.ahk — Registro de hotkeys e dispatch
; =====================================================

global _macroExecutando := false

_MontarChaveHk(tecla) {
    if (tecla = "N/A" || tecla = "")
        return ""
    prefixo := (tecla ~= "i)Button") ? "$*" : "$"
    return prefixo . tecla
}

AtualizarHotkeyCombo() {
    global macros, _macroExecutando
    static hotkeysRegistradas := Map()

    for hk, _ in hotkeysRegistradas {
        try Hotkey(hk, "Off")
        try Hotkey(hk, "Delete")
    }
    hotkeysRegistradas.Clear()

    JanelaAtiva()   => WinActive("ahk_exe pxgme.exe")
    PodeExecutar()  => JanelaAtiva() && !_macroExecutando

    ; ── Registra hotkey de execução (requer janela ativa e macro ligado) ──
    RegistrarExecucao(chave, nomeMacro) {
        if (chave = "")
            return
        try {
            HotIf(((n, *) => PodeExecutar() && macros[n]).Bind(nomeMacro))
            Hotkey(chave, ProcessarPressionamento, "On")
            hotkeysRegistradas[chave] := true
        }
    }

    ; ── Registra hotkey de toggle (global, sem restrição de janela) ──
    RegistrarToggle(chave, nomeMacro) {
        if (chave = "")
            return
        try {
            HotIf()
            Hotkey(chave, ((n, *) => ToggleMacroPorHotkey(n)).Bind(nomeMacro), "On")
            hotkeysRegistradas[chave] := true
        }
    }

    ; ── Combos Principal e Secundário ──
    for tipo in ["comboPrincipal", "comboSecundario"] {
        cfg := GetCfg(tipo)
        RegistrarExecucao(_MontarChaveHk(cfg["teclaHotkey"]),  tipo)
        RegistrarToggle(  _MontarChaveHk(cfg["toggleHotkey"]), tipo)
    }

    ; ── Revive ──
    cfgR := GetCfg("Revive")
    RegistrarExecucao(_MontarChaveHk(cfgR["teclaHotkey"]),        "revive")
    RegistrarToggle(  _MontarChaveHk(cfgR["toggleHotkeyRevive"]), "revive")

    ; ── Combo Revive ──
    cfgCR := GetCfg("comboRevive")
    RegistrarExecucao(_MontarChaveHk(cfgCR["teclaHotkey"]),  "comboRevive")
    RegistrarToggle(  _MontarChaveHk(cfgCR["toggleHotkey"]), "comboRevive")

    ; ── Cooldown ──
    cfgC := GetCfg("Cooldown")
    RegistrarExecucao(_MontarChaveHk(cfgC["hotkeyCooldown"]),       "cooldown")
    RegistrarToggle(  _MontarChaveHk(cfgC["toggleHotkeyCooldown"]), "cooldown")

    HotIf()
}

; ─── Toggle via hotkey ────────────────────────────────────
ToggleMacroPorHotkey(nome) {
    global macros, uiRefs

    macros[nome] := !macros[nome]

    ; Exclusividade entre os três combos
    if (macros[nome] && (nome = "comboPrincipal" || nome = "comboSecundario" || nome = "comboRevive")) {
        for outro in ["comboPrincipal", "comboSecundario", "comboRevive"] {
            if (outro != nome && macros[outro]) {
                macros[outro] := false
                if (uiRefs.Has(outro))
                    AtualizarVisual(uiRefs[outro], false)
            }
        }
    }

    if (uiRefs.Has(nome))
        AtualizarVisual(uiRefs[nome], macros[nome])

    ShowHint(StrUpper(nome) ": " (macros[nome] ? "LIGADO" : "DESLIGADO"), 1200)
    AtualizarHotkeyCombo()
}

; ─── Despachante central ─────────────────────────────────
ProcessarPressionamento(thisHotkey) {
    global macros, executandoCooldown, _macroExecutando

    if (_macroExecutando)
        return
    _macroExecutando := true

    ; Strip prefixes to get raw key name
    teclaPura := thisHotkey
    for p in ["$", "~", "*"]
        teclaPura := StrReplace(teclaPura, p, "")

    if      (macros["comboPrincipal"]  && GetCfg("comboPrincipal")["teclaHotkey"]  = teclaPura)
        ExecutarCombo("comboPrincipal")
    else if (macros["comboSecundario"] && GetCfg("comboSecundario")["teclaHotkey"] = teclaPura)
        ExecutarCombo("comboSecundario")
    else if (macros["comboRevive"]     && GetCfg("comboRevive")["teclaHotkey"]     = teclaPura)
        ExecutarComboRevive()
    else if (macros["revive"]          && GetCfg("Revive")["teclaHotkey"]          = teclaPura)
        ExecutarRevive()
    else if (macros["cooldown"]        && GetCfg("Cooldown")["hotkeyCooldown"]     = teclaPura) {
        if (executandoCooldown) {
            executandoCooldown := false
            ShowHint("CANCELADO", 1000)
        } else {
            ExecutarMacroCooldown()
        }
    }

    _macroExecutando := false
}
