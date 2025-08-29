
![WINDOWS TERMINAL](https://github.com/CodeCastor/CodeCastor.WindowsTerminal.Launcher/raw/main/img/anim.gif)

## What ?

This little project is providing functionality for the MSFT TERMNAL.


Right-Click launch terminal in directory
Start a terminal window with ANY combinatio of profile.. CORE / CORE/WINPS CORE/DOS  DOS/GIT

## Setup 

Creates the menu (check source and vaildate ICONS paths)

```
./Setup.ps1
```

#### In your profile script

Add this function:
```
function Get-TerminalStartingDirectory{ 
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $false)]
        [Alias('s', 'set')]
        [switch]$SetLocation
    )    
    $RegPath = "$ENV:OrganizationHKCU\windows.terminal"
    $RegKeyName = 'StartingDirectory'
    $RegKey = (Get-ItemProperty -Path $RegPath -Name $RegKeyName -ErrorAction ignore)

    if($RegKey -ne $null){
        $StartingDirectory = $RegKey.StartingDirectory
    }else {
        $StartingDirectory = $Home
    }
    if($SetLocation) { Set-Location $StartingDirectory; }
    return $StartingDirectory
}
```

And at the very end call this:

```
Get-TerminalStartingDirectory -s
```

#### MSFT TERMINAL Settings.json
Add the profiles defined in the script:
1. Core
2. Git
3. Dos

![Settings.json](https://github.com/CodeCastor/CodeCastor.WindowsTerminal.Launcher/raw/main/MSFT.Terminal.Settings/settings.json)

Repository
----------

https://github.com/cybercastor/Cybercastor.PowerShell.Terminal


