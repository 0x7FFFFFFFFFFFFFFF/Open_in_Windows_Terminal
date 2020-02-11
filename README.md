# Add "Open Windows Terminal" to your context menu

## Introduction
This repository contains some scripts to create a context menu item **Open Windows Terminal**. You can right click on any file, folder and the empty area of a folder to get this menu. See below demo.gif for the effects of the script.
<img src="https://github.com/yangshuairocks/Open_in_Windows_Terminal/raw/master/demo.gif">


## How to use
* Install Windows Terminal
* Run a PowerShell session as administrator and execute the command `Set-ExecutionPolicy RemoteSigned -Force` 
* Download [install.ps1](https://github.com/yangshuairocks/Open_in_Windows_Terminal/blob/master/Open%20in%20Windows%20Terminal/install.ps1)
* Right click `install.ps1`, choose `Run with PowerShell`. This will generate `wt.reg` and `wt_nonadmin.reg`.
* Double click `wt.reg`, click *Yes* and *OK*. This will add an entry *Open Windows Terminal* to your context menu.
* Optionally, double click `wt_nonadmin.reg`, click *Yes* and *OK*. This will add an entry *Open Windows Terminal(Non-Admin)* to your context menu.

Now you can try to right click on something to see if it works.

Note that it is suggested to close UAC, otherwise you will see this every time you click context menu item *Open Windows Terminal*.

<img src="https://github.com/yangshuairocks/Open_in_Windows_Terminal/raw/e057a9730f20ba90dfa3faded6e6dcf0991ee2cb/UAC.png">


## How does it work?
* The reg file adds entries to your registry so that you will have context menu item added.
* The `install.ps1` file adds some code to your PowerShell profile, which will be executed whenever you open a PowerShell command line.
* When you click the "Open Windows Terminal" context menu item, the full path of the current directly (if you are clicking on the blank area of a folder or if you are clicking on a folder) or the current file (if you are clicking on a file) will be stored in a temp file `$env:TEMP\windows_terminal_current_dir.temp` and a Windows Terminal session will be opened.
* The added code to PowerShell profile will check if the current PowerShell session is Windows Terminal, if it was run as administrator, if the file `$env:TEMP\windows_terminal_current_dir.temp` exists and whether the full path in `$env:TEMP\windows_terminal_current_dir.temp` refers to a file or a folder etc. and properly set the location to the one stored in `$env:TEMP\windows_terminal_current_dir.temp` and remove it.
* It's possible that a new Windows Terminal will open (ensure it's run as administrator) and the old one close. That's why you will probably see window flashes.  


## Problem
* As you see in the demo.gif, the PowerShell Window will flash one or two times (based on your configuration). I don't know how to solve this. This is not an issue to me, though. Please let me know if you have any ideas on this.
