rem *************************************************************************************************************************************************
rem   Script Name : "SYNCRONIZE.bat"                                        
rem   Author      : Luc Baeten                                              
rem   Created On  : 18-10-2025
rem   Description : Syncronize windows directories "Documents", "Pictures" "Videos" and "Music" with directory "Data" on usb
rem *************************************************************************************************************************************************

@echo off

setlocal

setlocal enabledelayedexpansion

mode con: cols=120 lines=40

title SYNCRONIZE

color 2

:: 0 = Black
:: 1 = Blue
:: 2 = Green
:: 3 = Aqua
:: 4 = Red
:: 5 = Purple
:: 6 = Yellow
:: 7 = White


rem *************************************************************************************************************************************************
rem   prompt [y/n] for timeouts
rem *************************************************************************************************************************************************


set input=""
set use_timeout=""

:prompt

cls
set /p "input=Run script with delays [y/n] : " 
if /i %input% == y ( set use_timeout=true & goto next )
if /i %input% == n ( goto next )
goto prompt

:next


rem *************************************************************************************************************************************************
rem   Show logo in the header
rem *************************************************************************************************************************************************


set /a logo_count=0

goto begin_logo
:end_logo_1


rem *************************************************************************************************************************************************
rem   validate user and computer
rem *************************************************************************************************************************************************

echo:
echo -------------------------------------------------------------------------------
echo    VALIDATE     ::     Validate user and computer
echo -------------------------------------------------------------------------------
echo:

if %use_timeout% == true ( timeout /t 2 > null )

set dir_user=%~d0\Syncronize\User
set dir_pc=%~d0\Syncronize\Pc

set valid_userQ=""
set valid_pcQ=""

set valid_user=""
set valid_pc=""

set validate=""

if exist %dir_user%\User.txt (
    for /f "tokens=*" %%A in (%dir_user%\User.txt) do (
        set valid_userQ="%%A"
    )
)

set "valid_user=%valid_userQ:"=%"

if exist %dir_pc%\Pc.txt (
    for /f "tokens=*" %%A in (%dir_pc%\Pc.txt) do (
        set valid_pcQ="%%A"
    )
)

set "valid_pc=%valid_pcQ:"=%"

if not exist %dir_user%\User.txt (
    if not exist %dir_pc%\Pc.txt (
        set validate="init_user"
    )
)

if exist %dir_user%\User.txt if "%USERNAME%" == "%valid_user%" (
    if exist %dir_pc%\Pc.txt if "%COMPUTERNAME%" == "%valid_pc%" (
        set validate="valid_user"
    )
)

if exist %dir_user%\user.txt if not "%USERNAME%" == "%valid_user%" (
    set validate="invalid_user"
)

if exist %dir_pc%\Pc.txt if not "%COMPUTERNAME%" == "%valid_pc%" (
    set validate="invalid_pc"
)

if exist %dir_user%\user.txt if not "%USERNAME%" == "%valid_user%" (
    if exist %dir_pc%\Pc.txt if not "%COMPUTERNAME%" == "%valid_pc%" (
        set validate="invalid_user_and_pc"
    )
)

if %validate% == "init_user" (
    echo  First syncronization for user "%USERNAME%" from computer "%COMPUTERNAME%"
    echo: 
    if %use_timeout% == true ( timeout /t 2 > null )
)

if %validate% == "valid_user" (
    echo  Next syncronization for user "%valid_user%" from computer "%valid_pc%"
    echo:
    if %use_timeout% == true ( timeout /t 2 > null )
) 

if %validate% == "invalid_user" (
    color 4
    echo  error : Different user!
    echo:
    echo  info  : Data for user "%valid_user%" from computer "%valid_pc%" has already been synchronized.
    echo          If you want to continue with user "%USERNAME%" from computer "%COMPUTERNAME%"
    echo          then delete the directory "%~d0\Syncronize" on the usb drive and restart the script. 
    echo:
    powershell "[console]::beep(500,1000)"
    pause 
    del "%~d0\null"
    exit
)

if %validate% == "invalid_pc" (
    color 4
    echo  error : Different computer!
    echo:
    echo  info  : Data for user "%valid_user%" from computer "%valid_pc%" has already been synchronized.
    echo          If you want to continue with user "%USERNAME%" from computer "%COMPUTERNAME%"
    echo          then delete the directory "%~d0\Syncronize" on the usb drive and restart the script. 
    echo:
    powershell "[console]::beep(500,1000)"
    pause 
    del "%~d0\null"
    exit
)

if %validate% == "invalid_user_and_pc" (
    color 4
    echo  error : Different user and computer!
    echo:
    echo  info  : Data for user "%valid_user%" from computer "%valid_pc%" has already been synchronized.      
    echo          If you want to continue with user "%USERNAME%" from computer "%COMPUTERNAME%"          
    echo          then delete the directory "%~d0\Syncronize" on the usb drive and and restart the script.  
    echo:
    powershell "[console]::beep(500,1000)"
    pause 
    del "%~d0\null"
    exit
)

if not exist %dir_user%\User.txt (
    mkdir %dir_user%
    echo %USERNAME%> %dir_user%\User.txt
    attrib +h "%~d0\Syncronize\User"
    echo  Save username "%USERNAME%" on usb "%dir_user%\User.txt"
    echo:
)

if not exist %dir_pc%\Pc.txt (
    mkdir %dir_pc%
    echo %COMPUTERNAME%> %dir_pc%\Pc.txt
    attrib +h "%~d0\Syncronize\Pc"
    echo  Save computername "%COMPUTERNAME%" on usb "%dir_pc%\Pc.txt"
    echo:
)


rem *************************************************************************************************************************************************
rem   if dir Syncronize\Logs does not exist then mkdir Syncronize\Logs on usb & rotate log files
rem *************************************************************************************************************************************************


set log1=%~d0\Syncronize\Logs\Log1.log
set log2=%~d0\Syncronize\Logs\Log2.log
set log3=%~d0\Syncronize\Logs\Log3.log
set log4=%~d0\Syncronize\Logs\Log4.log
set log5=%~d0\Syncronize\Logs\Log5.log

if not exist %~d0\Syncronize\Logs\ (
    mkdir %~d0\Syncronize\Logs
    echo -------------------------------------------------------------------------------
    echo    MAKE     ::     Make directories for logs and Data
    echo -------------------------------------------------------------------------------
    echo:
    echo  Make directory for logs on usb drive "%~d0\Syncronize\Logs"
    echo:
)

if exist %log5% (
    del %log5%
)

if exist %log4% (
    ren %log4% log5.log
)

if exist %log3% (
    ren %log3% log4.log
)

if exist %log2% (
    ren %log2% log3.log
)

if exist %log1% (
    ren %log1% log2.log
)


rem *************************************************************************************************************************************************
rem   if dir Data does not exist then mkdir Syncronize\Data on usb
rem *************************************************************************************************************************************************


if not exist %~d0\Syncronize\Data\ (
    mkdir %~d0\Syncronize\Data
    echo  Make directory for data on usb "%~d0\Syncronize\Data"
    echo:
)


rem **********************************************************************************
rem   get the size of the data on C:
rem **********************************************************************************


set dir_documents="%USERPROFILE%\documents"
set dir_pictures="%USERPROFILE%\Pictures"
set dir_videos="%USERPROFILE%\Videos"
set dir_music="%USERPROFILE%\Music"

set size_documentsQ=""
set size_picturesQ=""
set size_videosQ=""
set size_musicQ=""

set size_documents=""
set size_pictures=""
set size_videos=""
set size_music=""

set size_new_data=""
set size_new_data_GB=""

set line=""


rem ------------------------------------------------------------------------------


:: Get the total size of files in the directory documents

for /f "tokens=*" %%A in ('dir /s /a /-c "%dir_documents%" ^| find "File(s)"') do (
    set "line=%%A"
    for /f "tokens=1,2 delims=," %%B in ("!line!") do set "size_documents=%%B"
)

for /f "tokens=3 delims= " %%A in ("%size_documents%") do (
    set size_documentsQ="%%A"
)

set "size_documents=%size_documentsQ:"=%"

for /f %%S in (
    'powershell -Command "%size_documents% + 0"'
) do (
    set "size_new_data=%%S"
)


rem ------------------------------------------------------------------------------


:: Get the total size of files in the directory Pictures

for /f "tokens=*" %%A in ('dir /s /a /-c "%dir_pictures%" ^| find "File(s)"') do (
    set "line=%%A"
    for /f "tokens=1,2 delims=," %%B in ("!line!") do set "size_pictures=%%B"
)

for /f "tokens=3 delims= " %%A in ("%size_pictures%") do (
    set size_picturesQ="%%A"
)

set "size_pictures=%size_picturesQ:"=%"

for /f %%S in (
    'powershell -Command "%size_documents% + %size_pictures%"'
) do (
    set "size_new_data=%%S"
)


rem ------------------------------------------------------------------------------


:: Get the total size of files in the directory Videos

for /f "tokens=*" %%A in ('dir /s /a /-c "%dir_videos%" ^| find "File(s)"') do (
    set "line=%%A"
    for /f "tokens=1,2 delims=," %%B in ("!line!") do set "size_videos=%%B"
)

for /f "tokens=3 delims= " %%A in ("%size_videos%") do (
    set size_videosQ="%%A"
)

set "size_videos=%size_videosQ:"=%"

for /f %%S in (
    'powershell -Command "%size_documents% + %size_pictures% + %size_videos%"'
) do (
    set "size_new_data=%%S"
)


rem ------------------------------------------------------------------------------


:: Get the total size of files in the directory Music

for /f "tokens=*" %%A in ('dir /s /a /-c "%dir_music%" ^| find "File(s)"') do (
    set "line=%%A"
    for /f "tokens=1,2 delims=," %%B in ("!line!") do set "size_music=%%B"
)

for /f "tokens=3 delims= " %%A in ("%size_music%") do (
    set size_musicQ="%%A"
)

set "size_music=%size_musicQ:"=%"

for /f %%S in (
    'powershell -Command "%size_documents% + %size_pictures% + %size_videos% + %size_music%"'
) do (
    set "size_new_data=%%S"
)

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_new_data% / 1GB, 2)"') do set gb=%%A

set size_new_data_GB=%gb%


rem ------------------------------------------------------------------------------


echo -------------------------------------------------------------------------------
echo    STORAGE     ::     Make sure there is enough free space on usb
echo -------------------------------------------------------------------------------
echo:

echo  New data          : %size_new_data% bytes \ %size_new_data_GB% GB
echo:


rem **********************************************************************************
rem   get the size of current data on usb 
rem **********************************************************************************


set dir_data_usb=%~d0\Syncronize\Data

set size_data_usbQ=""
set size_data_usb=""

set size_current_data_usb=""
set size_current_data_usb_GB=""

:: Get the total size of files in the directory Syncronize\Data on usb

for /f "tokens=*" %%A in ('dir /s /a /-c "%dir_data_usb%" ^| find "File(s)"') do (
    set "line=%%A"
    for /f "tokens=1,2 delims=," %%B in ("!line!") do set "size_data_usb=%%B"
)

for /f "tokens=3 delims= " %%A in ("%size_data_usb%") do (
    set size_data_usbQ="%%A"
)

set "size_data_usb=%size_data_usbQ:"=%"

set size_current_data_usb=%size_data_usb%

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_current_data_usb% / 1GB, 2)"') do set gb=%%A

set size_current_data_usb_GB=%gb%

echo  Current data      : %size_current_data_usb% bytes \ %size_current_data_usb_GB% GB
echo:


rem **********************************************************************************
rem   get the size of delta data
rem **********************************************************************************


set size_delta_data=""
set size_delta_data_GB=""

:: calculate delta size with powershell command

for /f %%i in (
  'powershell -Command "%size_new_data% - %size_current_data_usb%"'
) do (
  set "size_delta_data=%%i"
)

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_delta_data% / 1GB, 2)"') do set gb=%%A

set size_delta_data_GB=%gb%

echo  Delta data        : %size_delta_data% bytes \ %size_delta_data_GB% GB
echo:


rem **********************************************************************************
rem   get the size of free space on usb
rem **********************************************************************************


set drive=%~d0

set free_bytes="0"

set size_free_space_usb=""
set size_free_space_usb_GB=""

:: Get the size of free space on usb by querying WMI

for /f "tokens=1-3" %%n in ('"WMIC /node:"localhost" LOGICALDISK GET Name,Size,FreeSpace | find /i "!drive!""') do ( set free_bytes=%%n )

::remove trailing space character

if not "!free_bytes:~-1!"=="" (
    set "free_bytes=!free_bytes:~0,-1!"
)

set size_free_space_usb=%free_bytes%

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_free_space_usb% / 1GB, 2)"') do set gb=%%A

set size_free_space_usb_GB=%gb%

echo  Free space on usb : %size_free_space_usb% bytes \ %size_free_space_usb_GB% GB
echo:


rem **********************************************************************************
rem   free space on usb >= delta data then continue script
rem **********************************************************************************

set continue_script=""

::evaluate of free space on usb >= size of delta data with powershell command
 
for /f %%i in (
  'powershell -Command "%size_free_space_usb% -gt %size_delta_data%"'
) do (
  set "continue_script=%%i"
)

echo  Free space on usb ^> delta data = %continue_script%
echo:
echo  Enough free space on usb : %continue_script%
echo:

if %use_timeout% == true ( timeout /t 5 > null )


rem ------------------------------------------------------------------------------


set size_c=""
set size_c_GB=""

for /f "tokens=1-3" %%n in ('"WMIC /node:"localhost" LOGICALDISK GET Name,Size,FreeSpace | find /i "C:""') do (set size_c=%%p)

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_c% / 1GB, 2)"') do set gb=%%A

set size_c_GB=%gb%

if %continue_script% == False ( 
    cls
    color 4
    goto begin_logo
    :end_logo_2
    echo:
    echo -------------------------------------------------------------------------------
    echo    STORAGE     ::     Make sure there is enough free space on the usb drive
    echo -------------------------------------------------------------------------------
    echo:
    echo  error : Not enough off free space on the usb drive. 
    echo:
    echo  info  : Please use another usb drive with capacity larger then %size_c_GB% GB.
    echo:
    powershell "[console]::beep(500,1000)"
    pause 
    del "%~d0\null"
    exit
)


rem *************************************************************************************************************************************************
rem   if source dir exist on pc then robocopy to destination dir on usb
rem *************************************************************************************************************************************************


echo -------------------------------------------------------------------------------
echo    PROBE     ::     Probe directories : Documents Pictures Videos Music
echo -------------------------------------------------------------------------------
echo:

if not exist "%USERPROFILE%\Documents" (
    echo  Directory not found "%USERPROFILE%\Documents"
    echo:
) else (
    echo  Directory "%USERPROFILE%\Documents" ok
    echo:
)

if not exist "%USERPROFILE%\Pictures" (
    echo  Directory not found "%USERPROFILE%\Pictures"
    echo:
) else (
    echo  Directory "%USERPROFILE%\Pictures" ok
    echo:
)

if not exist "%USERPROFILE%\Videos" (
    echo  Directory not found "%USERPROFILE%\Videos"
    echo:
) else (
    echo  Directory "%USERPROFILE%\Videos" ok
    echo:
)

if not exist "%USERPROFILE%\Music" (
    echo  Directory not found "%USERPROFILE%\Music"
    echo:
) else (
    echo  Directory "%USERPROFILE%\Music" ok
    echo:
)

echo  Starting syncronization . . .
if %use_timeout% == true ( timeout /t 5 > null )
echo:

echo -------------------------------------------------------------------------------
echo    SYNCRONIZE     ::     Syncronize directories : Documents Pictures Videos Music
echo -------------------------------------------------------------------------------

echo:
echo  Start syncronization %USERPROFILE%\Documents . . .
if %use_timeout% == true ( timeout /t 5 > null )

if exist "%USERPROFILE%\Documents" (
    robocopy %USERPROFILE%\Documents %~d0\Syncronize\Data\Documents /MIR /R:2 /W:5 /XJD /XF desktop.ini /LOG+:%~d0\Syncronize\Logs\Log1.log /TEE 
) else (
    echo:
    echo  Can not syncronize %USERPROFILE%\Documents 
    echo:
)

echo:
echo  Start syncronization %USERPROFILE%\Pictures . . .
if %use_timeout% == true ( timeout /t 5 > null )

if exist "%USERPROFILE%\Pictures" (
    robocopy %USERPROFILE%\Pictures %~d0\Syncronize\Data\Pictures /MIR /R:2 /W:5 /XJD /XF desktop.ini /LOG+:%~d0\Syncronize\Logs\Log1.log /TEE 
) else (
    echo:
    echo  Can not syncronize %USERPROFILE%\Pictures
    echo:
)

echo:
echo  Start syncronization %USERPROFILE%\Videos . . .
if %use_timeout% == true ( timeout /t 5 > null )

if exist "%USERPROFILE%\Videos" (
    robocopy %USERPROFILE%\Videos %~d0\Syncronize\Data\Videos /MIR /R:2 /W:5 /XJD /XF desktop.ini /LOG+:%~d0\Syncronize\Logs\Log1.log /TEE
) else (
    echo:
    echo  Can not syncronize %USERPROFILE%\Videos
    echo:
)

echo:
echo  Start syncronization %USERPROFILE%\Music . . .
if %use_timeout% == true ( timeout /t 5 > null )

if exist "%USERPROFILE%\Music" (
    robocopy %USERPROFILE%\Music %~d0\Syncronize\Data\Music /MIR /R:2 /W:5 /XJD /XF desktop.ini /LOG+:%~d0\Syncronize\Logs\Log1.log /TEE
)else (
    echo:
    echo  Can not syncronize %USERPROFILE%\Music
    echo:
)

if %use_timeout% == true ( timeout /t 5 > null )


rem *************************************************************************************************************************************************
rem   synchronization finished
rem *************************************************************************************************************************************************

echo -------------------------------------------------------------------------------
echo    SYNCRONIZATION     ::    Syncronization finished
echo -------------------------------------------------------------------------------
echo:

set exceptions="NO"

set present_documents=""
set present_pictures=""
set present_videos=""
set present_music=""

if not exist "%USERPROFILE%\Documents" (
    set exceptions="YES"
    set present_documents="NO"
)

if not exist "%USERPROFILE%\Pictures" (
    set exceptions="YES"
    set present_pictures="NO"
)

if not exist "%USERPROFILE%\Videos" (
    set exceptions="YES"
    set present_videos="NO"
)

if not exist "%USERPROFILE%\Music" (
    set exceptions="YES"
    set present_music="NO"
)

if %exceptions% == "NO" (
    echo  Syncronization completed
) else (
    echo  Syncronization finished with exceptions :
)

if %exceptions% == "YES" (
    if %present_documents% == "NO" (
        echo  No directory "%USERPROFILE%\Documents" to syncronize
    )
)

if %exceptions% == "YES" (
    if %present_pictures% == "NO" (
        echo  No directory "%USERPROFILE%\Pictures" to syncronize
    )
)

if %exceptions% == "YES" (
    if %present_videos% == "NO" (
        echo  No directory "%USERPROFILE%\Videos" to syncronize
    )
)

if %exceptions% == "YES" (
    if %present_music% == "NO" (
        echo  No directory "%USERPROFILE%\Music" to syncronize
    )
)


rem *************************************************************************************************************************************************
rem   end of script
rem *************************************************************************************************************************************************

echo:
echo -------------------------------------------------------------------------------
echo    END     ::    End of script
echo -------------------------------------------------------------------------------
echo:

if exist %~d0\null ( del %~d0\null )

powershell "[console]::beep(500,1000)"

pause

exit


rem *************************************************************************************************************************************************
rem   logo "SYNC FILES"
rem *************************************************************************************************************************************************


:begin_logo

:: logo_count is set at start of script to zero
set /a logo_count+=1

echo:
echo:
echo "           /$$$$$$  /$$     /$$ /$$   /$$  /$$$$$$  /$$$$$$$   /$$$$$$  /$$   /$$ /$$$$$$ /$$$$$$$$ /$$$$$$$$         "
echo "          /$$__  $$|  $$   /$$/| $$$ | $$ /$$__  $$| $$__  $$ /$$__  $$| $$$ | $$|_  $$_/|_____ $$ | $$_____/         "
echo "         | $$  \__/ \  $$ /$$/ | $$$$| $$| $$  \__/| $$  \ $$| $$  \ $$| $$$$| $$  | $$       /$$/ | $$               "
echo "         |  $$$$$$   \  $$$$/  | $$ $$ $$| $$      | $$$$$$$/| $$  | $$| $$ $$ $$  | $$      /$$/  | $$$$$            "
echo "          \____  $$   \  $$/   | $$  $$$$| $$      | $$__  $$| $$  | $$| $$  $$$$  | $$     /$$/   | $$__/            "
echo "          /$$  \ $$    | $$    | $$\  $$$| $$    $$| $$  \ $$| $$  | $$| $$\  $$$  | $$    /$$/    | $$               "
echo "         |  $$$$$$/    | $$    | $$ \  $$|  $$$$$$/| $$  | $$|  $$$$$$/| $$ \  $$ /$$$$$$ /$$$$$$$$| $$$$$$$$         "
echo "          \______/     |__/    |__/  \__/ \______/ |__/  |__/ \______/ |__/  \__/|______/|________/|________/         "
echo:

if %logo_count% == 1 (goto end_logo_1)
if %logo_count% == 2 (goto end_logo_2)


endlocal

pause

