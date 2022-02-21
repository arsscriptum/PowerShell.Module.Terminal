

[CmdletBinding(SupportsShouldProcess)]
param (
      [Parameter(Mandatory = $false)]
      [switch]$Uninstall
    )

function Remove-OldValues
{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    try {
        Write-Host "Cleaning up..."
        $RegistryPath = "HKCU:\SOFTWARE\Classes\Directory\shell\Custom Shell Commands"
        $null=Remove-Item -Path $RegistryPath  -Force -EA Ignore | Out-Null
       
        $Commands = InitializeCommands 'nul'
        ForEach( $cmd in $Commands){
            $CommandPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\{0}\command' -f $cmd.Name
            $exec=$cmd.Command
            
            $ShellCmdPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\{0}' -f $cmd.Name
            $null=Remove-Item -Path "$ShellCmdPath" -Force -Recurse -ErrorAction Ignore
        }
        For( $i=0 ; $i -lt 12 ; $i++){
             $name ="ShellCmd" + "$i"
             $ShellCmdPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\{0}' -f $cmd.Name
             $null=Remove-Item -Path "$ShellCmdPath" -Force -Recurse -ErrorAction Ignore
         }
    }
    catch{
        Write-Warning $_.Exception
        Write-Warning " Caught an Exception Error: $_"
    }
   
}

function New-SubCommand{
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Position=0,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Name,
     [parameter(Position=1,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Icon,
     [parameter(Position=2,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Verb,
     [parameter(Position=3,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Command,
     [parameter(Mandatory=$false)]
     [switch]$Separator
    )  
    try{
        $Exists = Test-Path $Icon -PathType Leaf
        if($Exists -eq $False) {throw "bad ico file $Icon"}
        $Command=[PSCustomObject]@{
                Name = $Name
                Icon = $Icon
                MUIVerb = $verb
                Command = $Command
                Separator = $false
            }  
   
        return $Command    
    }catch{
        Show-ExceptionDetails $_
    }
    
}
function New-Separator{
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Position=0,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Name
    )
    $Command=[PSCustomObject]@{
            Name = $Name
            Icon = ''
            MUIVerb = ''
            Command = ''
            Separator = $true
        }  


    return $Command
}


function InitializeCommands{

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Position=0,Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$InvokeTermScript
    ) 
    $ValueCmd="pwsh.exe -w Minimized -nol -nop -c `"& { Start-Process -FilePath `"pwsh.exe`" -ArgumentList ' -w Minimized -nol -nop -c `"& { $InvokeTermScript"
    
    write-host "InitializeCommands`nCmd: $ValueCmd " -f DarkBlue
    $IconPath = "C:\DOCUMENTS\PowerShell\Module-Development\PowerShell.Module.Terminal\ico"
    $Index = 1
    $TerminalCommands = [System.Collections.ArrayList]::new()
    write-verbose "Initialize-Commands";
    $Cmd = New-SubCommand "ShellCmd$Index" "$IconPath\Terminal.ico" "PowerShell Core Here" "$ValueCmd -Path `"%1`" -Mode T1;}`"' }`""
    $null = $TerminalCommands.Add($Cmd) ; $Index++
    $Cmd = New-SubCommand "ShellCmd$Index" "$IconPath\blackfolderterm.ico" "Command Promt Here" "$ValueCmd -Path `"%1`" -Mode T2;}`"' }`""
    $null = $TerminalCommands.Add($Cmd) ; $Index++
    $sep = New-Separator "ShellCmd$Index" ; $null = $TerminalCommands.Add($sep) ; $Index++
    $Cmd = New-SubCommand "ShellCmd$Index" "$IconPath\Administrator.ico" "PowerShell Core Admin" "$ValueCmd -Path `"%1`" -Mode T1A;}`"' }`""
    $null = $TerminalCommands.Add($Cmd) ; $Index++
    $Cmd = New-SubCommand "ShellCmd$Index" "$IconPath\Dos-black-red.ico" "Command Promt Admin" "$ValueCmd -Path `"%1`" -Mode T2A;}`"' }`""
    $null = $TerminalCommands.Add($Cmd) ; $Index++
   $sep = New-Separator "ShellCmd$Index" ; $null = $TerminalCommands.Add($sep) ; $Index++
    $Cmd = New-SubCommand "ShellCmd$Index" "$IconPath\blackfolderterm.ico" "PWSH Core / Cmd Prompt" "$ValueCmd -Path `"%1`" -Mode T1T2;}`"' }`""
    $null = $TerminalCommands.Add($Cmd) ; $Index++
    $Cmd = New-SubCommand "ShellCmd$Index" "$IconPath\Superuser-ice.ico" "DUAL CORE" "$ValueCmd -Path `"%1`" -Mode T1T1;}`"' }`"" 
    $null = $TerminalCommands.Add($Cmd) ; $Index++
   $sep = New-Separator "ShellCmd$Index" ; $null = $TerminalCommands.Add($sep) ; $Index++
    $Cmd = New-SubCommand "ShellCmd$Index" "$IconPath\Terminal-Wooden.ico" "PSCore Quake" "$ValueCmd `"%1`" Q1;}`"' }`""
    $null = $TerminalCommands.Add($Cmd) ; $Index++

    return $TerminalCommands
}

function CreateMenu
{
    [CmdletBinding(SupportsShouldProcess)]
    param (
         [parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [string]$SubCommands,
         [parameter(Mandatory=$false)]
         [ValidateNotNull()]
         [string]$Verb,
         [parameter(Mandatory=$false)]
         [ValidateNotNull()]
         [string]$Icon
    )
    try {
        write-verbose "Create-Menu";
        
        $RegistryPath = "HKCU:\SOFTWARE\Classes\Directory\shell\Custom Shell Commands"
        $null=New-Item -Path $RegistryPath  -Force | Out-Null
        $null=New-RegistryValue $RegistryPath "Icon" $Icon String
        $null=New-RegistryValue $RegistryPath "MUIVerb" $Verb String
        $null=New-RegistryValue $RegistryPath "SubCommands" "$SubCommands" String
    }

    catch {
       write-error "CreateMenu error $_"
        return $null
      
    }
}

function CreateCommands{
        [CmdletBinding(SupportsShouldProcess)]
        param (
             [parameter(Position=0,Mandatory=$true)]
             [ValidateNotNullOrEmpty()]$InvokeTermScript
        ) 
   
    Write-verbose "adding submenus" 
    $RegKeyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell'
    $Commands = InitializeCommands $InvokeTermScript
    $SubCommand = "" ; $First = $true

    ForEach( $cmd in $Commands){
        $Name = $cmd.Name
        Write-verbose " add cmd $Name; "
         if($First) { $First = $False; $SubCommands += "$Name" }else{$SubCommands += ";$Name"}
    }
    write-host "Create-Commands";
    ForEach( $cmd in $Commands){
         $Name = $cmd.Name
        write-host -n -f DarkYellow "Adding $Name ... ";
        $CommandPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\{0}\command' -f $cmd.Name
        $exec=$cmd.Command
        
        $ShellCmdPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\{0}' -f $cmd.Name
        $AddSeparator = $cmd.Separator
       
        $verb = $cmd.MUIVerb
        $ico = $cmd.Icon
        Write-verbose "$ShellCmdPath" 
        Write-verbose "$CommandPath" 
        $null=New-Item -Path $ShellCmdPath -Value "-" -Force
        $null=New-Item -Path $CommandPath -Value "$exec" -Force 
         if($AddSeparator){$null=New-RegistryValue $ShellCmdPath "CommandFlags" 00000040 dword ; continue ;}
        $null=New-RegistryValue $ShellCmdPath "Icon" $ico String
        $null=New-RegistryValue $ShellCmdPath "MUIVerb" $verb String
        write-host -f DarkGreen "ok";
    }

    CreateMenu -SubCommands "$SubCommands" -Verb "Windows &Terminal" -Icon "C:\DOCUMENTS\PowerShell\Module-Development\PowerShell.Module.Terminal\ico\WOOD-TERMINAL.ico" 
}


#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host " Launching in Admin mode" -f DarkRed
    Start-Process pwsh.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

$Script:CurrentPath=$PSScriptRoot
$Script:TermScript = (Resolve-Path -Path "$Script:CurrentPath\..\src\Terminal.ps1").Path
if(-not(Test-Path -Path $Script:TermScript)){
    write-error "cannot find script 'Terminal.ps1'"
    return
}

Write-Host "===============================================================================" -f DarkRed
Write-Host "SETUP of WINDOWS TERMINAL EXPLORER CONTEXTUAL MENU " -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed    
Write-Host "Current Path `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:CurrentPath" -f Gray 
Write-Host "TermScript   `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:TermScript" -f Gray 
Write-Host "WhatIf       `t" -NoNewLine -f DarkYellow;  Write-Host "$WhatIf" -f Gray 
Write-Host "Uninstall    `t" -NoNewLine -f DarkYellow;  Write-Host "$Uninstall" -f Gray 
Write-Host "Path         `t" -NoNewLine -f DarkYellow;  Write-Host "$Path" -f Gray 
Write-Host "Mode         `t" -NoNewLine -f DarkYellow;  Write-Host "$Mode" -f Gray 

Remove-OldValues 

if($Uninstall){
    Write-Host "Uninstall Completed, exiting." -f DarkYellow
    return
}
Write-Host "Starting configuration" -f DarkYellow
CreateCommands $TermScript
Write-Host "DONE" -f DarkGreen

Read-Host 'Install Completed, Press Any key...'
