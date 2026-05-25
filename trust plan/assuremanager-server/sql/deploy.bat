@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM AssureManager Database Deployment Script
REM Windows Batch - SQL Server
REM ============================================================

echo ==========================================
echo  AssureManager Database Deploy
echo ==========================================
echo.

REM Parse arguments
set SERVER=%~1
set DB=%~2

REM Defaults
if "%~1"=="" set SERVER=localhost\ASSUREMANAGER
if "%~2"=="" set DB=AssureManagerDB

echo Server  : %SERVER%
echo Database: %DB%
echo.

REM Check sqlcmd exists
where sqlcmd >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: sqlcmd not found. Install SQL Server Command Line Utilities.
    pause
    exit /b 1
)

REM Script directory
set SCRIPTDIR=%~dp0

echo --- Step 1/7: Creating database ---
sqlcmd -S %SERVER% -b -i "%SCRIPTDIR%\01_create_database.sql"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Database creation failed!
    pause
    exit /b 1
)

echo --- Step 2/7: Creating schema ---
sqlcmd -S %SERVER% -d %DB% -b -i "%SCRIPTDIR%\02_schema.sql"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Schema creation failed!
    pause
    exit /b 1
)

echo --- Step 3/7: Applying constraints ---
sqlcmd -S %SERVER% -d %DB% -b -i "%SCRIPTDIR%\03_constraints.sql"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Constraint application failed!
    pause
    exit /b 1
)

echo --- Step 4/7: Inserting seed data ---
sqlcmd -S %SERVER% -d %DB% -b -i "%SCRIPTDIR%\04_seeds.sql"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Seed data insertion failed!
    pause
    exit /b 1
)

echo --- Step 5/7: Creating triggers ---
sqlcmd -S %SERVER% -d %DB% -b -i "%SCRIPTDIR%\05_triggers.sql"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Trigger creation failed!
    pause
    exit /b 1
)

echo --- Step 6/7: Creating stored procedures ---
sqlcmd -S %SERVER% -d %DB% -b -i "%SCRIPTDIR%\06_stored_procedures.sql"
if %ERRORLEVEL% neq 0 (
    echo ERROR: Stored procedure creation failed!
    pause
    exit /b 1
)

echo --- Step 7/7: Creating views ---
sqlcmd -S %SERVER% -d %DB% -b -i "%SCRIPTDIR%\07_views.sql"
if %ERRORLEVEL% neq 0 (
    echo ERROR: View creation failed!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo  Deployment complete!
echo  Database: %DB% on %SERVER%
echo ==========================================
pause
