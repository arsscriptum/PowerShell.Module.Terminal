<#̷#̷\
#̷\ 
#̷\   ⼕ㄚ乃㠪尺⼕闩丂ㄒ龱尺 ᗪ㠪ᐯ㠪㇄龱尸爪㠪𝓝ㄒ
#̷\    
#̷\   𝘗𝘰𝘸𝘦𝘳𝘴𝘩𝘦𝘭𝘭 𝘚𝘤𝘳𝘪𝘱𝘵 (𝘤) 𝘣𝘺 <𝘮𝘰𝘤.𝘥𝘶𝘰𝘭𝘤𝘪@𝘳𝘰𝘵𝘴𝘢𝘤𝘳𝘦𝘣𝘺𝘤>
#̷\ 
#̷##>


[CmdletBinding(SupportsShouldProcess)]
Param
(
    [Parameter(Mandatory=$false)]
    [string]$Path,
    [Parameter(Mandatory=$false)]
    [ValidateSet("T1", "T2", "T3", "T1A", "T2A", "T3A", "T1T3", "T1T3A", "T1T2", "T1T2A", "T1T1" ,"Q1" ,"Q2" )]
    [string]$Mode,
    [switch]$Setup
)  


$IsBuilding = Get-BuildingFlag
if($IsBuilding){
    Write-Host "===============================================================================" -f DarkRed
    Write-Host "CURRENTLY BUILDING - BAILING OUT" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed     
    return
}

$Script:GitProfile = 'Git'
$Script:PwshCoreProfile = 'Core'
$Script:DosProfile = 'Dos'
$Script:RegistryPathWinTerminal = "$ENV:OrganizationHKCU\windows.terminal"

function Invoke-Terminal{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
         [Parameter(Mandatory=$false,Position=0)]
         [ValidateSet("T1", "T2", "T3", "T1A", "T2A", "T3A", "T1T3", "T1T3A", "T1T2", "T1T2A", "T1T1" ,"Q1" ,"Q2" )]
         $Mode
    )   
    try{
        if ($PSBoundParameters.ContainsKey('Mode') -eq $False)  {
            $Mode="T1"
        }

        $ExeTerminal="C:\Users\$ENV:USERNAME\AppData\Local\Microsoft\WindowsApps\wt.exe"
        $ExecName = (Get-Item -Path $ExeTerminal).Name
        $ArgumentList = ''
        $Verb = ''
        switch($Mode){

           "T1"         {$Verb = '' ; $ArgumentList = " new-tab -p $PwshCoreProfile"}
           "T2"          {$Verb = '' ; $ArgumentList = " new-tab -p $DosProfile"}
           "T3"        {$Verb = '' ; $ArgumentList = " new-tab -p $GitProfile"}

           "T1A"    {$Verb = 'RunAs' ; $ArgumentList = " new-tab -p $PwshCoreProfile"}
           "T2A"     {$Verb = 'RunAs' ; $ArgumentList = " new-tab -p $DosProfile "}
           "T3A"   {$Verb = 'RunAs' ; $ArgumentList = " new-tab -p $GitProfile "}

           "T1T3"         {$Verb = '' ; $ArgumentList =  " new-tab -p $GitProfile ; split-pane  -H"}
           "T1T3A"   {$Verb = 'RunAs' ; $ArgumentList =  " new-tab -p $GitProfile ; split-pane  -H"}

           "T1T2"           {$Verb = '' ; $ArgumentList =  " new-tab -p $DosProfile ; split-pane -H"}
           "T1T2A"     {$Verb = 'RunAs' ; $ArgumentList =  " new-tab -p $DosProfile ; split-pane -p $DosProfile -H"}


           "T1T1"         {$Verb = '' ; $ArgumentList =  " new-tab -p $PwshCoreProfile ; split-pane  -H"}
           "Q1"            {$Verb = '' ; $ArgumentList = "wt -w _quake -p $PwshCoreProfile"}
           "Q2"            {$Verb = 'Admin' ; $ArgumentList = "wt -w _quake -p $PwshCoreProfile"}
        }

        Write-Host "[TERMINAL] " -f DarkRed -NoNewLine
        Write-Host "$ExecName $ArgumentList" -f DarkYellow
        
        $process = $null
        if($Verb -eq ''){
            $process = Start-Process -FilePath $ExeTerminal -ArgumentList $ArgumentList -PassThru
        }else{
            $process = Start-Process -FilePath $ExeTerminal -ArgumentList $ArgumentList -PassThru -Verb $Verb
        }
    }
    catch{
        Write-Warning $_.Exception
        Write-Warning " Caught an Exception Error: $_"
    }
}



function Setup{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory=$false,Position=0)]
        [string]$Path=""
    )   
    try{

        if($Path -eq ""){
            $Path = (Get-Location).Path
        }
        Write-Host " Setup..."
        if(-not(Test-Path -Path $Script:RegistryPathWinTerminal)){
            New-Item -Path $Script:RegistryPathWinTerminal -Force | out-null
        }
        $SettingsFile = "C:\Users\$ENV:USERNAME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        if((Get-Item -Path $Script:RegistryPathWinTerminal -ErrorAction ignore) -eq $null){
            $null=New-Item -Path $Script:RegistryPathWinTerminal -Value 'PowerShellCore' -Force
        }
        $null=New-ItemProperty -Path $Script:RegistryPathWinTerminal -Name "StartingDirectory" -Value $Path -Force   
        $null=New-ItemProperty -Path $Script:RegistryPathWinTerminal -Name "Settings" -Value $SettingsFile -Force   
        $null=New-ItemProperty -Path $Script:RegistryPathWinTerminal -Name "Single" -Value 'wt new-tab -p $PwshCoreProfile' -Force   
        $null=New-ItemProperty -Path $Script:RegistryPathWinTerminal -Name "Dual" -Value 'new-tab -p $PwshCoreProfile ; split-pane -p $PwshCoreProfile -H;' -Force   
        Write-Host " Done"
        return
       
    }
    catch{
        Write-Warning $_.Exception
        Write-Warning " Caught an Exception Error: $_"
    }
}

if($Setup){
    Set-Location ~
    $p = (pwd).Path
    Setup $p 
    return
}else{
    if($Path -eq ""){
        $Path = (Get-Location).Path
    }

    Write-Host "===============================================================================" -f DarkRed
    Write-Host "WINDOWS TERMINAL" -f DarkYellow;
    Write-Host "===============================================================================" -f DarkRed    
    Write-Host "Path         `t" -NoNewLine -f DarkYellow;  Write-Host "$Path" -f Gray 
    Write-Host "Mode         `t" -NoNewLine -f DarkYellow;  Write-Host "$Mode" -f Gray 
    if((Get-Item -Path $Script:RegistryPathWinTerminal -ErrorAction ignore) -eq $null){
        New-Item -Path $Script:RegistryPathWinTerminal -Value "$Path" -Force
    }

    $null=New-ItemProperty -Path $Script:RegistryPathWinTerminal -Name "StartingDirectory" -Value $Path -Force   
    $null=New-ItemProperty -Path $Script:RegistryPathWinTerminal -Name "UseRegistryStartingDirectory" -Value "1" -Force   

    if(($Mode -ne $Null) -And($Mode -ne '')){
        Invoke-Terminal $Mode    
    }else{
        Invoke-Terminal
    }
    
}

