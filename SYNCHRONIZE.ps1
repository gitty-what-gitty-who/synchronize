<#
.SYNOPSIS
    SYNCRONIZE.ps1

.DESCRIPTION
    This PowerShell script allows Windows users to quickly and easily mirror 
    their Windows personal directories onto a USB drive.
#>

# ========================================================================================================
#    ensure this script runs from a removable USB drive only   
# ========================================================================================================

$scriptDrive = (Split-Path -Qualifier $MyInvocation.MyCommand.Path)

$systemDrive = $env:SystemDrive

if ($scriptDrive -eq $systemDrive) {
    Write-Host "⚠️ This script is being run from the system drive ($systemDrive) instead of a USB drive." -ForegroundColor Red
    Write-Host "   You need to run this script from a removable USB drive to continue.." -ForegroundColor Red
    Write-Host ""

    [console]::Beep(500, 1000)  # 500 Hz for 1 second

    if ($host.Name -eq 'ConsoleHost' -or $host.Name -eq 'Windows PowerShell ISE Host') {
    Write-Host "Press Enter to exit..."
    Read-Host
    exit
    }  
}

# ========================================================================================================
#    define function to change folder icon
# ========================================================================================================

function Change-Icon {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PathDir,

        [Parameter(Mandatory = $true)]
        [string]$Icon
    )

    $IconMap = @{
        "good"    = 233
        "bad"     = 93
        "warning" = 231
        "sync"    = 229
        "log"     = 97
    }

    $FileDesktopIni = Join-Path $PathDir "desktop.ini"
    $IconResource   = "C:\WINDOWS\system32\imageres.dll,$($IconMap[$Icon])"
    $Content        = "[.ShellClassInfo]`r`nIconResource=$IconResource"

    $Content | Set-Content -Encoding Unicode $FileDesktopIni

    attrib +r $PathDir
    attrib +h +s $FileDesktopIni
}

# ========================================================================================================
#    set output color
# ========================================================================================================

$output_color = 'Yellow'
$host.UI.RawUI.ForegroundColor = $output_color

#Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray,
#DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White

# ========================================================================================================
#    prompt [y/n] for timeout
# ========================================================================================================

$use_timeout = $null

do {
    clear-host
    $input = read-Host "Run script with delays [y/n]"

    switch ($input.ToLower()) {
        'y' { 
            $use_timeout = $true
        }
        'n' {
            $use_timeout = $false
        }
        default {
            write-Host "Invalid input, please enter 'y' or 'n'." 
            start-Sleep -Seconds 1
        }
    }
} until ($use_timeout -ne $null)

if ($use_timeout) {
    write-Host "Delays will be applied..."
    start-Sleep -Seconds 1
} else {
    write-Host "Running without delays..."
}

# ========================================================================================================
#    show logo
# ========================================================================================================

clear-host
write-host "   ______   ___   _  ____ _   _ ____   ___  _   _ ___ __________ "
write-host "  / ___\ \ / / \ | |/ ___| | | |  _ \ / _ \| \ | |_ _|__  / ____|"
write-host "  \___ \\ V /|  \| | |   | |_| | |_) | | | |  \| || |  / /|  _|  "
write-host "   ___) || | | |\  | |___|  _  |  _ <| |_| | |\  || | / /_| |___ "
write-host "  |____/ |_| |_| \_|\____|_| |_|_| \_\\___/|_| \_|___/____|_____|"

# ========================================================================================================
#    create parent dir from username + computername + account SID hash
# ========================================================================================================

if ($use_timeout) { Start-Sleep -Seconds 2 }

$drive = Split-Path -Qualifier $MyInvocation.MyCommand.Path

$baseName = "{0}_{1}" -f $env:USERNAME.ToUpper(), $env:COMPUTERNAME.ToUpper()

# Get current user SID
$userSID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

# Compute short hash from SID
$hashBytes = [System.Text.Encoding]::UTF8.GetBytes($userSID)
$sha1 = [System.Security.Cryptography.SHA1]::Create()
$hash = [BitConverter]::ToString($sha1.ComputeHash($hashBytes)) -replace "-", ""
$shortHash = $hash.Substring(0,6)

$dir_parent = Join-Path $drive ("{0}_{1}" -f $baseName, $shortHash)

if (-Not (Test-Path $dir_parent)) {
    Write-Host "" 
    Write-Host "-------------------------------------------------------------------------------" 
    Write-Host "   INIT     ::     Initialize user"
    Write-Host "-------------------------------------------------------------------------------" 
    Write-Host "" 
    Write-Host "  Performing first synchronization for user '$env:USERNAME' on computer '$env:COMPUTERNAME'"
    Write-Host ""
    if ($use_timeout) { Start-Sleep -Seconds 2 }
}
elseif (Test-Path $dir_parent) {
    Write-Host "" 
    Write-Host "-------------------------------------------------------------------------------" 
    Write-Host "   VERIFY     ::     Verify user"
    Write-Host "-------------------------------------------------------------------------------" 
    Write-Host "" 
    Write-Host "  Next synchronization for user '$env:USERNAME' on computer '$env:COMPUTERNAME'"
    Write-Host ""
    if ($use_timeout) { Start-Sleep -Seconds 2 }
}

# ========================================================================================================
#    if dir_parent\Logs does not exist then make dir_parent\Logs & keep only "n" log files
# ========================================================================================================

$dir_logs = Join-Path $dir_parent "Logs"

if (-not (Test-Path $dir_logs)) {
    New-Item -ItemType Directory -Path $dir_logs | Out-Null
    Write-Host "-------------------------------------------------------------------------------"
    Write-Host "   CREATE     ::     Creating directories logs and Data onto the USB drive"
    Write-Host "-------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host "  Creating Logs directory : $dir_logs"
    Write-Host ""
}

# Get all log files that match the date pattern
$logs = Get-ChildItem -Path $dir_logs -Filter "*.txt" |
    Where-Object { $_.BaseName -match '^\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}$' } |
    Sort-Object Name -Descending

# Keep the 5 most recent, delete the rest
$logsToDelete = $logs | Select-Object -Skip 20
$logsToDelete | Remove-Item -Force

Change-Icon -PathDir $dir_logs -Icon "log"

# ========================================================================================================
#    if dir_parent\Data does not exist then create dir_parent\Data
# ========================================================================================================

$dir_data = Join-Path $dir_parent "Data"

if (-not (Test-Path $dir_data)) {
    New-Item -ItemType Directory -Path $dir_data | Out-Null
    Write-Host "  Creating Data directory : $dir_data"
    Write-Host ""
    Change-Icon -PathDir $dir_parent -Icon "sync"
}

 Change-Icon -PathDir $dir_parent -Icon "sync"

# ========================================================================================================
#    calculate the size of data to be synchronized
# ========================================================================================================

$user_path = $env:USERPROFILE
$directories = @("Documents", "Pictures", "Videos", "Music")

$sizes = @{}

foreach ($dir in $directories) {
    $fullPath = Join-Path $user_path $dir
    if (Test-Path $fullPath) {
        $size = (Get-ChildItem -file $fullPath -Recurse -ErrorAction SilentlyContinue |
                 Measure-Object -Property Length -Sum).Sum
        if (-not $size) { $size = 0 }
    } else {
        $size = 0
    } 
    $sizes[$dir] = $size
}

# Total size in bytes
$size_new_data = ($sizes.Values | Measure-Object -Sum).Sum

# Total size in GB (rounded to 2 decimals)
$size_new_data_GB = [math]::Round($size_new_data / 1GB, 2)

Write-Host "-------------------------------------------------------------------------------"
Write-Host "   STORAGE     ::     Make sure there is enough free space on USB"
Write-Host "-------------------------------------------------------------------------------"
Write-Host ""
Write-Host "  New data          : $size_new_data bytes / $size_new_data_GB GB"
Write-Host ""

# ========================================================================================================
#    get the size of data on the USB drive
# ========================================================================================================

$dir_data_usb = Join-Path $dir_parent "Data"

if (Test-Path $dir_data_usb) {
    $size_data_usb = (Get-ChildItem $dir_data_usb -Recurse -ErrorAction SilentlyContinue |
                      Measure-Object -Property Length -Sum).Sum
    if (-not $size_data_usb) { $size_data_usb = 0 }
} else {
    $size_data_usb = 0
}

$size_data_usb_GB = [math]::Round($size_data_usb / 1GB, 2)

Write-Host "  Current data      : $size_data_usb bytes / $size_data_usb_GB GB"
Write-Host ""

# ========================================================================================================
#    calculate the size of delta data
# ========================================================================================================

$size_delta_data = $size_new_data - $size_data_usb
$size_delta_data_GB = [math]::Round($size_delta_data / 1GB, 2)

Write-Host "  Delta data        : $size_delta_data bytes / $size_delta_data_GB GB"
Write-Host ""

# ========================================================================================================
#    get the free space on the USB drive
# ========================================================================================================

$drive = $MyInvocation.MyCommand.Path.Substring(0, 1)  # First character = drive letter

$drive_info = Get-PSDrive -Name $drive -ErrorAction SilentlyContinue
if ($drive_info) {
    $size_free_space_usb = $drive_info.Free
} else {
    $size_free_space_usb = 0
}

$size_free_space_usb_GB = [math]::Round($size_free_space_usb / 1GB, 2)

Write-Host "  Free space on USB : $size_free_space_usb bytes / $size_free_space_usb_GB GB"
Write-Host ""

# ========================================================================================================
#    free space on usb >= delta data then continue script
# ========================================================================================================

#$continue_script = "False"

$continue_script = $size_free_space_usb -gt $size_delta_data

Write-Host "  Free space on USB > Delta data = $continue_script"
Write-Host ""
Write-Host "  Enough free space on USB : $continue_script"
Write-Host ""

if ($use_timeout -eq $true) { Start-Sleep -Seconds 5 }

if (-not $continue_script) {
    Clear-Host
    $host.UI.RawUI.ForegroundColor = 'Red'
    $driveInfo = Get-PSDrive -Name C
    $free_c = $driveInfo.Free
    $used_c = $driveInfo.Used
    $size_c = $free_c + $used_c
    $size_c_gb = [math]::Round($size_c / 1GB, 2)

    write-host "   ______   ___   _  ____ _   _ ____   ___  _   _ ___ __________ "
    write-host "  / ___\ \ / / \ | |/ ___| | | |  _ \ / _ \| \ | |_ _|__  / ____|"
    write-host "  \___ \\ V /|  \| | |   | |_| | |_) | | | |  \| || |  / /|  _|  "
    write-host "   ___) || | | |\  | |___|  _  |  _ <| |_| | |\  || | / /_| |___ "
    write-host "  |____/ |_| |_| \_|\____|_| |_|_| \_\\___/|_| \_|___/____|_____|"
    Write-Host ""
    Write-Host "-------------------------------------------------------------------------------"
    Write-Host "   ERROR     ::     There is not enough free space on USB drive"
    Write-Host "-------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host "  Please use another USB drive with capacity larger than $size_c_gb GB."
    Write-Host ""

    Change-Icon -PathDir $dir_data -Icon "bad"

    [console]::beep(500, 1000)

    if ($host.Name -eq 'ConsoleHost' -or $host.Name -eq 'Windows PowerShell ISE Host') {
    Write-Host "  Press Enter to exit..."
    Read-Host
    exit
    }  
}

# ========================================================================================================
#    Verify directories Documents Pictures Videos Music
# ========================================================================================================

Write-Host "-------------------------------------------------------------------------------"
Write-Host "   VERIFY     ::     Verify local directories"
Write-Host "-------------------------------------------------------------------------------"
Write-Host ""

$directories = "Documents","Pictures","Videos","Music"
$user_profile = $env:USERPROFILE

foreach ($dir in $directories) {
    $full_path = Join-Path $user_profile $dir
    if (-not (Test-Path $full_path)) {
        Write-Host "  Directory '$full_path' not found" -ForegroundColor Red
        Write-Host ""
    } else {
        Write-Host "  Directory '$full_path' ok"
        Write-Host ""
    }
}

# ========================================================================================================
#     synchronize directories met robocopy
# ========================================================================================================

Write-Host "  Starting synchronization . . ."

if ($use_timeout -eq $true) { Start-Sleep -Seconds 5 }
Write-Host ""

Write-Host "-------------------------------------------------------------------------------"
Write-Host "   SYNCHRONIZE     ::     Starting synchronization "
Write-Host "-------------------------------------------------------------------------------"

$directories = "Documents","Pictures","Videos","Music"
$user_profile = $env:USERPROFILE
#$log_file = Join-Path $dir_parent "Logs\Log1.log"
$log = Join-Path $dir_logs "$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
$data_dir = Join-Path $dir_parent "Data"

foreach ($dir in $directories) {
    $source = Join-Path $user_profile $dir
    $destination = Join-Path $data_dir $dir

    if (Test-Path $source) {
        Write-Host ""
        Write-Host "  Start synchronization $source . . ."
        if ($use_timeout -eq $true) { Start-Sleep -Seconds 5 }
        if (-not (Test-Path $destination)) { New-Item -ItemType Directory -Path $destination | Out-Null }

        robocopy $source $destination /MIR /FFT /R:2 /W:5 /XJD /E /LOG+:$log /TEE 
    }
}

if ($use_timeout -eq $true) { Start-Sleep -Seconds 5 }

# ========================================================================================================
#     synchronization finished
# ========================================================================================================

Write-Host "-------------------------------------------------------------------------------"
Write-Host "   SYNCHRONIZE     ::     Finished Synchronization"
Write-Host "-------------------------------------------------------------------------------"
Write-Host ""

$exceptions = $false
$directories = "Documents","Pictures","Videos","Music"
$user_profile = $env:USERPROFILE
$exist = @{}

foreach ($dir in $directories) {
    $full_path = Join-Path $user_profile $dir
    if (-not (Test-Path $full_path)) {
        $exceptions = $true
        $exist[$dir] = $false
    } else {
        $exist[$dir] = $true
    }
}

if (-not $exceptions) {
    Write-Host "  Finished synchronization"
    Change-Icon -PathDir $dir_data -Icon "good"
} else {
    Write-Host "  Finished synchronization with exceptions:" -ForegroundColor Red
    foreach ($dir in $directories) {
        if (-not $exist[$dir]) {
            Write-Host "  No directory '$user_profile\$dir' to synchronize" -ForegroundColor Red
            Change-Icon -PathDir $dir_data -Icon "warning"
        }
    }
}

# ========================================================================================================
#     end of script
# ========================================================================================================

Write-Host ""
Write-Host "-------------------------------------------------------------------------------"
Write-Host "   END     ::     End of script"
Write-Host "-------------------------------------------------------------------------------"
Write-Host ""

[console]::Beep(500, 1000)  # 500 Hz for 1 second

if ($host.Name -eq 'ConsoleHost' -or $host.Name -eq 'Windows PowerShell ISE Host') {
Write-Host "  Press Enter to exit..."
Read-Host
exit
}  
