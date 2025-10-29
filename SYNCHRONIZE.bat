rem *************************************************************************************************************************************************
rem   Script Name : SYNCRONIZE.bat                                     
rem   Author      : Luc Baeten                                              
rem   Created On  : 18-10-2025
rem   Description : This batch script allows Windows users to quickly and easily mirror their Windows personal directories onto a USB drive.
rem *************************************************************************************************************************************************


@echo off

setlocal

setlocal enabledelayedexpansion

mode con: cols=120 lines=40

title SYNCRONIZE


rem *************************************************************************************************************************************************
rem   set output color
rem *************************************************************************************************************************************************


set "output_color=6"

rem     0 = Black       8 = Gray
rem     1 = Blue        9 = Light Blue
rem     2 = Green       A = Light Green
rem     3 = Aqua        B = Light Aqua
rem     4 = Red         C = Light Red
rem     5 = Purple      D = Light Purple
rem     6 = Yellow      E = Light Yellow
rem     7 = White       F = Bright White

color %output_color%   


rem *************************************************************************************************************************************************
rem   prompt [y/n] for timeout
rem *************************************************************************************************************************************************


set "input="
set "use_timeout="

:prompt

cls
set /p "input=Run script with delays [y/n] : "
if /i "%input%" == "y" ( set "use_timeout=true" & goto next )
if /i "%input%" == "n" ( goto next )  
goto prompt

:next


rem *************************************************************************************************************************************************
rem   Show logo in the header
rem *************************************************************************************************************************************************


cls
call :logo

set "colors=9 8 7 6 5 4 3 2 9 8 7 6 5 4 3 2"

if "%use_timeout%" == "true" ( 
    for %%c in (%colors%) do ( 
        color %%c
        for /l %%w in (1,1,5000) do (
        set "wait=%%w"
        )
    ) 
color %output_color%                                
if "%use_timeout%" == "true" ( timeout /t 2 > null )
)


rem *************************************************************************************************************************************************
rem   validate user and computer
rem *************************************************************************************************************************************************


echo:
echo -------------------------------------------------------------------------------
echo    VALIDATE     ::     Validate user and computer
echo -------------------------------------------------------------------------------
echo:

if "%use_timeout%" == "true" ( timeout /t 2 > null )

set "dir_parent=%~dpn0"

set "dir_user=%dir_parent%\User"
set "dir_pc=%dir_parent%\Pc"

set "user_txt=%dir_user%\User.txt"
set "pc_txt=%dir_pc%\Pc.txt"

set "valid_user="
set "valid_pc="

set "validate="

if exist "%user_txt%" (
    for /f "usebackq tokens=*" %%A in ("%user_txt%") do (
        set "valid_user=%%~A"
    )
)

if exist "%pc_txt%" (
    for /f "usebackq tokens=*" %%A in ("%pc_txt%") do (
        set "valid_pc=%%~A"
    )
)

if not exist "%user_txt%" if not exist "%pc_txt%" (
    set "validate=init_user"
)

if exist "%user_txt%" (
    if "%USERNAME%"=="%valid_user%" (
        if exist "%pc_txt%" (
            if "%COMPUTERNAME%"=="%valid_pc%" (
                set "validate=valid_user"
            ) else (
                set "validate=invalid_user"
            )
        ) else (
            set "validate=invalid_user"
        )
    ) else (
        set "validate=invalid_user"
    )
)

if "%validate%" == "init_user" (
    echo  First syncronization for user "%USERNAME%" from computer "%COMPUTERNAME%"
    echo: 
    if "%use_timeout%" == "true" ( timeout /t 2 > null )
)

if "%validate%" == "valid_user" (
    echo  Next syncronization for user "%valid_user%" from computer "%valid_pc%"
    echo:
    if "%use_timeout%" == "true" ( timeout /t 2 > null )
) 

if "%validate%" == "invalid_user" ( goto error1 )

if not exist "%user_txt%" (
    mkdir "%dir_user%"
    echo %USERNAME%> "%User_txt%"
    attrib +h "%dir_parent%\User"
    echo  Save username "%USERNAME%" on usb "%user_txt%"
    echo:
)

if not exist "%pc_txt%" (
    mkdir "%dir_pc%"
    echo %COMPUTERNAME%> "%Pc_txt%"
    attrib +h "%dir_parent%\Pc"
    echo  Save computername "%COMPUTERNAME%" on usb "%pc_txt%"
    echo:
)


rem *************************************************************************************************************************************************
rem   if dir %dir_parent%\Logs does not exist then mkdir %dir_parent%\Logs on usb & rotate log files
rem *************************************************************************************************************************************************


set "dir_logs=%dir_parent%\Logs"
set "log1=%dir_logs%\Log1.log"
set "log2=%dir_logs%\Log2.log"
set "log3=%dir_logs%\Log3.log"
set "log4=%dir_logs%\Log4.log"
set "log5=%dir_logs%\Log5.log"

if not exist "%dir_logs%" (
    mkdir "%dir_logs%"
    echo -------------------------------------------------------------------------------
    echo    MAKE     ::     Make directories for logs and Data
    echo -------------------------------------------------------------------------------
    echo:
    echo  Make directory for logs on usb drive "%dir_logs%"
    echo:
)

if exist "%log5%" del "%log5%"

if exist "%log4%" ren "%log4%" "Log5.log"

if exist "%log3%" ren "%log3%" "Log4.log"

if exist "%log2%" ren "%log2%" "Log3.log"

if exist "%log1%" ren "%log1%" "Log2.log"


rem *************************************************************************************************************************************************
rem   if dir %dir_parent%\Data does not exist then mkdir %dir_parent%\Data on usb
rem *************************************************************************************************************************************************


if not exist "%dir_parent%\Data" (
    mkdir "%dir_parent%\Data"
    echo  Make directory for data on usb "%dir_parent%\Data"
    echo:
)


rem **********************************************************************************
rem   calculate the size of data to be synchronized
rem **********************************************************************************


set "size_documents="
set "size_pictures="
set "size_videos="
set "size_music="

set "size_new_data="
set "size_new_data_GB="

set "user_path=%USERPROFILE%"
set "directories=Documents Pictures Videos Music"
set "directory_path="

for %%F in (%directories%) do (
    set "directory_path=%user_path%\%%F"
    for /f "usebackq delims=" %%A in (`powershell -noprofile -command ^
        "if (Test-Path '!directory_path!') {(Get-ChildItem '!directory_path!' -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum} else {0}"`) do (
        set "size_%%F=%%A"
    )
    if "!size_%%F!" == "" ( set "size_%%F=0" )  
)

for /f %%S in ( 'powershell -Command "%size_Documents% + %size_Pictures% + %size_Videos% + %size_Music%"' ) do ( set "size_new_data=%%S" )

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_new_data% / 1GB, 2)"') do ( set "size_new_data_GB=%%A" )


echo -------------------------------------------------------------------------------
echo    STORAGE     ::     Make sure there is enough free space on usb
echo -------------------------------------------------------------------------------
echo:

echo  New data          : %size_new_data% bytes \ %size_new_data_GB% GB
echo:


rem **********************************************************************************
rem   get the size of data on the USB drive
rem **********************************************************************************


set "dir_data_usb=%dir_parent%\Data"

set "size_data_usb="
set "size_data_usb_GB="

for /f %%A in ('powershell -noprofile -command "(Get-ChildItem '%dir_data_usb%' -Recurse | Measure-Object -Property Length -Sum).Sum"') do ( set "size_data_usb=%%A" )

if "%size_data_usb%" == "" ( set "size_data_usb=0" )

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_data_usb% / 1GB, 2)"') do ( set "size_data_usb_GB=%%A" )

echo  Current data      : %size_data_usb% bytes \ %size_data_usb_GB% GB
echo:


rem **********************************************************************************
rem   calculate the size of delta data
rem **********************************************************************************


set "size_delta_data="
set "size_delta_data_GB="

for /f %%i in ('powershell -Command "%size_new_data% - %size_data_usb%"') do ( set "size_delta_data=%%i" )

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_delta_data% / 1GB, 2)"') do ( set "size_delta_data_GB=%%A" )

echo  Delta data        : %size_delta_data% bytes \ %size_delta_data_GB% GB
echo:


rem **********************************************************************************
rem   get the free space on the USB drive
rem **********************************************************************************


set "drive=%~d0"
set "drive=%drive::=%"

set "size_free_space_usb="
set "size_free_space_usb_GB="

for /f %%A in ('powershell -noprofile -command "(Get-PSDrive -Name "%drive%").Free"') do (set "size_free_space_usb=%%A")

if "%size_free_space_usb%" == "" ( set size_free_space_usb=0 ) 

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_free_space_usb% / 1GB, 2)"') do ( set "size_free_space_usb_GB=%%A" )

echo  Free space on usb : %size_free_space_usb% bytes \ %size_free_space_usb_GB% GB
echo:


rem **********************************************************************************
rem   free space on usb >= delta data then continue script
rem **********************************************************************************


set "continue_script="
 
for /f %%i in ('powershell -Command "%size_free_space_usb% -gt %size_delta_data%"') do (set "continue_script=%%i")

echo  Free space on usb ^> delta data = %continue_script%
echo:
echo  Enough free space on usb : %continue_script%
echo:

if "%use_timeout%" == "true" ( timeout /t 5 > null )   

if "%continue_script%" == "False" ( goto error2 )        


rem *************************************************************************************************************************************************
rem   probe directories Documents Pictures Videos Music
rem *************************************************************************************************************************************************


echo -------------------------------------------------------------------------------
echo    PROBE     ::     Probe directories : Documents Pictures Videos Music
echo -------------------------------------------------------------------------------
echo:


for %%D in (Documents Pictures Videos Music) do (
    if not exist "%USERPROFILE%\%%D" (
        echo  Directory "%USERPROFILE%\%%D" not found
        echo:
    ) else (
        echo  Directory "%USERPROFILE%\%%D" ok
        echo:
    )
)


rem *************************************************************************************************************************************************
rem   synchronize directories met robocopy
rem *************************************************************************************************************************************************


echo  Starting syncronization . . .
if "%use_timeout%" == "true" ( timeout /t 5 > null )
echo:

echo -------------------------------------------------------------------------------
echo    SYNCRONIZE     ::     Syncronize directories : Documents Pictures Videos Music
echo -------------------------------------------------------------------------------


for %%D in (Documents Pictures Videos Music) do (
    if exist "%USERPROFILE%\%%D" (
        echo:
        echo  Start syncronization %USERPROFILE%\%%D . . .
        if "%use_timeout%" == "true" ( timeout /t 5 > null )
        robocopy "%USERPROFILE%\%%D" "%dir_parent%\Data\%%D" /MIR /FFT /R:2 /W:5 /XJD /LOG+:"%dir_parent%\Logs\Log1.log" /TEE 
        )
)

if "%use_timeout%" == "true" ( timeout /t 5 > null )


rem *************************************************************************************************************************************************
rem   synchronization finished
rem *************************************************************************************************************************************************


echo -------------------------------------------------------------------------------
echo    SYNCRONIZATION     ::    Syncronization finished
echo -------------------------------------------------------------------------------
echo:

set "exceptions=NO"

set "exist_Documents="
set "exist_Pictures="
set "exist_Videos="
set "exist_Music="

for %%D in (Documents Pictures Videos Music) do (
    if not exist "%USERPROFILE%\%%D" (
        set "exceptions=YES"
        set "exist_%%D=NO"
    )
)

if "%exceptions%" == "NO" (
    echo  Syncronization completed
) else (
    echo  Syncronization finished with exceptions :
)

for %%D in (Documents Pictures Videos Music) do (
    if "%exceptions%" == "YES" (
           if "!exist_%%D!" == "NO" (
               echo  No directory "%USERPROFILE%\%%D" to syncronize
               )
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
echo:

if exist %~d0\null ( del %~d0\null )

powershell "[console]::beep(500,1000)"

endlocal 

pause

exit








rem *************************************************************************************************************************************************
rem   subroutine logo 
rem *************************************************************************************************************************************************


:logo
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
exit /b


rem *************************************************************************************************************************************************
rem   label error 1
rem *************************************************************************************************************************************************


:error1
cls
color 4
call :logo
echo:
echo  error : The USB contains syncronized data from a different user or computer!
echo:
echo            Saved user : %valid_user%
echo            Saved host : %valid_pc%
echo:
echo            New user   : %USERNAME%   
echo            New host   : %COMPUTERNAME%
echo:
echo  info  : To proceed with the new user and remove existing synchronized data:
echo:
echo            1. Delete directory "%dir_parent%" on the USB.
echo            2. Restart the script.
echo:
echo          To synchronize multiple users on the same USB while keeping their data:
echo:
echo            1. Copy and rename the batch script for each user ^( for example John^_SYNC^.bat^, Alice^_SYNC^.bat^ )^.
echo            2. Run the renamed script for each user.
echo:
powershell "[console]::beep(500,1000)"
echo:
pause 
del "%~d0\null"
exit


rem *************************************************************************************************************************************************
rem   label error 2
rem *************************************************************************************************************************************************


:error2

set "free_c="
set "used_c="

set "size_c="
set "size_c_gb="

for /f "usebackq tokens=1" %%A in (`powershell -noprofile -command "(Get-PSDrive -Name C).Free"`) do ( set "free_c=%%A" )

for /f "usebackq tokens=1" %%A in (`powershell -noprofile -command "(Get-PSDrive -Name C).Used"`) do ( set "used_c=%%A" )

for /f %%A in ('powershell -Command "%free_c% + %used_c%"') do ( set "size_c=%%A" )

for /f "delims=" %%A in ('powershell -Command "[math]::Round(%size_c% / 1GB, 2)"') do ( set "size_c_gb=%%A" )

cls 
color 4
call :logo
echo:
echo  error : Not enough off free space on the usb drive. 
echo:
echo  info  : Please use another usb drive with capacity larger then %size_c_gb% GB.
echo:
powershell "[console]::beep(500,1000)"
echo:
pause 
del "%~d0\null"
exit

