; =====================================================
; ui\gui_main.ahk — Interface principal (tema Pokémon)
; =====================================================

CriarInterface() {
    global myGui, macros, icons, uiRefs

    uiRefs := Map()

    myGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
    myGui.BackColor := "0x1A1A2E"
    myGui.MarginX   := 0
    myGui.MarginY   := 0

    myGui.OnEvent("Escape", (*) => (SalvarPosicaoJanela(), myGui.Destroy(), myGui := 0))
    myGui.OnEvent("Close",  (*) => (SalvarPosicaoJanela(), myGui := 0))

    OnMessage(0x200, MouseMoveHandler)
    OnMessage(0x201, DragJanela)

    ; ── Dimensões ──
    pad   := 12
    slotW := 110
    cfgW  := 52
    gap   := 6
    W     := pad + slotW + gap + cfgW + pad   ; = 192

    ; ── Faixa tricolor ──
    faixaH := 8
    w1 := W * 58 // 100
    w2 := W * 20 // 100
    w3 := W - w1 - w2
    myGui.AddText("x0 y0 w" w1 " h" faixaH " Background0xCC0000")
    myGui.AddText("x" w1 " y0 w" w2 " h" faixaH " Background0xFFCC00")
    myGui.AddText("x" (w1+w2) " y0 w" w3 " h" faixaH " Background0x3B4CCA")

    ; ── Barra de título ──
    tituloH := 28
    btnW    := 22
    btnH    := 20
    btnY    := faixaH + (tituloH - btnH) // 2

    ; Título ocupa tudo menos os 2 botões
    titulo := myGui.AddText(
        "x0 y" faixaH " w" (W - btnW*2 - 4) " h" tituloH
        " Center c0xFFCC00 Background0x1A1A2E +0x200", "✦ POKÉMACRO ✦")
    titulo.SetFont("s8 Bold", GF())

    ; ⚙ e X colados à direita, terminando em W
    btnGear := myGui.AddText(
        "x" (W - btnW*2 - 12) " y" btnY " w" btnW " h" btnH
        " Center Background0x2D2D44 Border c0xAAAACC +0x200", "⚙")
    btnGear.SetFont("s9 Bold", GF())
    btnGear.OnEvent("Click", (*) => AbrirConfigGeral())

    btnClose := myGui.AddText(
        "x" (W - btnW - 8) " y" btnY " w" btnW " h" btnH
        " Center Background0x2D2D44 Border cF5F5F5 +0x200", "X")
    btnClose.SetFont("s8 Bold", GF())
    btnClose.OnEvent("Click", (*) => (SalvarPosicaoJanela(), myGui.Destroy(), myGui := 0))

    y := faixaH + tituloH + 4
    myGui.AddText("x0 y" y " w" W " h1 Background0x6060AA")
    y += 6

    ; ── Linhas de macro ──
    CriarLinha(nome, label, icone, cfgCallback) {
        uiRefs[nome] := CriarSlot(
            myGui, pad, y, label, icone,
            (ctrl, *) => ToggleMacro(nome, ctrl),
            macros[nome], slotW, 116)

        CriarBotaoLateral(myGui, pad + slotW + gap, y,
            "⚙ CFG", cfgCallback, cfgW, 116)

        y += 116 + 8
        myGui.AddText("x0 y" y " w" W " h1 Background0x6060AA")
        y += 6
    }

    CriarLinha("comboPrincipal",  "Combo Principal",  icons["comboPrincipal"],
        (*) => AbrirConfigCombo("comboPrincipal"))
    CriarLinha("comboSecundario", "Combo Secundário",     icons["comboSecundario"],
        (*) => AbrirConfigCombo("comboSecundario"))
    CriarLinha("revive",          "Revive",          icons["revive"],
        (*) => AbrirTelaConfigRevive("revive"))
    CriarLinha("comboRevive",     "Combo Revive",   icons["comboRevive"],
        (*) => AbrirConfigComboRevive())
    CriarLinha("cooldown",        "Cooldown",        icons["cooldown"],
        (*) => AbrirConfigCooldown())

    ; ── Rodapé ──
    rodape := myGui.AddText(
        "x0 y" y " w" W " h22 Center c0x6060AA Background0x1A1A2E",
        "CTRL+F12  FECHAR")
    rodape.SetFont("s8 Bold", GF())

    pos := CarregarPosicaoJanela()
    myGui.Show("w" W " " pos)
}
