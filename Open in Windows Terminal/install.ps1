# Require admin
if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Main{
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
@="powershell -WindowStyle hidden -NoProfile -Command \"Add-Content -Path \"$env:TEMP\\windows_terminal_current_dir.temp\" -Value \\\"\"%V\"\\\"; Start-Process shell:appsFolder\\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App\""

; show in context menu when right click empty area of explorer
[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal]
@="Open Windows Terminal"
"Icon"="windows_terminal_path,0"

[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal\command]
@="powershell -WindowStyle hidden -NoProfile -Command \"Add-Content -Path \"$env:TEMP\\windows_terminal_current_dir.temp\" -Value \\\"\"%V\"\\\"; Start-Process shell:appsFolder\\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App\""

; show in context menu when right click directory
[HKEY_CLASSES_ROOT\Directory\shell\WindowsTerminal]
@="Open Windows Terminal"
"Icon"="windows_terminal_path,0"

[HKEY_CLASSES_ROOT\Directory\shell\WindowsTerminal\command]
@="powershell -WindowStyle hidden -NoProfile -Command \"Add-Content -Path \"$env:TEMP\\windows_terminal_current_dir.temp\" -Value \\\"\"%V\"\\\"; Start-Process shell:appsFolder\\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App\""
'@
    $registry = $registry -replace "windows_terminal_path", ($windows_terminal_path -replace "\\", "\\")
    $wt_reg = Join-Path -Path (Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent) -ChildPath "wt.reg"
    $registry | Out-File -FilePath $wt_reg -Force

    $registry = $registry -replace "\\WindowsTerminal\\command", "\WindowsTerminalNonAdmin\command"
    $registry = $registry -replace "\\WindowsTerminal]", "\WindowsTerminalNonAdmin]"
    $registry = $registry -replace "windows_terminal_current_dir.temp", "windows_terminal_nonadmin_current_dir.temp"
    $registry = $registry -replace "Open Windows Terminal", "Open Windows Terminal(Non-Admin)"

    $wt_reg = Join-Path -Path (Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent) -ChildPath "wt_nonadmin.reg"
    $registry | Out-File -FilePath $wt_reg -Force

    $profile_lines = @'
#===Open in Windows Terminal start===#
# More info: https://github.com/yangshuairocks/Open_in_Windows_Terminal
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
# If it's Windows Terminal session
if(Test-Path -Path $env:TEMP\windows_terminal_current_dir.temp -PathType Leaf) {
    # If not admin
    if(!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process shell:appsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App -Verb RunAs
        # Force exit current Windows Terminal session
        Stop-Process -Id (Get-WmiObject win32_process | ? processid -eq  $PID).parentprocessid -Force
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
if(Test-Path -Path $env:TEMP\windows_terminal_nonadmin_current_dir.temp -PathType Leaf) {
    if(Test-Path -Path $env:TEMP\windows_terminal_nonadmin_current_dir.temp -PathType Leaf) {
        $destination = Get-Content $env:TEMP\windows_terminal_nonadmin_current_dir.temp -First 1
        if((Get-Item $destination -ea 0) -is [IO.FileInfo]) {
            $destination = Split-Path $destination
        }
        Set-Location -Path $destination
        Remove-Item -Path $env:TEMP\windows_terminal_nonadmin_current_dir.temp -Force
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
        if ((Get-Content $PROFILE -Raw).IndexOf("#===Open in Windows Terminal start===#") -ge 0)
        {
            $tmp_content = (Get-Content $PROFILE -Raw) -replace '(?sm)^#===Open in Windows Terminal start===#\r?$.*^#===Open in Windows Terminal end===#\r?$', $profile_lines
            $tmp_content | Out-File $PROFILE -Force
        }
        # If profile exists but doesn't contain the corresponding code
        else
        {
            # The whole profile could take some time to run. We need to put our code at the beginning of the profile
            # so that it can quickly determine if reopen is necessary and avoid the performance penalty.
            PrependTo-File -file $PROFILE -content $profile_lines
        }
    }


}

function PrependTo-File {
    [cmdletbinding()]
    param (
        [Parameter(Position = 1, ValueFromPipeline = $true, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Object]$file,
        [Parameter(Position = 0, ValueFromPipeline = $false, Mandatory = $true)]
        [string]$content,
        [Parameter(ValueFromPipeline = $false, Mandatory = $false)]
        [Switch]$NoNewline,
        [Parameter(ValueFromPipeline = $false, Mandatory = $false)]
        [Switch]$UnixNewline
    )

    process {
        if ($file -is [string]) {
            $original_file = $file
            $file = Get-Item -Path $file -ea 0
            if ($file -eq $null) {
                New-Item -Path $original_file -ItemType File -Force -ea 0
            }
        }
        $filepath = $file.FullName;
        $tmp_file = $filepath + ".__tmp__";
        $tmp_stream = [System.io.file]::create($tmp_file);
        $original_stream = [System.IO.File]::Open($filepath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite);
        try {
            $msg = $content.ToCharArray();
            $tmp_stream.Write($msg, 0, $msg.length);
            if ($NoNewline -eq $false) {
                if ($UnixNewline -eq $false) {
                    $tmp = [text.encoding]::ASCII.GetBytes("`r")
                    $tmp_stream.Write($tmp, 0, $tmp.length)
                }
                $tmp = [text.encoding]::ASCII.GetBytes("`n")
                $tmp_stream.Write($tmp, 0, $tmp.length)
            }
            $original_stream.Position = 0;
            $original_stream.CopyTo($tmp_stream);
        }
        finally {
            $tmp_stream.flush();
            $tmp_stream.close();
            $original_stream.close();
            if ($error.count -eq 0) {
                [System.io.File]::Delete($filepath);
                [System.io.file]::Move($tmp_file, $filepath);
            } else {
                $error.clear();
                [System.io.file]::Delete($tmp_file);
            }
        }
    }
}

Main
