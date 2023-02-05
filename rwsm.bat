@echo off
setlocal enabledelayedexpansion
title RainWorld Save Manager

:: Setup save manager
set MAIN_DIR=%USERPROFILE%\AppData\LocalLow\Videocult\Rain World
set SAVE_DIR=%MAIN_DIR%\Saves
set SAVE_FILE=%MAIN_DIR%\sav

if not exist "%SAVE_DIR%" mkdir "%SAVE_DIR%"

:MENU
    cls
    set "MENU_OPTION="
    set "SWAP_SELECTION="
    set "BACKUP_SELECTION="
    echo Rain World Save Manager
    echo.
    echo    1  - Swap in save
    echo    2  - Backup
    echo   [q] - Exit
    echo.

    set /p MENU_OPTION="Option: "
    IF %MENU_OPTION%==1 GOTO SWAP
    IF %MENU_OPTION%==2 GOTO BACKUP
    GOTO END

:SWAP
    cls
    :: Gather save file paths
    set COUNT=0
    for %%x in ("%SAVE_DIR%\*") do (
    set /a COUNT+=1
    set CHOICE[!COUNT!]=%%x
    )

    :: Display options
    echo Which option do you want to swap with?
    echo.
    for /l %%x in (1,1,!COUNT!) do (
        echo   %%x - !CHOICE[%%x]:%SAVE_DIR%\=!
    )
    echo.

    :: Recieve options and check it exists
    set /p SWAP_OPTION="Option: "
    echo.
    IF exist !CHOICE[%SWAP_OPTION%]! (
        echo Selected !CHOICE[%SWAP_OPTION%]:%SAVE_DIR%\=!
        echo.
    ) ELSE (
        echo ERROR: Invalid choice %SWAP_OPTION%
        echo.
        pause
        GOTO END
    )

    :: Call backup function
    CALL :BACKUP_FUNCTION "!CHOICE[%SWAP_OPTION%]!"
    IF %ERRORLEVEL% NEQ 0 (
        echo ERROR: Failed to perform backup for swap
        echo.
        pause
        GOTO END
    )

    :: Perform swap
    echo Swapping in "!CHOICE[%SWAP_OPTION%]:%SAVE_DIR%\=!"
    copy "!CHOICE[%SWAP_OPTION%]!" "%SAVE_FILE%"
    echo.

    :: Return to menu
    pause
    GOTO MENU


:BACKUP
    cls
    :: Call backup function
    CALL :BACKUP_FUNCTION
    :: Return to menu
    pause
    GOTO MENU

:BACKUP_FUNCTION
    :: User prompt
    echo What do you wish to name your backup?
    echo.
    set /p BACKUP_NAME="Name your backup: "
    echo.

    :: Exit command if
    IF "%SAVE_DIR%\!BACKUP_NAME!"=="%~1" (
        echo ERROR: You cannot overwrite the swap file
        echo.
        EXIT /B 1
    )

    :: Check if backup is overridding
    IF exist "%SAVE_DIR%\!BACKUP_NAME!" (
        set /p CONFIRM_OVERWRITE="!BACKUP_NAME! already exists, are you sure you want to overwrite it (Y/[n])? "
        echo.
        IF /i "!CONFIRM_OVERWRITE!" neq "Y" EXIT /B 1
    )
    echo.
    echo Copying save to "%SAVE_DIR%\%BACKUP_NAME%"
    copy "%SAVE_FILE%" "%SAVE_DIR%\%BACKUP_NAME%"
    echo.
    EXIT /B 0

:END
    endlocal