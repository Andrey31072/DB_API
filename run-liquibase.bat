@echo off
REM Script para ejecutar Liquibase en Windows
REM ==========================================

echo Ejecutando Liquibase...
echo.

REM Verificar que Java esté instalado
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java no está instalado o no está en el PATH
    echo Por favor instala Java JDK 11 o superior
    pause
    exit /b 1
)

REM Verificar que el driver PostgreSQL existe
if not exist "DRIVERS\postgresql-42.7.10.jar" (
    echo ERROR: Driver PostgreSQL no encontrado en DRIVERS\
    echo Descarga el driver desde: https://jdbc.postgresql.org/
    pause
    exit /b 1
)

REM Ejecutar comando Liquibase
echo Ejecutando migraciones...
java -cp "DRIVERS/postgresql-42.7.10.jar" liquibase.integration.commandline.Main --defaultsFile=liquibase.properties %*

echo.
echo Proceso completado.
pause