# Require admin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$windows_terminal_path = Get-Command "C:\Program Files\WindowsApps\Microsoft.WindowsTerminal*\WindowsTerminal.exe" -ea 0 | Select-Object -ExpandProperty Source
if ($windows_terminal_path -eq $null)
{
    Write-Host "Can't find WindowsTerminal.exe"
    return
}

$registry = @'
Windows Registry Editor Version 5.00

; Note you must write elevate's full path and escape \ and "
; show in context menu when right click all kinds files
[HKEY_CLASSES_ROOT\*\shell\WindowsTerminal]
@="Open Windows Terminal"
"Icon"="windows_terminal_path,0"

[HKEY_CLASSES_ROOT\*\shell\WindowsTerminal\command]
@="powershell -Command \"Add-Content -Path \"$env:TEMP\\windows_terminal_current_dir.temp\" -Value \\\"\"%V\"\\\"; Start-Process shell:appsFolder\\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App\""

; show in context menu when right click empty area of explorer
[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal]
@="Open Windows Terminal"
"Icon"="windows_terminal_path,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal\command]
@="powershell -Command \"Add-Content -Path \"$env:TEMP\\windows_terminal_current_dir.temp\" -Value \\\"\"%V\"\\\"; Start-Process shell:appsFolder\\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App\""

; show in context menu when right click directory
[HKEY_CLASSES_ROOT\Directory\shell\WindowsTerminal]
@="Open Windows Terminal"
"Icon"="windows_terminal_path,0"

[HKEY_CLASSES_ROOT\Directory\shell\WindowsTerminal\command]
@="powershell -Command \"Add-Content -Path \"$env:TEMP\\windows_terminal_current_dir.temp\" -Value \\\"\"%V\"\\\"; Start-Process shell:appsFolder\\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App\""
'@
$registry = $registry -replace "windows_terminal_path", ($windows_terminal_path -replace "\\", "\\")
$wt_reg = Join-Path -Path (Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent) -ChildPath "wt.reg"
$registry | Out-File -FilePath $wt_reg -Force

$profile_lines = @'
#===Open in Windows Terminal start===#
# More info: https://github.com/yangshuairocks/Open_in_Windows_Terminal
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
#===Open in Windows Terminal end===#
'@

if ((Get-Item $PROFILE -ea 0) -isnot [IO.FileInfo])
{
    New-Item $PROFILE -Type File -Force
    Add-Content -Path $PROFILE -Value $profile_lines
}
else
{
    # If old corresponding block of code exists
    if ((Get-Content $PROFILE -Raw) -match '(?sm).*?^#===Open in Windows Terminal start===#\r?$.*')
    {
        $tmp_content = (Get-Content $PROFILE -Raw) -replace '(?sm)^#===Open in Windows Terminal start===#\r?$.*^#===Open in Windows Terminal end===#\r?$', $profile_lines
        $tmp_content | Out-File $PROFILE -Force
    }
    # If profile exists but doesn't contain the corresponding code
    else
    {
        Add-Content -Path $PROFILE -Value $profile_lines
    }
}


