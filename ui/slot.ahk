; =====================================================
; ui\slot.ahk — Componente de slot clicável (tema Pokémon)
; =====================================================

; ─── VISUAL ──────────────────────────────────────────
AtualizarVisual(ctrl, ativo) {
    try {
        if (ativo) {
            ctrl.slot.Opt("Background0x3D3D5C")
            ctrl.txt.Opt("Background0x3D3D5C")
            ctrl.txt.SetFont("cFFCC00 Bold")
        } else {
            ctrl.slot.Opt("Background0x2D2D44")
            ctrl.txt.Opt("Background0x2D2D44")
            ctrl.txt.SetFont("cF5F5F5 Bold")
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

    ; Exclusividade: ativar um combo desliga os outros
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
CriarSlot(gui, x, y, texto, icone, callback, ativo := false, slotW := 110, slotH := 116) {
    lblH   := 20
    pad    := 4
    iconH  := slotH - lblH - (pad * 2)
    iconSz := Min(slotW - (pad * 2), iconH)

    slot := gui.AddText("x" x " y" y " w" slotW " h" slotH " Background0x2D2D44 Border")

    iconX := x + pad + ((slotW - (pad*2) - iconSz) // 2)
    pic   := gui.AddPicture("x" iconX " y" (y+pad) " w" iconSz " h" iconSz, icone)

    sep := gui.AddText("x" (x+1) " y" (y+slotH-lblH-2) " w" (slotW-2) " h1 Background0x6060AA")

    txt := gui.AddText(
        "x" (x+1) " y" (y+slotH-lblH) " w" (slotW-2) " h" lblH
        " Center c0xF5F5F5 Background0x2D2D44 +0x200",
        texto)
    txt.SetFont("s8 Bold", GF())

    pic.slot := slot
    pic.txt  := txt

    AtualizarVisual(pic, ativo)
    pic.OnEvent("Click", callback)

    return pic
}

; ─── BOTÃO LATERAL CFG ───────────────────────────────
CriarBotaoLateral(gui, x, y, texto, callback, cfgW := 52, slotH := 116) {
    btn := gui.AddText(
        "x" x " y" y " w" cfgW " h" slotH " Background0x2D2D44 Border Center +0x200 c0xAAAACC",
        texto
    )
    btn.SetFont("s8 Bold", GF())
    btn.OnEvent("Click", callback)
    return btn
}

; ─── BOTÃO DE CONFIG (telas de configuração) ─────────
CriarBotaoConfig(gui, x, y, texto, callback) {
    btn := gui.AddText(
        "x" x " y" y " w220 h30 Background0x2D2D44 Border Center +0x200 cFFCC00",
        "▶ " texto
    )
    btn.SetFont("s7 Bold", GF())
    btn.OnEvent("Click", callback)
    return btn
}
