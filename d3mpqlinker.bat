@echo off
Setlocal EnableDelayedExpansion

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

:: If error flag set, we do not have admin rights.
if '%errorlevel%' NEQ '0' (
:: launch 
	start-d3mpqlinker.vbs
	echo.&pause&goto:eof
)

:: Get current batch file directory
for /f %%i in ("%0") do set curpath=%%~dpi 
cd /d %curpath% 

:: includes the configuration
call config.bat

echo === D3MPQs Linker v0.3 by megablue===
echo D3FOLDER=!D3FOLDER!
echo Number of USB Drives to use = !TotalUSBDrive!
echo USBDRIVE1=!USBDRIVE!
echo USBDRIVE2=!USBDRIVE2!
echo USBDRIVE3=!USBDRIVE3!

IF !UseRAMDISK!==YES ( 
	echo Use RAMDISK = YES
	echo RAMDISK=!RAMDISK!
) else (
	echo Use RAMDISK = NO
)

echo.
echo Please make sure you had configured the script before running it!
echo Run notepad, drag config.bat to the notepad interface, configure as per instructions, save it!
echo.
echo Please make sure you make a backup for your Diablo III folder!
echo.
echo Use the script at your own risk! 
echo.
echo The script will now attempt to link the MPQ files according to your configuration.
SET /P ANSWER=Do you want to continue (Y/N)?
if /i {%ANSWER%}=={y} (goto :continue)
if /i {%ANSWER%}=={yes} (goto :continue)
goto :eof

:continue

if !SkipUSB!==YES (
	echo Skipping USB method and go for RAMDISK directly...
	if !UseRAMDISK!==YES (
		goto:PART3
	) else (
		echo Error: You must enable RAMDISK in order to skip directly to RAMDISK process.
		goto :eof
	)		
)


:PART1
set DESTDRIVE=!USBDRIVE!

set source=!D3FOLDER!\Data_D3\PC\MPQs\base
set dest=!DESTDRIVE!\base
set folderMode=YES
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\enUS
set dest=!DESTDRIVE!\enUS
set folderMode=YES
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\win
set dest=!DESTDRIVE!\win
set folderMode=YES
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\base-Win.mpq
set dest=!DESTDRIVE!\base-Win.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\ClientData.mpq
set dest=!DESTDRIVE!\ClientData.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\CoreData.mpq
set dest=!DESTDRIVE!\CoreData.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\enUS_Audio.mpq
set dest=!DESTDRIVE!\enUS_Audio.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

:PART2
if !TotalUSBDrive!==1 (
	set DESTDRIVE=!USBDRIVE!
)

if !TotalUSBDrive!==2 (
	set DESTDRIVE=!USBDRIVE2!
)

if !TotalUSBDrive!==3 (
	set DESTDRIVE=!USBDRIVE2!
)

set source=!D3FOLDER!\Data_D3\PC\MPQs\Texture.mpq
set dest=!DESTDRIVE!\Texture.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\enUS_Cutscene.mpq
set dest=!DESTDRIVE!\enUS_Cutscene.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\enUS_Text.mpq
set dest=!DESTDRIVE!\enUS_Text.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

set source=!D3FOLDER!\Data_D3\PC\MPQs\HLSLShaders.mpq
set dest=!DESTDRIVE!\HLSLShaders.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

:PART3
if !TotalUSBDrive!==1 (
	set DESTDRIVE=!USBDRIVE!
)
 
if !TotalUSBDrive!==2 (
	set DESTDRIVE=!USBDRIVE2!
)
 
if !TotalUSBDrive!==3 (
	set DESTDRIVE=!USBDRIVE3!
)

if !UseRAMDISK!==YES (
	set DESTDRIVE=!RAMDISK!
)

set source=!D3FOLDER!\Data_D3\PC\MPQs\Sound.mpq
set dest=!DESTDRIVE!\Sound.mpq
set folderMode=NO
call :d3link folderMode errorMsg errorFlag
IF %errorFlag%==YES goto:linkError

echo .
echo .
echo .
echo D3 MPQS has been successfully linked to your specified drives!

 :: ======================================
	:: pause the script and jump to end of file
 :: ======================================
echo.&pause&goto:eof


:linkError
echo Error: Failed - !errorMsg!
echo.&pause&goto:eof


 :: ======================================
 	:: function to copy and link file/folder with error detection
 :: ====================================== 
:d3link <folderMode> <errorMsg> <errorFlag>
(   

    :: set source=%~1
    :: set dest=%~2
    set folderMode=%~3
    set errorMsg=""
    set errorFlag=NO

    if !folderMode!==YES ( 
    	echo Folder mode 
    ) else ( 
    	echo File mode 
    )

    echo Source = !source!
    echo dest = !dest!

    if NOT EXIST "!source!" (
		set errorFlag=YES
		set errorMsg=:d3link: File or Folder deosn't exist 
		goto:d3linkEND
    )

    if !folderMode!==YES (

		XCOPY "!source!" "!dest!" /D /E /C /R /I /K /Y 
		if NOT EXIST "!dest!" (
			set errorFlag=YES
			set errorMsg=":d3link: Failed to XCOPY !source! to !dest!" 
			goto:d3linkEND
		)else (
			RMDIR "!source!" /S /Q
		)

		MKLINK /J "!source!" "!dest!"
		echo mklink result: %errorlevel%
		if '%errorlevel%' NEQ '0' (
			set errorFlag=YES
			set errorMsg=":d3link: Failed to MLINK /J !source! to !dest!" 
			goto:d3linkEND
		)

    ) else (
		
		COPY /Y "!source!" "!dest!"

		if NOT EXIST "!dest!" (
			set errorFlag=YES
			set errorMsg=":d3link: Failed to COPY !source! to !dest!" 
			goto:d3linkEND
		) else (
			DEL "!source!" /F /Q
		)

		MKLINK "!source!" "!dest!"
		echo mklink result: %errorlevel%
		if '%errorlevel%' NEQ '0' (
			set errorFlag=YES
			set errorMsg=":d3link: Failed to MLINK !source! to !dest!" 
			goto:d3linkEND
		)

    )

)
:d3linkEND
(
    set %~2=!errorMsg!
    set %~3=!errorFlag!
    exit /B
)


endlocal