#NoTrayIcon
#SingleInstance Force
#Warn
DetectHiddenWindows "Off"
SetWinDelay 100
SetTitleMatchMode 3 ;Exact
SetControlDelay -1
DetectHiddenText "Off"
SendMode "Input"

WindowClass := "#32770"
WindowProcessName := "gwunstal.exe"
WindowTitle := "ahk_class " WindowClass " ahk_exe " WindowProcessName

WinWait WindowTitle
ControlClick "Button1", WindowTitle,,,, "NA"
WinWaitClose WindowTitle

WinWait WindowTitle
ControlClick "Button1", WindowTitle,,,, "NA"

ExitApp
