; =====================================================
; ui\config_geral.ahk — Configurações Gerais
; =====================================================

global cfgGeralAberta := false

GetFonteAtual() {
    global configFile
    return IniRead(configFile, "Geral", "fonte", "Courier New")
}

GetSleepCombo() {
    global configFile
    return Integer(IniRead(configFile, "Geral", "sleepCombo", "92"))
}

GetUsarPrefixoF() {
    global configFile
    return IniRead(configFile, "Geral", "usarPrefixoF", "true")
}

GetModoLegado() {
    global configFile
    return IniRead(configFile, "Geral", "modoLegado", "false")
}

AplicarFonte(novaFonte) {
    global configFile, myGui, cfgGeralAberta
    IniWrite(novaFonte, configFile, "Geral", "fonte")
    cfgGeralAberta := false
    _ReaplicarInterface()
    AbrirConfigGeral()
}

; Fecha e recria a interface principal com o tema/fonte atual
_ReaplicarInterface() {
    global myGui, cfgGeralAberta
    cfgGeralAberta := false
    if (myGui) {
        SalvarPosicaoJanela()
        myGui.Destroy()
        myGui := 0
    }
    CriarInterface()
}

AbrirConfigGeral() {
    global cfgGeralAberta, configFile

    if (cfgGeralAberta)
        return
    cfgGeralAberta := true

    fonte := GetFonteAtual()
    IW    := 260
    pad   := 14
    W     := IW + pad * 2

    g := Gui("-Caption +ToolWindow +AlwaysOnTop")
    g.BackColor := T()["BG"]
    g.MarginX   := 0
    g.MarginY   := 0
    g.OnEvent("Escape", (*) => (cfgGeralAberta := false, g.Destroy()))
    g.OnEvent("Close",  (*) => (cfgGeralAberta := false))
    OnMessage(0x201, DragJanela)

    ; ── Cabeçalho (sem botão R) ──
    g.AddText("x0 y0 w" W " h8 Background" T()["STRIPE3"])
    lblGeral := g.AddText("x0 y8 w" (W-30) " h32 Center c" T()["ACCENT"] " Background" T()["BG"] " +0x200", "CONFIGURAÇÕES GERAIS")
    lblGeral.SetFont("s8 Bold", fonte)
    bX := g.AddText("x" (W-28) " y11 w22 h22 Center Background" T()["BG2"] " c" T()["TEXT"] " Border +0x200", "X")
    bX.SetFont("s8 Bold", fonte)
    bX.OnEvent("Click", (*) => (cfgGeralAberta := false, g.Destroy()))
    g.AddText("x0 y40 w" W " h1 Background" T()["SEP"])
    y := 60

    ; ── 1. Fonte ──
    lbl1 := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"] "", "FONTE DA INTERFACE:")
    lbl1.SetFont("s8 Bold", fonte)
    y += 22

    fontes   := ["Courier New", "Consolas", "Lucida Console", "Fixedsys"]
    fonteIdx := 1
    for i, n in fontes
        if (n = fonte)
            fonteIdx := i

    ddl := g.AddDropDownList("x" pad " y" y " w" IW " Choose" fonteIdx, fontes)
    ddl.SetFont("s9", fonte)
    ddl.OnEvent("Change", (ctrl, *) => (
        _fs := ctrl.Text,
        g.Destroy(),
        AplicarFonte(_fs)
    ))

    y += 32 , g.AddText("x0 y" y " w" W " h1 Background" T()["SEP"]) , y += 10

    ; ── 2. Tema de Cores ──
    lbl2t := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"], "TEMA DE CORES:")
    lbl2t.SetFont("s8 Bold", fonte)
    y += 22

    temas    := ["Pokédex Vermelho", "Night Blue", "Gold", "Minimal"]
    temaAtual := GetTema()
    temaIdx  := 1
    for i, n in temas
        if (n = temaAtual)
            temaIdx := i

    ddlTema := g.AddDropDownList("x" pad " y" y " w" IW " Choose" temaIdx, temas)
    ddlTema.SetFont("s9", fonte)
    ddlTema.OnEvent("Change", (ctrl, *) => (
        _ts := ctrl.Text,
        IniWrite(_ts, configFile, "Geral", "tema"),
        g.Destroy(),
        _ReaplicarInterface()
    ))

    y += 32 , g.AddText("x0 y" y " w" W " h1 Background" T()["SEP"]) , y += 10

    ; ── 2. Sleep do combo ──
    lbl2 := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"] "", "DELAY ENTRE TECLAS DO COMBO (MS):")
    lbl2.SetFont("s8 Bold", fonte)
    y += 22

    valSleep := g.AddText("x" pad " y" y " w" IW " h22 Center c" T()["TEXT"] " Background" T()["BG2"] " Border",
        "[ " GetSleepCombo() " MS ]")
    valSleep.SetFont("s9 Bold", fonte)
    y += 28

    editSleep := g.AddEdit("x" pad " y" y " w" IW " h26 Center Number c" T()["TEXT"] " Background" T()["BG2"] " -E0x200",
        GetSleepCombo())
    editSleep.SetFont("s10 Bold", fonte)
    editSleep.OnEvent("Change", (ctrl, *) => (
        IniWrite(ctrl.Value, configFile, "Geral", "sleepCombo"),
        valSleep.Value := "[ " ctrl.Value " MS ]"
    ))

    y += 34 , g.AddText("x0 y" y " w" W " h1 Background" T()["SEP"]) , y += 10

    ; ── 3. Prefixo F ──
    lbl3 := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"] "", "USAR PREFIXO [F] NAS TECLAS:")
    lbl3.SetFont("s8 Bold", fonte)
    y += 22

    usarF := GetUsarPrefixoF()

    ; Radios consecutivos
    rSim := g.AddRadio("x" pad              " y" y " w16 h18 Group" (usarF = "true"  ? " Checked" : ""))
    rNao := g.AddRadio("x" (pad+130)        " y" y " w16 h18"       (usarF = "false" ? " Checked" : ""))

    ; Labels depois
    lSim := g.AddText("x" (pad+20)          " y" (y+1) " w100 h16 c" T()["TEXT"] " Background" T()["BG"] "", "SIM  (F1..F9)")
    lSim.SetFont("s8", fonte)
    lNao := g.AddText("x" (pad+150)         " y" (y+1) " w100 h16 c" T()["TEXT"] " Background" T()["BG"] "", "NÃO  (1..9)")
    lNao.SetFont("s8", fonte)

    rSim.OnEvent("Click", (*) => IniWrite("true",  configFile, "Geral", "usarPrefixoF"))
    rNao.OnEvent("Click", (*) => IniWrite("false", configFile, "Geral", "usarPrefixoF"))

    y += 32 , g.AddText("x0 y" y " w" W " h1 Background" T()["SEP"]) , y += 10

    ; ── 4. Modo Legado ──
    lbl4 := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"] "", "MODO LEGADO (REVIVE):")
    lbl4.SetFont("s8 Bold", fonte)
    y += 16
    desc := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"] "", "Ativo: clique direito  |  Inativo: Ctrl+1")
    desc.SetFont("s7", fonte)
    y += 20

    modoLegado := GetModoLegado()

    rLegSim := g.AddRadio("x" pad       " y" y " w16 h18 Group" (modoLegado = "true"  ? " Checked" : ""))
    rLegNao := g.AddRadio("x" (pad+130) " y" y " w16 h18"       (modoLegado = "false" ? " Checked" : ""))

    lLegSim := g.AddText("x" (pad+20)  " y" (y+1) " w100 h16 c" T()["TEXT"] " Background" T()["BG"] "", "ATIVO")
    lLegSim.SetFont("s8", fonte)
    lLegNao := g.AddText("x" (pad+150) " y" (y+1) " w100 h16 c" T()["TEXT"] " Background" T()["BG"] "", "INATIVO")
    lLegNao.SetFont("s8", fonte)

    rLegSim.OnEvent("Click", (*) => IniWrite("true",  configFile, "Geral", "modoLegado"))
    rLegNao.OnEvent("Click", (*) => IniWrite("false", configFile, "Geral", "modoLegado"))

    y += 32 , g.AddText("x0 y" y " w" W " h1 Background" T()["SEP"]) , y += 10

    ; ── 5. Full Attack ──
    lbl5 := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"] "", "TECLA FULL ATTACK (GLOBAL):")
    lbl5.SetFont("s8 Bold", fonte)
    y += 22

    faVal := IniRead(configFile, "Geral", "fullAttack", "N/A")
    txtFullAtkGeral := g.AddText("x" pad " y" y " w" IW " h22 Center c" T()["TEXT"] " Background" T()["BG2"] " Border",
        "[ " StrUpper(faVal) " ]")
    txtFullAtkGeral.SetFont("s9 Bold", fonte)
    y += 28
    bFA := g.AddText("x" pad " y" y " w" IW " h30 Background" T()["BG2"] " Border Center +0x200 c" T()["ACCENT"] "",
        "▶ DEFINIR FULL ATTACK")
    bFA.SetFont("s8 Bold", fonte)
    bFA.OnEvent("Click", (*) => CapturarTecla("Geral", "fullAttack", txtFullAtkGeral, "FULL ATTACK"))

    y += 36 , g.AddText("x0 y" y " w" W " h1 Background" T()["SEP"]) , y += 10

    ; ── 6. Full Defense ──
    lbl6 := g.AddText("x" pad " y" y " w" IW " c" T()["MUTED"] "", "TECLA FULL DEFENSE (GLOBAL):")
    lbl6.SetFont("s8 Bold", fonte)
    y += 22

    fdVal := IniRead(configFile, "Geral", "fullDefense", "N/A")
    txtFullDefGeral := g.AddText("x" pad " y" y " w" IW " h22 Center c" T()["TEXT"] " Background" T()["BG2"] " Border",
        "[ " StrUpper(fdVal) " ]")
    txtFullDefGeral.SetFont("s9 Bold", fonte)
    y += 28
    bFD := g.AddText("x" pad " y" y " w" IW " h30 Background" T()["BG2"] " Border Center +0x200 c" T()["ACCENT"] "",
        "▶ DEFINIR FULL DEFENSE")
    bFD.SetFont("s8 Bold", fonte)
    bFD.OnEvent("Click", (*) => CapturarTecla("Geral", "fullDefense", txtFullDefGeral, "FULL DEFENSE"))

    y += 36
    g.AddText("x0 y" y " w" W " h16 Background" T()["BG"] "")
    g.Show("w" W " Center")
}
