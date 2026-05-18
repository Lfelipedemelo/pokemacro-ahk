; =====================================================
; ui\slot.ahk — Componente de slot clicável (tema Pokémon)
; =====================================================
;
; PALETA POKÉMON
;   Fundo principal  : 0x1A1A2E  (azul-noite)
;   Fundo slot       : 0x2D2D44  (cinza-roxo escuro)
;   Fundo slot hover : 0x3D3D5C
;   Ativo (borda/txt): 0xFFCC00  (amarelo Pikachu)
;   Inativo (borda)  : 0x6060AA
;   Texto normal     : 0xF5F5F5
;   Texto mudo       : 0xAAAACC
;   Botão config     : 0x3D3D5C
;   Vermelho Pokédex : 0xCC0000

; ─── VISUAL ──────────────────────────────────────────
; Ativo  → fundo escuro + texto amarelo
; Inativo→ fundo normal + texto branco
; O fundo do txt é sempre sincronizado com o slot
AtualizarVisual(ctrl, ativo) {
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

; ─── HOVER ───────────────────────────────────────────
SetHover(slot) {
    global hoverSlot

    if (hoverSlot && hoverSlot != slot) {
        hoverSlot.Opt("Background0x2D2D44")
        ; sincroniza txt se disponível via uiRefs
    }

    slot.Opt("Background0x3D3D5C")
    hoverSlot := slot
}

ClearHover() {
    global hoverSlot
    if (hoverSlot) {
        hoverSlot.Opt("Background0x2D2D44")
        hoverSlot := 0
    }
}

; ─── MOUSE MOVE HANDLER ──────────────────────────────
MouseMoveHandler(*) {
    global myGui

    if (!myGui)
        return

    MouseGetPos(, , , &ctrlHwnd)

    try ctrl := GuiCtrlFromHwnd(ctrlHwnd)
    catch {
        ClearHover()
        return
    }

    if IsObject(ctrl) && ctrl.HasProp("slot")
        SetHover(ctrl.slot)
    else
        ClearHover()
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
                    AtualizarVisual(uiRefs[outro], false)
            }
        }
    }

    AtualizarVisual(controle, macros[nome])
    AtualizarHotkeyCombo()
}

; ─── SLOT PRINCIPAL ──────────────────────────────────
; Layout interno do slot (slotW x slotH):
;   ┌─────────────┐
;   │  [ícone]    │  ← iconSz x iconSz (quadrado, padding 4px)
;   │─────────────│
;   │   LABEL     │  ← lblH px no rodapé
;   └─────────────┘
; O label fica ABAIXO do ícone, nunca sobre ele.
CriarSlot(gui, x, y, texto, icone, callback, ativo := false, slotW := 110, slotH := 116) {
    lblH   := 20
    pad    := 4
    iconH  := slotH - lblH - (pad * 2)   ; altura do ícone = espaço disponível acima do label
    iconSz := Min(slotW - (pad * 2), iconH)   ; quadrado: menor entre largura e altura disponíveis

    ; Fundo + borda — engloba ícone E label
    slot := gui.AddText("x" x " y" y " w" slotW " h" slotH " Background0x2D2D44 Border")

    ; Ícone centralizado horizontalmente, com padding no topo
    iconX := x + pad + ((slotW - (pad*2) - iconSz) // 2)
    pic := gui.AddPicture("x" iconX " y" (y+pad) " w" iconSz " h" iconSz, icone)

    ; Separador fino entre ícone e label
    sep := gui.AddText("x" (x+1) " y" (y+slotH-lblH-2) " w" (slotW-2) " h1 Background0x6060AA")

    ; Label no rodapé
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
; Altura acompanha o slot via parâmetro slotH
CriarBotaoLateral(gui, x, y, texto, callback, cfgW := 52, slotH := 102) {
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
