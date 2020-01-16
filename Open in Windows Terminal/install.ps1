# Require admin
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$lines = @'
# Below code is for context menu handling
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
# If it's Windows Terminal session
if($env:WT_SESSION.Length -gt 0) {
    # If not admin
    if(!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "In Terminal not admin"
        Start-Process shell:appsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App -Verb RunAs
        $Host.SetShouldExit(0)
    }
    else {
        if(Test-Path -Path $env:TEMP\windows_terminal_current_dir.temp -PathType Leaf) {
            $destination = Get-Content $env:TEMP\windows_terminal_current_dir.temp -First 1
            if((Get-Item $destination -ea 0) -is [IO.FileInfo]) {
                $destination = Split-Path $destination
            }
            Set-Location -Path $destination
            Remove-Item -Path $env:TEMP\windows_terminal_current_dir.temp -Force
        }
    }
}
'@

if((Get-Item $PROFILE -ea 0) -isnot [IO.FileInfo]) {
    New-Item $PROFILE -Type File
}

Add-Content -Path $PROFILE -Value $lines