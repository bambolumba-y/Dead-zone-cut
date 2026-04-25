#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook
InstallKeybdHook()

; =========================
; SETTINGS
; =========================
global CutPixels := 175
global NewBottom := A_ScreenHeight - CutPixels

; Crop/zoom mode:
; The game gets a normal 16:9 window, full screen width, so it does not add side bars.
; Top crop keeps the top visible. Bottom crop keeps the bottom above the dead zone.
global CropOffsetY := 0
global CropNudgeStep := 20
global GameAspectW := 16
global GameAspectH := 9
global LastCropAnchor := "top"

global SavedStyles := Map()
global SavedPlacements := Map()
global OriginalWorkArea := Buffer(16, 0)

; =========================
; INIT
; =========================

if !A_IsAdmin {
    try {
        Run('*RunAs "' A_ScriptFullPath '"')
        ExitApp()
    }
}

DllCall("SystemParametersInfo", "UInt", 0x30, "UInt", 0, "Ptr", OriginalWorkArea, "UInt", 0)
SetCustomWorkArea()
OnExit(RestoreWorkArea)

; =========================
; HOTKEYS
; =========================

; Normal mode: the window exactly fits the safe visible area.
^!f::ApplyFitMode()
^!F12::ApplyFitMode()

; Crop/zoom modes: full width without side bars for games that lock aspect ratio.
^!c::ApplyCropTopMode()
^!F11::ApplyCropTopMode()
^!+c::ApplyCropBottomMode()

; Move the cropped picture after crop/zoom mode.
^!PgUp::NudgeCrop(-CropNudgeStep)
^!PgDn::NudgeCrop(CropNudgeStep)
^!+PgUp::NudgeCrop(-(CropNudgeStep * 3))
^!+PgDn::NudgeCrop(CropNudgeStep * 3)

; Restore active window or the Windows work area.
^!r::RestoreActiveWindow()
^!+r::RestoreActiveWindow()
^!w::RestoreWorkAreaHotkey()
^!+w::RestoreWorkAreaHotkey()

MsgBox(
    "Dead Zone Cut is ready.`n`n"
    . "Cut from bottom: " CutPixels " px.`n`n"
    . "Hotkeys:`n"
    . "Ctrl + Alt + F: fit safe area`n"
    . "Ctrl + Alt + F12: fit safe area, backup`n"
    . "Ctrl + Alt + C: crop/zoom, keep top visible`n"
    . "Ctrl + Alt + F11: crop/zoom, keep top visible, backup`n"
    . "Ctrl + Alt + Shift + C: crop/zoom, keep bottom safe`n"
    . "Ctrl + Alt + PgUp/PgDn: move cropped picture`n"
    . "Ctrl + Alt + R: restore active window`n"
    . "Ctrl + Alt + W: restore work area",
    "Dead Zone Cut"
)

; =========================
; WINDOW MODES
; =========================

ApplyFitMode() {
    global NewBottom

    active_id := PrepareActiveWindow()
    if !active_id
        return

    hwnd := "ahk_id " active_id
    WinMove(0, 0, A_ScreenWidth, NewBottom, hwnd)

    SoundBeep(750, 200)
    ShowTip("Fit mode applied")
}

ApplyCropTopMode() {
    ApplyCropMode("top")
}

ApplyCropBottomMode() {
    ApplyCropMode("bottom")
}

ApplyCropMode(anchor := "") {
    global NewBottom, CropOffsetY, GameAspectW, GameAspectH, LastCropAnchor

    active_id := PrepareActiveWindow()
    if !active_id
        return

    hwnd := "ahk_id " active_id
    if anchor = ""
        anchor := LastCropAnchor
    LastCropAnchor := anchor

    ; Use a normal game aspect ratio. On a 1920x1080 monitor this creates
    ; 1920x1080 for full-width 16:9 games.
    targetW := A_ScreenWidth
    targetH := Round(targetW * GameAspectH / GameAspectW)

    if anchor = "bottom" {
        ; Keep the bottom of the game inside the safe area.
        targetY := NewBottom - targetH + CropOffsetY
    } else {
        ; Keep the top of the game visible and crop the bottom instead.
        targetY := CropOffsetY
    }

    WinMove(0, targetY, targetW, targetH, hwnd)

    SoundBeep(900, 200)
    ShowTip(anchor = "bottom" ? "Crop/zoom bottom-safe mode applied" : "Crop/zoom top-safe mode applied")
}

NudgeCrop(deltaY) {
    global CropOffsetY

    CropOffsetY += deltaY
    ApplyCropMode()
}

PrepareActiveWindow() {
    global SavedStyles, SavedPlacements

    active_id := WinGetID("A")
    if !active_id
        return 0

    hwnd := "ahk_id " active_id

    if !SavedStyles.Has(active_id) {
        SavedStyles[active_id] := WinGetStyle(hwnd)
        WinGetPos(&x, &y, &w, &h, hwnd)
        SavedPlacements[active_id] := {x: x, y: y, w: w, h: h}
    }

    try WinRestore(hwnd)

    ; Remove caption and thick frame.
    WinSetStyle("-0xC40000", hwnd)
    RefreshFrame(active_id)

    return active_id
}

RestoreActiveWindow() {
    global SavedStyles, SavedPlacements

    active_id := WinGetID("A")
    if !active_id
        return

    hwnd := "ahk_id " active_id

    if SavedStyles.Has(active_id) {
        DllCall("SetWindowLongPtr", "Ptr", active_id, "Int", -16, "Ptr", SavedStyles[active_id], "Ptr")
        RefreshFrame(active_id)

        if SavedPlacements.Has(active_id) {
            p := SavedPlacements[active_id]
            WinMove(p.x, p.y, p.w, p.h, hwnd)
        }

        SoundBeep(500, 200)
        ShowTip("Window restored")
    }
}

RefreshFrame(hwnd) {
    DllCall("SetWindowPos"
        , "Ptr", hwnd
        , "Ptr", 0
        , "Int", 0
        , "Int", 0
        , "Int", 0
        , "Int", 0
        , "UInt", 0x0027)
}

; =========================
; WORK AREA
; =========================

RestoreWorkAreaHotkey() {
    RestoreWorkArea()
    SoundBeep(600, 200)
    ShowTip("Work area restored")
}

SetCustomWorkArea() {
    global NewBottom

    rect := Buffer(16, 0)
    NumPut("Int", 0, rect, 0)
    NumPut("Int", 0, rect, 4)
    NumPut("Int", A_ScreenWidth, rect, 8)
    NumPut("Int", NewBottom, rect, 12)

    DllCall("SystemParametersInfo", "UInt", 0x2F, "UInt", 0, "Ptr", rect, "UInt", 0x02)
}

RestoreWorkArea(*) {
    global OriginalWorkArea

    DllCall("SystemParametersInfo", "UInt", 0x2F, "UInt", 0, "Ptr", OriginalWorkArea, "UInt", 0x02)
}

; =========================
; UI
; =========================

ShowTip(text) {
    ToolTip(text)
    SetTimer(HideTip, -1200)
}

HideTip(*) {
    ToolTip()
}
