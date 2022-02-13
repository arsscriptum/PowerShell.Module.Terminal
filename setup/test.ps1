



#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host " Launching in Admin mode" -f DarkRed
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$a1 = $args[0]
$Script:CurrentPath = $PSScriptRoot

Write-Host "===============================================================================" -f DarkRed
Write-Host "SETUP of WINDOWS TERMINAL EXPLORER CONTEXTUAL MENU " -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed    
Write-Host "Current Path `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:CurrentPath" -f Gray 
Write-Host "TermScript   `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:TermScript" -f Gray 
Write-Host "WhatIf       `t" -NoNewLine -f DarkYellow;  Write-Host "$a1" -f Gray 
Write-Host "Uninstall    `t" -NoNewLine -f DarkYellow;  Write-Host "$Uninstall" -f Gray 
Write-Host "Path         `t" -NoNewLine -f DarkYellow;  Write-Host "$Path" -f Gray 
Write-Host "Mode         `t" -NoNewLine -f DarkYellow;  Write-Host "$Mode" -f Gray 
Sleep 40