#!/bin/bash
# Script para ejecutar Liquibase en Linux/Mac
# ===========================================

echo "Ejecutando Liquibase..."
echo

# Verificar que Java esté instalado
if ! command -v java &> /dev/null; then
    echo "ERROR: Java no está instalado o no está en el PATH"
    echo "Por favor instala Java JDK 11 o superior"
    exit 1
fi

# Verificar que el driver PostgreSQL existe
if [ ! -f "DRIVERS/postgresql-42.7.10.jar" ]; then
    echo "ERROR: Driver PostgreSQL no encontrado en DRIVERS/"
    echo "Descarga el driver desde: https://jdbc.postgresql.org/"
    exit 1
fi

# Ejecutar comando Liquibase
echo "Ejecutando migraciones..."
java -cp "DRIVERS/postgresql-42.7.10.jar" liquibase.integration.commandline.Main --defaultsFile=liquibase.properties "$@"

echo
echo "Proceso completado."