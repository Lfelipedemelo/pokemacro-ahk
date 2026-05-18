; =====================================================
; lib\hint.ahk — Notificações flutuantes (tema Pokémon)
; =====================================================
;
; Estilo: caixa de diálogo Pokémon
;   Fundo    : azul-noite  0x1A1A2E
;   Borda    : amarelo     0xFFCC00
;   Texto    : branco      0xF5F5F5
;   Fonte    : Courier New Bold (pixel-art feel)

ShowHint(text, time := 1200) {
    static hint := 0
    static tmr  := 0

    if (tmr)
        SetTimer(tmr, 0)

    if IsObject(hint) {
        try hint.Destroy()
    }

    if (text = "")
        return

    hint := Gui("+AlwaysOnTop -Caption +ToolWindow")
    hint.BackColor := "0x1A1A2E"

    ; Faixa amarela no topo (estilo Pokédex)
    hint.AddText("x0 y0 w420 h5 Background0xFFCC00")

    ; Texto principal
    txt := hint.AddText("x0 y5 Center c0xF5F5F5 w420 h44 +0x200", text)
    txt.SetFont("s9 Bold", GF())

    ; Faixa amarela no rodapé
    hint.AddText("x0 y49 w420 h5 Background0xFFCC00")

    hint.Show("AutoSize Center")

    tmr := (*) => hint.Destroy()
    SetTimer(tmr, -time)
}
