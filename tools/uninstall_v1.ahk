#NoEnv
#NoTrayIcon
#SingleInstance Force
#Warn
DetectHiddenWindows, off
SetWinDelay, 100
SetTitleMatchMode, 3 ;Exact
SetControlDelay, -1
DetectHiddenText, off
SendMode Input

WindowClass = #32770
WindowProcessName = gwunstal.exe
WindowTitle = ahk_class %WindowClass% ahk_exe %WindowProcessName%

WinWait, %WindowTitle%
YesButton = Button1
ControlClick, %YesButton%, %WindowTitle%,,,, NA
WinWaitClose, %WindowTitle%

WinWait, %WindowTitle%
OKButton = Button1
ControlClick, %OKButton%, %WindowTitle%,,,, NA

ExitApp
