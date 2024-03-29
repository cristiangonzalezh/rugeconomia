# Base de datos del Registro Único de Garantías Mobiliarias de la Secretaria de Economia.

Repositorio de scripts de base de datos del proyecto del Registro Único de Garantías Mobiliarias de la Secretaria de Economia.

## Especificaciones Técnicas

### Documentación

- En la carpeta `documentacion`, se debe almacenar el diccionario de datos, diagrama entidad - relacion y documentación necesaria para su gestión.

### Versionamiento

- Para la carpeta `database`, se deben generar los archivos `.sql` correspondientes a la creación de la base de datos, usuarios y permisos otorgados. El nombre de los scripts deben ser nombrados con base a un nombre alfanumérico, para su correcta ejecución en el contenedor de forma local.

> Los scripts de la carpeta `database` se ejecutarán de forma manual en los servidores destinados para integrar y validar el producto de software.

- Para la carpeta `schema`, se deben almacenar los scripts de migración donde se muestran los cambios de la base de datos a través del tiempo, seguirán la nomenclatura definida por el producto de Flyway.
  
    [SQL-based migrations](https://flywaydb.org/documentation/concepts/migrations#sql-based-migrations)

Para llevar un mejor seguimiento de la base de datos, se deben seguir las siguientes convenciones:

- Prefijo: V para migración, R para script repetible 
- Versión: Número entero consecutivo.
- Separator: Dos caracteres de guion bajo (__).
- Description: Nombre del identificador de la actividad registrada en OpenProject, cada palabra separada por un guion bajo.
- Sufijo: .sql

Ejemplo:

- Prefijo: V
- Versión: 2
- Separator: __ 
- Description: HU_00000_Actualización__[objeto base datos]
- Sufijo: .sql

**Nombre del script**: V2__HU_0000_Actualización_tablas.sql
**Nombre del script**: R__HU_0000_Actualización_vistas.sql

## Tecnologías Implementadas y Versiones

En la siguiente sección se enlistan las tecnologías a utilizar en el proyecto.

### Visión General

| Tecnología                    | Descripción    |
| ----------------------------- | -------------- |
| Migraciones                   | Flyway         |
| Base de datos                 | PostgreSQL     |
| Implementación                | Docker         |
| Herramienta de implementación | Docker compose |

### Migraciones

| Tecnología                                                     | Versión | Descripción                                                                 |
| -------------------------------------------------------------- | ------- | --------------------------------------------------------------------------- |
| <a href="https://www.red-gate.com/products/flyway/">Flyway</a> | 9.14.1  | Flyway es una herramienta de migración de bases de datos de código abierto. |

Cuando se ejecuta flyway para realizar una migración de sql, se realiza las siguiente comprobaciones:

- Se crea la tabla donde se guarda la información de las migraciones (**flyway_schema_history**).
- Se analiza los archivos de la migración.
- Se comparan los archivos con respecto a las migraciones pasadas, si ha habido cambios en los archivos de versiones anteriores fallará la migración.
- Los nuevos scripts de migración serán ejecutados y se añadirá la información de los nuevos scripts.

### Base de Datos

| Tecnología                                 | Versión | Descripción                                                                         |
| ------------------------------------------ | ------- | ----------------------------------------------------------------------------------- |
| <a href="https://www.postgresql.org/">PostgreSQL</a> | 15.2 | Sistema de gestión de bases de datos relacional orientado a objetos y de código abierto. |

### Implementación

| Tecnología                                                       | Versión   | Descripción                                                                                                                                                                                                                                            |
| ---------------------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Docker Community Edition (CE)](https://docs.docker.com/engine/) | 20.10.22+ | Proyecto de código abierto que automatiza el despliegue de aplicaciones dentro de contenedores de software, proporcionando una capa adicional de abstracción y automatización de virtualización de aplicaciones en múltiples sistemas operativos.<br/> |
| [Docker compose](https://docs.docker.com/compose/)               | 1.26.1+   | Es una herramienta para definir y ejecutar aplicaciones Docker de varios contenedores.<br/>                                                                                                                                                            |

## Estructura de archivos y carpetas

El proyecto tendrá una estructura de carpetas particular. A continuación se muestra un ejemplo representativo:

### Estructura del proyecto

```console
.
├── database
├── deploy
│   └── docker
│       └── .env
├── documentacion
├── schema
├── CHANGELOG.md
├── docker-compose.yml
├── .dockerignore
├── .gitignore
└── README.md
```

### Carpetas

- `database` - Carpeta que almacenará los scripts que generen la base de datos, además de crear los usuarios y permisos definidos para el uso de la base de datos.
- `deploy` - Carpeta para almacenar las configuraciones del Flyway.
- `documentacion` - Carpeta para almacenar diccionario de datos, diagrama entidad de relacion y documentacion adicional sobre la base de Datos.
- `schema` - Carpeta que almacenará los scripts de migraciones de la base de datos.

### Archivos

- `.env` - Archivo de propiedades para configurar la conexión del Flyway con la base de datos.
- `CHANGELOG.md` -  Archivo con todos los cambios notables del proyecto.
- `docker-compose.yml` - Archivo para la ejecución del contenedor de PostgreSQL y Flyway donde se ejecutará la migración SQL.
- `README.md` - Archivo con lineamientos generales del proyecto.
- `afterMigrate__*` - Archivos que se ejecutan después de realizar todas las migraciones de manera exitosas.

> En el archivo `docker-compose.yml` se encuentran definidos las configuraciones para levantar los servicios antes mencionados.
> Por default, la definición de volumen para la persistencia de los datos de PostgreSQL se encontrará comentado, por lo tanto, para hacer uso de la persistencia, se debe des-comentar la siguiente línea:
> 
> ```yml
> #- ./data:/var/lib/mysql # Persistencia de datos
> ```

## Proyecto

### Clonar repositorio

Clonar un repositorio extrae una copia integral de todos los datos del mismo que `GitLab` tiene en ese momento, incluyendo todas las versiones para cada archivo y carpeta para el proyecto. 

Ejecutando el siguiente comando:

```console
git clone https://github.com/cristiangonzalezh/rugeconomia.git
```

### Iniciar servicios en local

Para levantar el contenedor de base de datos y ejecutar las migraciones con Flyway, se debe realizar de la siguiente forma:

```console
docker-compose up -d
```

> Para ver los logs de Flyway, se ejecuta el siguiente comando:
> `docker-compose logs flyway`

> Para visualizar los logs en tiempo, se agrega la opción `--follow`
> `docker-compose logs --follow flyway`

> Si Flyway no puede conectarse a la base de datos, es probable que:
> - Ocurriera un error en los scripts de la carpeta `database` que generan la base y usuarios a utilizar.
> - Los parámetros de conexión (archivo **.env**) no sean los correctos con forme a los definidos en los scripts de inicialización.

### Detener servicios en local

Para detener los servicios de las herramientas de Flyway y PostgreSQL, se ejecuta el siguiente comando:

```console
docker-compose stop
```
> Para mayor información sobre el comando, puede consultar la documentación en [Command-line reference](https://docs.docker.com/engine/reference/commandline/compose/)

### Eliminar servicios en local

Para eliminar los servicios de las herramientas de Flyway y PostgreSQL, se ejecuta el siguiente comando:

```console
docker-compose down
```

> Esta acción además de detener los servicios, elimina los datos dentro del contenedor. Si se requiere persistir la información, es recomendable habilitar los volúmenes necesarios dentro del archivo `docker-compose.yml`.

## Datos de conexión en local

Los datos por default para conexión a la base de datos fuera del contenedor son:

- Host: localhost
- Puerto: 5433
- Base de datos: economiarug
- Usuarios
  - Administrador
    - Usuario: root
    - Contraseña: J2nwKw@721s&
  - Aplicación
    - Usuario: ruguser
    - Contraseña: O0S#7Jh9p6r7

> Se puede utilizar cualquier cliente de base de datos para conectarse.

## Propiedades del proyecto

Se debe contemplar los siguientes valores como variables de entorno para la configuración del proyecto:

| Nombre                 | Valor por default                   | Descripción                                                                                                                   |
| ---------------------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| FLYWAY_URL             | jdbc:postgresql://economiarug-db:5432/economiarug | Cadena de conexión utilizada por Flyway para conectarse a la base de datos y ejecutar los scripts de migración.               |
| FLYWAY_USER            | root                                | Usuario con permisos de administrador para ejecutar la creación de la base de datos junto con todos los objetos relacionados. |
| FLYWAY_PASSWORD        | J2nwKw@721s&                        | Contraseña del usuario con permisos de administrador.                                                                         |
| FLYWAY_CONNECT_RETRIES | 10                                  | Número de intentos para conectarse a la base de datos.                                                                        |

> Se pueden incorporar propiedades que no se han especificado con forme al manejo del producto de Flyway.
