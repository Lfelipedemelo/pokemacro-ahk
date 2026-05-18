; =====================================================
; ui\config_combo_revive.ahk — Config Combo Revive
; =====================================================

AbrirConfigComboRevive() {
    global cfgAberta
    global txtTeclaInicialCR, txtTeclaFinalCR, txtHotkeyComboCR, txtToggleCR

    if (cfgAberta)
        return
    cfgAberta := true

    IW  := 260
    pad := 14
    W   := IW + pad * 2

    cfg := GetCfg("comboRevive")

    cfgGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
    cfgGui.BackColor := "0x1A1A2E"
    cfgGui.MarginX   := 0
    cfgGui.MarginY   := 0
    cfgGui.OnEvent("Escape", (*) => _FecharConfigCR(cfgGui))
    cfgGui.OnEvent("Close",  (*) => (cfgAberta := false))
    OnMessage(0x201, DragJanela)

    _CabecalhoConfig(cfgGui, W, IW, pad, "CONFIG: COMBO REVIVE", "0xCC0000",
        (*) => ResetarConfigCR(),
        (*) => _FecharConfigCR(cfgGui))

    y := 54

    ; ── Combo ────────────────────────────────────────
    txtTeclaInicialCR := _CampoConfig(cfgGui, pad, y, IW, "BOTÃO INICIAL", "[ " cfg["teclaInicial"] " ]")
    y += 40
    _BtnConfig(cfgGui, pad, y, IW, "DEFINIR BOTÃO INICIAL",
        (*) => CapturarTecla("comboRevive", "teclaInicial", txtTeclaInicialCR, "BOTÃO INICIAL"))

    y += 36 , _Sep(cfgGui, y, W) , y += 10

    txtTeclaFinalCR := _CampoConfig(cfgGui, pad, y, IW, "BOTÃO FINAL", "[ " cfg["teclaFinal"] " ]")
    y += 40
    _BtnConfig(cfgGui, pad, y, IW, "DEFINIR BOTÃO FINAL",
        (*) => CapturarTecla("comboRevive", "teclaFinal", txtTeclaFinalCR, "BOTÃO FINAL"))

    y += 36 , _Sep(cfgGui, y, W) , y += 10

    txtHotkeyComboCR := _CampoConfig(cfgGui, pad, y, IW, "TECLA DO MACRO",
        "[ " StrUpper(cfg["teclaHotkey"]) " ]")
    y += 40
    _BtnConfig(cfgGui, pad, y, IW, "DEFINIR TECLA MACRO",
        (*) => CapturarTecla("comboRevive", "teclaHotkey", txtHotkeyComboCR, "TECLA MACRO"))

    y += 36 , _Sep(cfgGui, y, W) , y += 10

    ; ── Full Attack / Defense ────────────────────────
    faGlobal := cfg["fullAttack"]
    fdGlobal := cfg["fullDefense"]
    usaAtk   := cfg["usarFullAtk"] = "true"
    usaDef   := cfg["usarFullDef"] = "true"

    lbFA := cfgGui.AddText("x" pad " y" y " w" IW " c0xAAAACC",
        "FULL ATTACK (TECLA GLOBAL: [ " StrUpper(faGlobal) " ])")
    lbFA.SetFont("s8 Bold", GF())
    y += 22

    rAtkSim := cfgGui.AddRadio("x" pad       " y" y " w16 h18 Group" (usaAtk  ? " Checked" : ""))
    rAtkNao := cfgGui.AddRadio("x" (pad+130) " y" y " w16 h18"       (!usaAtk ? " Checked" : ""))
    lAS := cfgGui.AddText("x" (pad+20)  " y" (y+1) " w100 h16 c0xF5F5F5 Background0x1A1A2E", "ATIVAR")
    lAS.SetFont("s8", GF())
    lAN := cfgGui.AddText("x" (pad+150) " y" (y+1) " w100 h16 c0xF5F5F5 Background0x1A1A2E", "DESATIVAR")
    lAN.SetFont("s8", GF())
    rAtkSim.OnEvent("Click", (*) => SalvarCfg("comboRevive", "usarFullAtk", "true"))
    rAtkNao.OnEvent("Click", (*) => SalvarCfg("comboRevive", "usarFullAtk", "false"))

    y += 28 , _Sep(cfgGui, y, W) , y += 10

    lbFD := cfgGui.AddText("x" pad " y" y " w" IW " c0xAAAACC",
        "FULL DEFENSE (TECLA GLOBAL: [ " StrUpper(fdGlobal) " ])")
    lbFD.SetFont("s8 Bold", GF())
    y += 22

    rDefSim := cfgGui.AddRadio("x" pad       " y" y " w16 h18 Group" (usaDef  ? " Checked" : ""))
    rDefNao := cfgGui.AddRadio("x" (pad+130) " y" y " w16 h18"       (!usaDef ? " Checked" : ""))
    lDS := cfgGui.AddText("x" (pad+20)  " y" (y+1) " w100 h16 c0xF5F5F5 Background0x1A1A2E", "ATIVAR")
    lDS.SetFont("s8", GF())
    lDN := cfgGui.AddText("x" (pad+150) " y" (y+1) " w100 h16 c0xF5F5F5 Background0x1A1A2E", "DESATIVAR")
    lDN.SetFont("s8", GF())
    rDefSim.OnEvent("Click", (*) => SalvarCfg("comboRevive", "usarFullDef", "true"))
    rDefNao.OnEvent("Click", (*) => SalvarCfg("comboRevive", "usarFullDef", "false"))

    y += 28 , _Sep(cfgGui, y, W) , y += 10

    ; ── Delay Combo (ms) ─────────────────────────────
    lbl := cfgGui.AddText("x" pad " y" y " w" IW " h18 Center c0xAAAACC +0x200",
        "DELAY APÓS REVIVE (MS)")
    lbl.SetFont("s8 Bold", GF())
    y += 22

    editDelay := cfgGui.AddEdit(
        "x" pad " y" y " w" IW " h26 Center Number c0xF5F5F5 Background0x2D2D44 -E0x200",
        cfg["delayCombo"])
    editDelay.SetFont("s10 Bold", GF())
    editDelay.OnEvent("Change", (ctrl, *) => SalvarCfg("comboRevive", "delayCombo", ctrl.Value))

    y += 34 , _SepDest(cfgGui, y, W) , y += 10

    ; ── Toggle Hotkey ────────────────────────────────
    txtToggleCR := _CampoConfig(cfgGui, pad, y, IW, "HOTKEY LIGAR/DESLIGAR",
        "[ " _ComboDisplay(cfg["toggleHotkey"]) " ]")
    y += 40
    _BtnConfig(cfgGui, pad, y, IW, "DEFINIR HOTKEY TOGGLE",
        (*) => CapturarCombo("comboRevive", "toggleHotkey", txtToggleCR, "HOTKEY TOGGLE"))

    y += 38
    cfgGui.AddText("x0 y" y " w" W " h12 Background0x1A1A2E")
    cfgGui.Show("w" W " Center")
}

_FecharConfigCR(cfgGui) {
    global cfgAberta
    cfgAberta := false
    AtualizarHotkeyCombo()
    cfgGui.Destroy()
}

ResetarConfigCR() {
    _CriarGuiConfirmacao(
        "RESETAR COMBO REVIVE?",
        "Esta ação não pode ser desfeita.",
        (g, *) => (ResetarSecao("comboRevive"), _LimparCamposCR(), g.Destroy(), ShowHint("RESETADO!", 1000)),
        (g, *) => g.Destroy()
    )
}

_LimparCamposCR() {
    global txtTeclaInicialCR, txtTeclaFinalCR, txtHotkeyComboCR, txtToggleCR
    try {
        txtTeclaInicialCR.Value := "[ N/A ]"
        txtTeclaFinalCR.Value   := "[ N/A ]"
        txtHotkeyComboCR.Value  := "[ N/A ]"
        txtToggleCR.Value       := "[ N/A ]"
    }
}
