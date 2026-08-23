@echo off
setlocal EnableExtensions

rem ============================================================
rem ComfyUI_testUpdator.bat
rem
rem 1. Clone ComfyUI_windows_portable to ComfyUI_windows_portable_test
rem 2. Exclude models / input / output from copy
rem 3. Create junctions to the original folders
rem 4. Run the stable ComfyUI updater inside the test environment
rem
rem Place this BAT next to ComfyUI_windows_portable.
rem ============================================================

set "BASE=%~dp0"
set "SRC=%BASE%ComfyUI_windows_portable"
set "DST=%BASE%ComfyUI_windows_portable_test"

set "SRC_MODELS=%SRC%\ComfyUI\models"
set "SRC_INPUT=%SRC%\ComfyUI\input"
set "SRC_OUTPUT=%SRC%\ComfyUI\output"

set "DST_COMFYUI=%DST%\ComfyUI"
set "STABLE_UPDATER=%DST%\update\update_comfyui_stable.bat"

echo.
echo ============================================================
echo ComfyUI Test Environment Updater
echo ============================================================
echo Source      : %SRC%
echo Destination : %DST%
echo.

rem ------------------------------------------------------------
rem Validate source
rem ------------------------------------------------------------

if not exist "%SRC%\" (
    echo [ERROR] Source folder was not found:
    echo         %SRC%
    goto :failed
)

if not exist "%SRC_MODELS%\" (
    echo [ERROR] models folder was not found:
    echo         %SRC_MODELS%
    goto :failed
)

if not exist "%SRC_INPUT%\" (
    echo [ERROR] input folder was not found:
    echo         %SRC_INPUT%
    goto :failed
)

if not exist "%SRC_OUTPUT%\" (
    echo [ERROR] output folder was not found:
    echo         %SRC_OUTPUT%
    goto :failed
)

rem ------------------------------------------------------------
rem Do not overwrite an existing test environment
rem ------------------------------------------------------------

if exist "%DST%\" (
    echo [ERROR] Destination already exists:
    echo         %DST%
    echo.
    echo Rename or delete the existing test environment first.
    goto :failed
)

rem ------------------------------------------------------------
rem Clone portable environment, excluding shared folders
rem ------------------------------------------------------------

echo [1/5] Cloning ComfyUI portable environment...
echo       Excluding models, input and output.
echo.

robocopy "%SRC%" "%DST%" /E /COPY:DAT /DCOPY:DAT /R:2 /W:1 ^
    /XD "%SRC_MODELS%" "%SRC_INPUT%" "%SRC_OUTPUT%"

set "ROBOCOPY_EXIT=%ERRORLEVEL%"

rem Robocopy exit codes 0-7 mean success or non-fatal differences.
if %ROBOCOPY_EXIT% GEQ 8 (
    echo.
    echo [ERROR] Robocopy failed. Exit code: %ROBOCOPY_EXIT%
    goto :partial_failure
)

if not exist "%DST_COMFYUI%\" (
    echo.
    echo [ERROR] Destination ComfyUI folder was not created.
    goto :partial_failure
)

rem ------------------------------------------------------------
rem Create junctions
rem ------------------------------------------------------------

echo.
echo [2/5] Creating models junction...
mklink /J "%DST_COMFYUI%\models" "%SRC_MODELS%"
if errorlevel 1 goto :partial_failure

echo.
echo [3/5] Creating input junction...
mklink /J "%DST_COMFYUI%\input" "%SRC_INPUT%"
if errorlevel 1 goto :partial_failure

echo.
echo [4/5] Creating output junction...
mklink /J "%DST_COMFYUI%\output" "%SRC_OUTPUT%"
if errorlevel 1 goto :partial_failure

rem ------------------------------------------------------------
rem Validate stable updater
rem ------------------------------------------------------------

if not exist "%STABLE_UPDATER%" (
    echo.
    echo [ERROR] Stable updater was not found:
    echo         %STABLE_UPDATER%
    echo.
    echo The test environment was created successfully,
    echo but ComfyUI was NOT updated.
    goto :failed
)

rem ------------------------------------------------------------
rem Run stable updater in test environment
rem ------------------------------------------------------------

echo.
echo [5/5] Running ComfyUI stable updater...
echo.
echo ------------------------------------------------------------
echo %STABLE_UPDATER%
echo ------------------------------------------------------------
echo.

pushd "%DST%\update"
call "%STABLE_UPDATER%"
set "UPDATE_EXIT=%ERRORLEVEL%"
popd

if not "%UPDATE_EXIT%"=="0" (
    echo.
    echo ============================================================
    echo WARNING
    echo ============================================================
    echo The test environment was created, but the stable updater
    echo returned exit code %UPDATE_EXIT%.
    echo.
    echo Test environment:
    echo   %DST%
    echo.
    echo The original ComfyUI environment was not modified.
    echo.
    pause
    exit /b %UPDATE_EXIT%
)

echo.
echo ============================================================
echo SUCCESS
echo ============================================================
echo.
echo Test environment created and updated:
echo   %DST%
echo.
echo Shared by junction:
echo   models ^> %SRC_MODELS%
echo   input  ^> %SRC_INPUT%
echo   output ^> %SRC_OUTPUT%
echo.
echo The original ComfyUI_windows_portable environment
echo was not updated or modified by this BAT.
echo.
pause
exit /b 0


:partial_failure
echo.
echo ============================================================
echo ERROR
echo ============================================================
echo Creation of the test environment failed.
echo.
echo A partially created folder may remain:
echo   %DST%
echo.
echo For safety, this BAT will NOT delete it automatically.
echo Delete or rename it manually before running this BAT again.
goto :failed


:failed
echo.
echo Operation aborted.
echo.
pause
exit /b 1
