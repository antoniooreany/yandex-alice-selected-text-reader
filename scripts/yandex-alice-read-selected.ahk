#Requires AutoHotkey v2.0
#SingleInstance Force

; SETTINGS
BROWSEREXE := "ahk_exe browser.exe"
MAINMENUINDEX := 6
ALTMENUINDEX := 7
CONTEXTMENUOPENDELAYMS := 300
MENUOPENKEYS := "{AppsKey}"
MENUSTEPDELAYMS := 80
BEFOREENTERDELAYMS := 120
DEBUGCONTEXTMENUOPENDELAYMS := 900
DEBUGMENUSTEPDELAYMS := 300
DEBUGBEFOREENTERDELAYMS := 500
NOTIFYHIDEDELAYMS := 1800
HELPHIDEDELAYMS := 5000

; PATHS
SCRIPTDIR := A_ScriptDir
PROJECTROOT := DirExist(SCRIPTDIR "\..") ? SCRIPTDIR "\.." : SCRIPTDIR
LOGDIR := PROJECTROOT "\logs"
LOGFILE := LOGDIR "\ahk-runtime.log"

HELPTEXT := "F8 - show help`n"
    . "F9 - test Alice menu item 6`n"
    . "F10 - test Alice menu item 7`n"
    . "F11 - debug primary Alice flow"

#Include ".\lib\alice-common.ahk"

#HotIf WinActive(BROWSEREXE)

F8::{
    WriteLog("INFO", "Hotkey pressed: F8")
    ShowNotification(HELPTEXT, HELPHIDEDELAYMS)
    KeyWait("F8")
}

F9::{
    WriteLog("INFO", "Hotkey pressed: F9")
    ReadSelectedTextByIndex(MAINMENUINDEX, "F9 / AppsKey menu item 6")
    KeyWait("F9")
}

F10::{
    WriteLog("INFO", "Hotkey pressed: F10")
    ReadSelectedTextByIndex(ALTMENUINDEX, "F10 / AppsKey menu item 7")
    KeyWait("F10")
}

F11::{
    WriteLog("INFO", "Hotkey pressed: F11")
    ReadSelectedTextByIndex(MAINMENUINDEX, "F11 debug / AppsKey menu item 6", GetRunProfile(true))
    KeyWait("F11")
}

#HotIf