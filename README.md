# 📁 Carpeta DB - Sistema de Migraciones de Base de Datos

Esta carpeta contiene todo el sistema de migraciones de base de datos utilizando **Liquibase** para PostgreSQL. Gestiona la evolución del esquema de la base de datos de manera controlada y versionada.

## 🏗️ Arquitectura General

La estructura está organizada siguiendo las mejores prácticas de Liquibase:

```
DB/
├── changelog.yml              # Archivo maestro de cambios
├── liquibase.properties       # Configuración de conexión BD
├── run-liquibase.bat          # Script Windows para ejecutar migraciones
├── run-liquibase.sh           # Script Linux/Mac para ejecutar migraciones
├── .gitignore                 # Archivos ignorados por Git
├── CHANGES/                   # Scripts de cambios forward
│   ├── DDL/                   # Cambios en estructura (Data Definition Language)
│   │   ├── 00_EXTENCIONS/     # Extensiones de PostgreSQL
│   │   └── 01_TABLES/         # Creación de tablas
│   └── DML/                   # Cambios en datos (Data Manipulation Language)
│       └── 00-INSERTS/        # Datos iniciales
├── ROLLBACKS/                 # Scripts de reversión
│   ├── DDL/                   # Rollbacks de estructura
│   └── DML/                   # Rollbacks de datos
└── DRIVERS/                   # Controladores JDBC
    └── postgresql-42.7.10.jar # Driver PostgreSQL
```

## 📋 Componentes Principales

### 1. changelog.yml - Maestro de Cambios
Archivo de configuración principal que define el orden y las dependencias de todos los cambios de base de datos.

**Características:**
- Define 3 fases principales de migración
- Incluye estrategias de rollback para cada cambio
- Usa contextos y etiquetas para control granular
- Maneja errores con `failOnError: true`

### 2. liquibase.properties - Configuración
Archivo de propiedades que configura la conexión a PostgreSQL y parámetros de Liquibase.

**Configuración importante:**
- URL de conexión JDBC
- Credenciales de base de datos
- Ruta al archivo changelog
- Configuración del classpath para drivers

### 3. Scripts de Ejecución
- **run-liquibase.bat**: Para sistemas Windows
- **run-liquibase.sh**: Para Linux/Mac (requiere `chmod +x`)

### 4. Cambios Forward (CHANGES)
Scripts SQL que aplican los cambios a la base de datos:

#### DDL (Data Definition Language)
- **00_EXTENCIONS/extencion.sql**: Crea extensiones PostgreSQL necesarias
  - `pgcrypto`: Para funciones criptográficas y generación de UUIDs

- **01_TABLES/01-ddl-tables.sql**: Define la estructura de la base de datos
  - `usuario`: Tabla de usuarios con UUID como clave primaria
  - `tarea`: Tabla de tareas con estados y timestamps
  - `usuario_tarea`: Tabla de relación muchos-a-muchos para asignaciones

#### DML (Data Manipulation Language)
- **00-INSERTS/02-dml-tables.sql**: Inserta datos iniciales
  - Usuarios de ejemplo (Kevin Gómez, Skleiner Lopez)
  - Tareas de ejemplo con diferentes estados

### 5. Rollbacks (ROLLBACKS)
Scripts para revertir cambios en caso de errores:

#### DDL Rollbacks
- **00_TABLES/01-drop-tables.sql**: Elimina todas las tablas en orden correcto
  - Primero elimina tablas de relación, luego tablas principales

#### DML Rollbacks
- **00_INSERTS/02-drop-data.sql**: Elimina todos los datos insertados
  - Limpia datos de tablas en orden correcto

### 6. Drivers JDBC
- **postgresql-42.7.10.jar**: Controlador JDBC oficial de PostgreSQL
  - Versión 42.7.10 (última estable)
  - Compatible con PostgreSQL 9.4+

## 🔄 Flujo de Migración

### Fase 1: Extensiones (ID: 00-extensions)
```yaml
- Crear extensión pgcrypto
- Contexto: database-setup
- Etiquetas: extensions
```

### Fase 2: Estructura (ID: 01-create-tables)
```yaml
- Crear tablas usuario, tarea, usuario_tarea
- Contexto: database-setup
- Etiquetas: ddl,structure
- Rollback: Eliminar todas las tablas
```

### Fase 3: Datos Iniciales (ID: 02-insert-data)
```yaml
- Insertar usuarios y tareas de ejemplo
- Contexto: database-setup
- Etiquetas: dml,data-seeding
- Rollback: Eliminar todos los datos
```

## 🗃️ Esquema de Base de Datos

### Tabla `usuario`
```sql
CREATE TABLE usuario (
    usuario_id UUID PRIMARY KEY,           -- ID único generado automáticamente
    nombre VARCHAR(100) NOT NULL,          -- Nombre del usuario
    email VARCHAR(150) UNIQUE NOT NULL,    -- Email único
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
```

### Tabla `tarea`
```sql
CREATE TABLE tarea (
    tarea_id UUID PRIMARY KEY,             -- ID único generado automáticamente
    titulo VARCHAR(200) NOT NULL,          -- Título de la tarea
    descripcion TEXT,                      -- Descripción detallada
    estado VARCHAR(50) DEFAULT 'PENDIENTE', -- Estado: PENDIENTE/FINALIZADA
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Fecha de creación
);
```

### Tabla `usuario_tarea` (Relación)
```sql
CREATE TABLE usuario_tarea (
    usuario_id UUID,                       -- FK a usuario
    tarea_id UUID,                         -- FK a tarea
    PRIMARY KEY (usuario_id, tarea_id),    -- Clave compuesta
    CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id),
    CONSTRAINT fk_tarea FOREIGN KEY (tarea_id) REFERENCES tarea(tarea_id)
);
```

## 🚀 Cómo Usar

### Opción 1: Ejecutar desde Spring Boot (Recomendado)
```bash
# Desde el directorio del backend
cd ../Backend
mvn liquibase:update
```

### Opción 2: Ejecutar directamente desde DB (Standalone)
```bash
# Windows
run-liquibase.bat update

# Linux/Mac
./run-liquibase.sh update
```

### Verificar Estado
```bash
# Ver cambios aplicados
run-liquibase.bat status

# Ver historial de cambios
run-liquibase.bat history
```

### Rollback (si es necesario)
```bash
# Rollback al último changeset
run-liquibase.bat rollbackCount 1

# Rollback a una etiqueta específica
run-liquibase.bat rollbackToDate 2024-01-01
```

### Otros Comandos Útiles
```bash
# Generar SQL sin ejecutar (dry-run)
run-liquibase.bat updateSQL

# Validar changelog
run-liquibase.bat validate

# Limpiar checksums (para forzar re-ejecución)
run-liquibase.bat clearChecksums
```

## ⚙️ Configuración

### Base de Datos PostgreSQL
Antes de ejecutar las migraciones, asegúrate de tener PostgreSQL corriendo:

```sql
-- Crear base de datos
CREATE DATABASE taskdb;

-- Crear usuario (opcional)
CREATE USER taskuser WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE taskdb TO taskuser;
```

### Configuración Personalizada
Si necesitas cambiar la configuración de conexión, edita `liquibase.properties`:

```properties
# Cambia estos valores según tu setup
url: jdbc:postgresql://localhost:5432/taskdb
username: postgres
password: password
```

### Variables de Entorno
Para mayor seguridad, puedes usar variables de entorno:

```properties
username: ${DB_USERNAME}
password: ${DB_PASSWORD}
url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
```

## ⚙️ Configuración en Spring Boot

En `application.properties`:
```properties
# Configuración de Liquibase
spring.liquibase.change-log=classpath:db/changelog.yml
spring.liquibase.enabled=true

# Configuración de PostgreSQL
spring.datasource.url=jdbc:postgresql://localhost:5432/taskdb
spring.datasource.username=postgres
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=validate
```

## 🔒 Características de Seguridad

- **UUIDs**: Uso de identificadores únicos no secuenciales
- **Validaciones**: Constraints de integridad referencial
- **Rollback Seguro**: Estrategias de reversión para todos los cambios
- **Control de Versiones**: Seguimiento completo de cambios aplicados

## 📊 Datos de Ejemplo

### Usuarios
- Kevin Gómez (kevin@email.com)
- Skleiner Lopez (Skleiner@email.com)

### Tareas
- "Aprender Software" - Estudiar Docker (PENDIENTE)
- "Crear Aplicación" - Desarrollar frontend (FINALIZADA)

## 🛠️ Mantenimiento

### Convenciones de Nomenclatura
- **DDL**: `NN-descripción.sql` (01-ddl-tables.sql)
- **DML**: `NN-descripción.sql` (02-dml-tables.sql)
- **Changesets**: `NN-descripción` (01-create-tables)

## 📈 Beneficios de Esta Arquitectura

- **Versionado**: Control completo de versiones de BD
- **Reversible**: Rollbacks seguros para cualquier cambio
- **Incremental**: Cambios pequeños y controlados
- **Multi-entorno**: Contextos para diferentes ambientes
- **Auditable**: Historial completo de cambios aplicados
- **Colaborativo**: Compatible con control de versiones

## � Solución de Problemas

### Error: "Driver not found"
```bash
# Asegúrate de que el JAR del driver existe
ls -la DRIVERS/
# Si no existe, descarga desde: https://jdbc.postgresql.org/
```

### Error: "Connection refused"
```bash
# Verifica que PostgreSQL esté corriendo
sudo systemctl status postgresql

# Verifica la configuración de conexión en liquibase.properties
```

### Error: "Checksum validation failed"
```bash
# Limpia los checksums y re-ejecuta
run-liquibase.bat clearChecksums
run-liquibase.bat update
```

### Error: "Changeset already executed"
```bash
# Para forzar re-ejecución (cuidado con datos)
run-liquibase.bat update --force
```

### Ver Logs Detallados
```bash
# Agrega logging detallado
run-liquibase.bat update --logLevel=DEBUG
```

## �👥 Autor

Kevin Andrey Culma Gomez

