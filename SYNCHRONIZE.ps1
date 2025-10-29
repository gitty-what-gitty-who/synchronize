<#
.SYNOPSIS
    SYNCRONIZE.ps1

.DESCRIPTION
    This PowerShell script allows Windows users to quickly and easily mirror 
    their Windows personal directories onto a USB drive.

.AUTHOR
    Luc Baeten

.CREATED
    18-10-2025
#>

# ================================================================================================
# set output color
# ================================================================================================

$host.UI.RawUI.ForegroundColor = 'Yellow'

# ================================================================================================
# prompt [y/n] for timeout
# ================================================================================================

$use_timeout = $null

do {
    Clear-Host
    $input = Read-Host "Run script with delays [y/n]"

    switch ($input.ToLower()) {
        'y' { 
            $use_timeout = $true
        }
        'n' {
            $use_timeout = $false
        }
        default {
            Write-Host "Invalid input, please enter 'y' or 'n'."
            Start-Sleep -Seconds 1
        }
    }
} until ($use_timeout -ne $null)

if ($use_timeout) {
    Write-Host "Delays will be applied..."
    Start-Sleep -Seconds 1
} else {
    Write-Host "Running without delays..."
}

# ================================================================================================
# validate user and computer
# ================================================================================================

Write-Host ""
Write-Host "-------------------------------------------------------------------------------------"
Write-Host "   VALIDATE     ::     Validate user and computer"
Write-Host "-------------------------------------------------------------------------------------"
Write-Host ""

if ($use_timeout) { Start-Sleep -Seconds 2 }

$dir_parent = $MyInvocation.MyCommand.Path
$dir_parent = $dir_parent -replace '\.ps1$', ''

$dir_user   = Join-Path $dir_parent "User"
$dir_pc     = Join-Path $dir_parent "Pc"

$user_txt = Join-Path $dir_user "User.txt"
$pc_txt   = Join-Path $dir_pc "Pc.txt"

$valid_user = $null
$valid_pc   = $null
$validate   = $null

if (Test-Path $user_txt) { $valid_user = (Get-Content $user_txt -Raw).Trim() }
if (Test-Path $pc_txt)   { $valid_pc   = (Get-Content $pc_txt -Raw).Trim() }

if (-not (Test-Path $user_txt) -and -not (Test-Path $pc_txt)) {
    $validate = "init_user"
}
elseif ((Test-Path $user_txt) -and $env:USERNAME -eq $valid_user) {
    if ((Test-Path $pc_txt) -and $env:COMPUTERNAME -eq $valid_pc) {
        $validate = "valid_user"
    } else {
        $validate = "invalid_user"
    }
} else {
    $validate = "invalid_user"
}

switch ($validate) {
    "init_user" {
        Write-Host "  First synchronization for user '$env:USERNAME' from computer '$env:COMPUTERNAME'"
        Write-Host ""
        if ($use_timeout) { Start-Sleep -Seconds 2 }
    }
    "valid_user" {
        Write-Host "  Next synchronization for user '$valid_user' from computer '$valid_pc'"
        if ($use_timeout) { Start-Sleep -Seconds 2 }
        Write-Host ""
    }
    "invalid_user" {
        Clear-Host
        $host.UI.RawUI.ForegroundColor = 'Red'
        Write-Host ""
        Write-Host "ERROR: The USB contains synchronized data from a different user or computer!"
        Write-Host ""
        Write-Host "       Saved user : $valid_user"
        Write-Host "       Saved host : $valid_pc"
        Write-Host ""
        Write-Host "       New user   : $env:USERNAME"
        Write-Host "       New host   : $env:COMPUTERNAME"
        Write-Host ""
        Write-Host "INFO: To proceed with the new user and remove existing synchronized data:"
        Write-Host ""
        Write-Host "      1. Delete directory '$dir_parent' on the USB."
        Write-Host "      2. Restart the script."
        Write-Host ""
        Write-Host "To synchronize multiple users on the same USB while keeping their data:"
        Write-Host ""
        Write-Host "      1. Copy and rename the script for each user (e.g., John_SYNC.ps1, Alice_SYNC.ps1)."
        Write-Host "      2. Run the renamed script for each user."
        Write-Host ""
       [console]::beep(500,1000)
       exit
    }
}

if (-not (Test-Path $user_txt)) {
    New-Item -ItemType Directory -Path $dir_user -Force | Out-Null
    $env:USERNAME | Out-File -FilePath $user_txt -Encoding UTF8
    (Get-Item $dir_user).Attributes += 'Hidden'
    Write-Host "  Saved username '$env:USERNAME' at '$user_txt'"
    Write-Host ""
}

if (-not (Test-Path $pc_txt)) {
    New-Item -ItemType Directory -Path $dir_pc -Force | Out-Null
    $env:COMPUTERNAME | Out-File -FilePath $pc_txt -Encoding UTF8
    (Get-Item $dir_pc).Attributes += 'Hidden'
    Write-Host "  Saved computer name '$env:COMPUTERNAME' at '$pc_txt'"
    Write-Host ""
}

# ================================================================================================
# if dir_parent\Logs does not exist then make dir_parent\Logs on usb & rotate log files
# ================================================================================================

$dir_logs = Join-Path $dir_parent "Logs"

$log1 = Join-Path $dir_logs "Log1.log"
$log2 = Join-Path $dir_logs "Log2.log"
$log3 = Join-Path $dir_logs "Log3.log"
$log4 = Join-Path $dir_logs "Log4.log"
$log5 = Join-Path $dir_logs "Log5.log"

if (-not (Test-Path $dir_logs)) {
    New-Item -ItemType Directory -Path $dir_logs | Out-Null
    Write-Host "-------------------------------------------------------------------------------------"
    Write-Host "   MAKE     ::     Make directories for logs and Data"
    Write-Host "-------------------------------------------------------------------------------------"
    Write-Host ""
    Write-Host "  Make directory for logs on USB drive: $dir_logs"
    Write-Host ""
}

if (Test-Path $log5) { Remove-Item $log5 -Force }
if (Test-Path $log4) { Rename-Item $log4 "Log5.log" }
if (Test-Path $log3) { Rename-Item $log3 "Log4.log" }
if (Test-Path $log2) { Rename-Item $log2 "Log3.log" }
if (Test-Path $log1) { Rename-Item $log1 "Log2.log" }

# ================================================================================================
#  if dir_parent\Data does not exist then make dir_parent\Data on usb
# ================================================================================================

$dir_data = Join-Path $dir_parent "Data"

if (-not (Test-Path $dir_data)) {
    New-Item -ItemType Directory -Path $dir_data | Out-Null
    Write-Host "  Make directory for data on USB: $dir_data"
    Write-Host ""
}

# ================================================================================================
#  calculate the size of data to be synchronized
# ================================================================================================

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

Write-Host "-------------------------------------------------------------------------------------"
Write-Host "   STORAGE     ::     Make sure there is enough free space on USB"
Write-Host "-------------------------------------------------------------------------------------"
Write-Host ""

Write-Host "  New data          : $size_new_data bytes / $size_new_data_GB GB"
Write-Host ""

# ================================================================================================
#    get the size of data on the USB drive
# ================================================================================================

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

# ================================================================================================
#    calculate the size of delta data
# ================================================================================================

$size_delta_data = $size_new_data - $size_data_usb
$size_delta_data_GB = [math]::Round($size_delta_data / 1GB, 2)

Write-Host "  Delta data        : $size_delta_data bytes / $size_delta_data_GB GB"
Write-Host ""

# ================================================================================================
#    get the free space on the USB drive
# ================================================================================================

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

# ================================================================================================
#    free space on usb >= delta data then continue script
# ================================================================================================

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
    Write-Host ""
    Write-Host "error : Not enough free space on the USB drive."
    Write-Host ""
    Write-Host "info  : Please use another USB drive with capacity larger than $size_c_gb GB."
    Write-Host ""
    [console]::beep(500, 1000)
    exit
}

# ================================================================================================
#    probe directories Documents Pictures Videos Music
# ================================================================================================

Write-Host "-------------------------------------------------------------------------------------"
Write-Host "   PROBE     ::     Probe directories : Documents Pictures Videos Music"
Write-Host "-------------------------------------------------------------------------------------"
Write-Host ""

$directories = "Documents","Pictures","Videos","Music"
$user_profile = $env:USERPROFILE

foreach ($dir in $directories) {
    $full_path = Join-Path $user_profile $dir
    if (-not (Test-Path $full_path)) {
        Write-Host "  Directory '$full_path' not found"
        Write-Host ""
    } else {
        Write-Host "  Directory '$full_path' ok"
        Write-Host ""
    }
}

# ================================================================================================
#     synchronize directories met robocopy
# ================================================================================================

Write-Host "  Starting synchronization . . ."

if ($use_timeout -eq $true) { Start-Sleep -Seconds 5 }
Write-Host ""

Write-Host "-------------------------------------------------------------------------------------"
Write-Host "   SYNCHRONIZE     ::     Synchronize directories : Documents Pictures Videos Music"
Write-Host "-------------------------------------------------------------------------------------"

$directories = "Documents","Pictures","Videos","Music"
$user_profile = $env:USERPROFILE
$log_file = Join-Path $dir_parent "Logs\Log1.log"
$data_dir = Join-Path $dir_parent "Data"

foreach ($dir in $directories) {
    $source = Join-Path $user_profile $dir
    $destination = Join-Path $data_dir $dir

    if (Test-Path $source) {
        Write-Host ""
        Write-Host "  Start synchronization $source . . ."

        if ($use_timeout -eq $true) { Start-Sleep -Seconds 5 }

        if (-not (Test-Path $destination)) { New-Item -ItemType Directory -Path $destination | Out-Null }

        robocopy $source $destination /MIR /FFT /R:2 /W:5 /XJD /LOG+:$log_file /TEE
    }
}

if ($use_timeout -eq $true) { Start-Sleep -Seconds 5 }

# ================================================================================================
#     synchronization finished
# ================================================================================================

Write-Host "-------------------------------------------------------------------------------------"
Write-Host "   SYNCHRONIZATION     ::    Synchronization finished"
Write-Host "-------------------------------------------------------------------------------------"
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
    Write-Host "  Synchronization completed"
} else {
    Write-Host "  Synchronization finished with exceptions:"
    foreach ($dir in $directories) {
        if (-not $exist[$dir]) {
            Write-Host "    No directory '$user_profile\$dir' to synchronize"
        }
    }
}

# ================================================================================================
#     end of script
# ================================================================================================

[console]::Beep(500, 1000)  # 500 Hz for 1 second

Write-Host ""
Write-Host ""