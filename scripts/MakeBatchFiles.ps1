

<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



function New-StartupBatchFile{
    [CmdletBinding(SupportsShouldProcess)]
    param (
     [parameter(Position=0,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Path,
     [parameter(Position=1,Mandatory=$true)]
     [ValidateNotNullOrEmpty()]$Mode
    )  
    try{
        $command = @"

        `$StartPath = Get-TerminalStartingDirectory -SetLocation
        if([string]::IsNullOrEmpty(`$ENV:LaunchPath) -eq `$False){
            `$StartPath =  `$ENV:LaunchPath
        }
        `$script = `"C:\DOCUMENTS\PowerShell\Module-Development\PowerShell.Module.Terminal\src\Terminal.ps1`"
        &`"`$script`" -Path `"`$StartPath`" -Mode $Mode

"@


        $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        $BatchCommand = "pwsh -nol -encodedcommand $encodedCommand"

        $BatchScript = @"
@echo off
set LaunchPath=%1
$BatchCommand
"@

        Set-Content "$Path" -Value $BatchScript
        Write-Output "$Path"
  
    }catch{
        Show-ExceptionDetails $_
    }
    
}

New-StartupBatchFile "$PSScriptRoot\StartPwsh.bat" "T1A"
New-StartupBatchFile "$PSScriptRoot\StartPwshAdmin.bat" "T1A"
New-StartupBatchFile "$PSScriptRoot\StartCmdAdmin.bat" "T2A"
New-StartupBatchFile "$PSScriptRoot\StartCmd.bat" "T2"
New-StartupBatchFile "$PSScriptRoot\StartDual.bat" "T1T1"
New-StartupBatchFile "$PSScriptRoot\StartQuake.bat" "Q1"