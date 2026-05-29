; =====================================================
; ui\gui_main.ahk — Interface principal
; =====================================================

; Retorna apenas a tecla do macro para exibir no slot
_KeyHint(tipo) {
    cfg := GetCfg(tipo)
    hk  := cfg["teclaHotkey"]
    if (hk = "N/A" || hk = "")
        return ""
    return "[" StrUpper(hk) "]"
}

_KeyHintCooldown() {
    cfg := GetCfg("Cooldown")
    hk  := cfg["hotkeyCooldown"]
    return (hk != "N/A" && hk != "") ? "[" StrUpper(hk) "]" : ""
}

CriarInterface() {
    global myGui, macros, icons, uiRefs, modoCompacto

    uiRefs := Map()

    myGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
    myGui.BackColor := T()["BG"]
    myGui.MarginX   := 0
    myGui.MarginY   := 0

    myGui.OnEvent("Escape", (*) => (SalvarPosicaoJanela(), myGui.Destroy(), myGui := 0))
    myGui.OnEvent("Close",  (*) => (SalvarPosicaoJanela(), myGui := 0))

    OnMessage(0x201, DragJanela)

    ; ── Dimensões ──
    pad   := 12
    slotW := 110
    cfgW  := 52
    gap   := 6
    W     := pad + slotW + gap + cfgW + pad
    slotH := modoCompacto ? 42 : 116

    ; ── Faixa tricolor ──
    faixaH := 8
    w1 := W * 58 // 100
    w2 := W * 20 // 100
    w3 := W - w1 - w2
    myGui.AddText("x0 y0 w" w1          " h" faixaH " Background" T()["STRIPE1"])
    myGui.AddText("x" w1 " y0 w" w2     " h" faixaH " Background" T()["STRIPE2"])
    myGui.AddText("x" (w1+w2) " y0 w" w3 " h" faixaH " Background" T()["STRIPE3"])

    ; ── Barra de título ──
    tituloH := 28
    btnW    := 22
    btnH    := 20
    btnY    := faixaH + (tituloH - btnH) // 2

    titulo := myGui.AddText(
        "x0 y" faixaH " w" (W - btnW*3 - 6) " h" tituloH
        " Center c" T()["ACCENT"] " Background" T()["BG"] " +0x200",
        "✦ POKÉMACRO ✦")
    titulo.SetFont("s8 Bold", GF())

    btnCompact := myGui.AddText(
        "x" (W - btnW*3 - 4) " y" btnY " w" btnW " h" btnH
        " Center Background" T()["BG2"] " Border c" T()["MUTED"] " +0x200",
        modoCompacto ? "↓" : "↑")
    btnCompact.SetFont("s9 Bold", GF())
    btnCompact.OnEvent("Click", (*) => _ToggleCompacto())

    btnGear := myGui.AddText(
        "x" (W - btnW*2 - 2) " y" btnY " w" btnW " h" btnH
        " Center Background" T()["BG2"] " Border c" T()["MUTED"] " +0x200", "⚙")
    btnGear.SetFont("s9 Bold", GF())
    btnGear.OnEvent("Click", (*) => AbrirConfigGeral())

    btnClose := myGui.AddText(
        "x" (W - btnW) " y" btnY " w" btnW " h" btnH
        " Center Background" T()["BG2"] " Border c" T()["TEXT"] " +0x200", "X")
    btnClose.SetFont("s8 Bold", GF())
    btnClose.OnEvent("Click", (*) => (SalvarPosicaoJanela(), myGui.Destroy(), myGui := 0))

    y := faixaH + tituloH + 4
    myGui.AddText("x0 y" y " w" W " h1 Background" T()["SEP"])
    y += 6

    ; ── Linhas de macro ──
    CriarLinha(nome, label, icone, cfgCallback, keyHintFn) {
        hint := keyHintFn()
        uiRefs[nome] := CriarSlot(
            myGui, pad, y, label, icone,
            (ctrl, *) => ToggleMacro(nome, ctrl),
            macros[nome], slotW, slotH, hint)
        CriarBotaoLateral(myGui, pad + slotW + gap, y,
            "⚙`nCFG", cfgCallback, cfgW, slotH)
        y += slotH + 8
        myGui.AddText("x0 y" y " w" W " h1 Background" T()["SEP"])
        y += 6
    }

    CriarLinha("comboPrincipal",  "COMBO`nPRINC.",  icons["comboPrincipal"],
        (*) => AbrirConfigCombo("comboPrincipal"),
        () => _KeyHint("comboPrincipal"))
    CriarLinha("comboSecundario", "COMBO`nSEC.",     icons["comboSecundario"],
        (*) => AbrirConfigCombo("comboSecundario"),
        () => _KeyHint("comboSecundario"))
    CriarLinha("comboRevive",     "COMBO`nREVIVE",   icons["comboRevive"],
        (*) => AbrirConfigComboRevive(),
        () => _KeyHint("comboRevive"))
    CriarLinha("revive",          "REVIVE",          icons["revive"],
        (*) => AbrirTelaConfigRevive("revive"),
        () => _KeyHint("revive"))
    CriarLinha("cooldown",        "COOLDOWN",        icons["cooldown"],
        (*) => AbrirConfigCooldown(),
        () => _KeyHintCooldown())

    ; ── Rodapé ──
    if (!modoCompacto) {
        rodape := myGui.AddText(
            "x0 y" y " w" W " h22 Center c" T()["MUTED"] " Background" T()["BG"],
            "CTRL+F12  FECHAR")
        rodape.SetFont("s8 Bold", GF())
    }

    pos := CarregarPosicaoJanela()
    myGui.Show("w" W " " pos)
}

_ToggleCompacto() {
    global modoCompacto, myGui
    modoCompacto := !modoCompacto
    SalvarPosicaoJanela()
    myGui.Destroy()
    myGui := 0
    CriarInterface()
}
