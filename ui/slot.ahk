; =====================================================
; ui\slot.ahk — Componente de slot (tema dinâmico)
; =====================================================

; ─── VISUAL ──────────────────────────────────────────
AtualizarVisual(ctrl, ativo) {
    try {
        if (ativo) {
            ctrl.slot.Opt("Background" T()["BG3"])
            ctrl.txt.Opt("Background"  T()["BG3"])
            ctrl.txt.SetFont("c" T()["ACCENT"] " Bold")
        } else {
            ctrl.slot.Opt("Background" T()["BG2"])
            ctrl.txt.Opt("Background"  T()["BG2"])
            ctrl.txt.SetFont("c" T()["TEXT"] " Bold")
        }
    }
}

; ─── TOGGLE ──────────────────────────────────────────
ToggleMacro(nome, controle) {
    global macros, lastClick, uiRefs

    if (A_TickCount - lastClick < 150)
        return
    lastClick := A_TickCount

    macros[nome] := !macros[nome]

    if (macros[nome] && (nome = "comboPrincipal" || nome = "comboSecundario" || nome = "comboRevive")) {
        for outro in ["comboPrincipal", "comboSecundario", "comboRevive"] {
            if (outro != nome && macros[outro]) {
                macros[outro] := false
                if (uiRefs.Has(outro))
                    try AtualizarVisual(uiRefs[outro], false)
            }
        }
    }

    try AtualizarVisual(controle, macros[nome])
    AtualizarHotkeyCombo()
}

; ─── SLOT PRINCIPAL ──────────────────────────────────
; modoCompacto = true  → só texto, sem ícone, slot menor
; modoCompacto = false → ícone + texto + keyHint
;
; Cálculo de ícone (modo normal):
;   separador fica em y + slotH - lblH - 2
;   ícone começa em y + pad e tem tamanho iconSz
;   iconSz = slotH - lblH - pad*2 - 8  (8px de folga garantida)
CriarSlot(gui, x, y, texto, icone, callback, ativo := false, slotW := 110, slotH := 116, keyHint := "") {
    global modoCompacto

    lblH := 24   ; altura do label no rodapé
    pad  := 6    ; padding interno

    slot := gui.AddText("x" x " y" y " w" slotW " h" slotH " Background" T()["BG2"] " Border")

    if (!modoCompacto) {
        ; ── Modo normal: ícone + separador + label ──
        ; iconSz calculado com folga de 8px para não cortar
        iconSz := slotH - lblH - (pad * 2) - 8
        iconSz := Min(slotW - (pad * 2), iconSz)   ; garante quadrado

        iconX  := x + pad + ((slotW - (pad*2) - iconSz) // 2)
        pic    := gui.AddPicture("x" iconX " y" (y+pad) " w" iconSz " h" iconSz, icone)

        ; Separador entre ícone e label
        gui.AddText("x" (x+1) " y" (y+slotH-lblH-2) " w" (slotW-2) " h1 Background" T()["SEP"])

        ; Label
        txt := gui.AddText(
            "x" (x+1) " y" (y+slotH-lblH) " w" (slotW-2) " h" lblH
            " Center c" T()["TEXT"] " Background" T()["BG2"] " +0x200",
            texto)
        txt.SetFont("s8 Bold", GF())

        ; Miniatura da tecla — só a tecla do macro
        if (keyHint != "") {
            hintCtrl := gui.AddText(
                "x" (x+1) " y" (y+slotH-lblH-14) " w" (slotW-2) " h12"
                " Right c" T()["MUTED"] " Background" T()["BG2"],
                keyHint)
            hintCtrl.SetFont("s6", GF())
        }

        pic.slot := slot
        pic.txt  := txt
        AtualizarVisual(pic, ativo)
        pic.OnEvent("Click", callback)

    } else {
        ; ── Modo compacto: só texto centralizado, sem ícone ──
        ; Usa um controle fake para pic.slot e pic.txt
        txt := gui.AddText(
            "x" (x+1) " y" (y+1) " w" (slotW-2) " h" (slotH-2)
            " Center c" T()["TEXT"] " Background" T()["BG2"] " +0x200",
            texto)
        txt.SetFont("s9 Bold", GF())

        ; Proxy para AtualizarVisual funcionar igual
        slot.slot := slot
        slot.txt  := txt
        AtualizarVisual(slot, ativo)
        slot.OnEvent("Click", callback)
        txt.OnEvent("Click", callback)
        return slot
    }

    return pic
}

; ─── BOTÃO LATERAL CFG ───────────────────────────────
CriarBotaoLateral(gui, x, y, texto, callback, cfgW := 52, slotH := 116) {
    btn := gui.AddText(
        "x" x " y" y " w" cfgW " h" slotH
        " Background" T()["BG2"] " Border Center +0x200 c" T()["MUTED"],
        texto)
    btn.SetFont("s8 Bold", GF())
    btn.OnEvent("Click", callback)
    return btn
}

; ─── BOTÃO DE CONFIG (telas de configuração) ─────────
CriarBotaoConfig(gui, x, y, texto, callback) {
    btn := gui.AddText(
        "x" x " y" y " w220 h30 Background" T()["BG2"] " Border Center +0x200 c" T()["ACCENT"],
        "▶ " texto)
    btn.SetFont("s7 Bold", GF())
    btn.OnEvent("Click", callback)
    return btn
}
