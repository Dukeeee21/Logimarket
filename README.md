# Vendia — Sistema de Punto de Venta
## LogiMarket Perú S.A. | Arquitectura MVC con N Capas

Sistema distribuido para registrar ventas por sede, consolidarlas en un servidor
central, replicarlas en un servidor Mirror y cargarlas en un DataWarehouse para
análisis OLAP. Implementa el patrón **MVC** en todas sus capas:

| MVC | Componente |
|-----|-----------|
| Modelo | Base de datos MySQL + repositorios JDBC |
| Vista | HTML + CSS + React (VendiaWeb) / JavaFX (VendiaApp) |
| Controlador | Spring Boot REST API (VendiaWeb) / controladores Java (VendiaApp) |

---

## Módulos del sistema

| Módulo | Capa | Descripción |
|--------|------|-------------|
| `VendiaApp` | Cliente | App de escritorio JavaFX para cajeros. Almacena ventas en archivos binarios locales |
| `VendiaSender` | FTP | Envía los archivos `.dat` al servidor por FTP o carpeta compartida |
| `VendiaUpdater` | Datos | Daemon que detecta archivos `.dat` e inserta en MySQL |
| `VendiaWeb` | Aplicación Web | Servidor web Spring Boot con API REST y frontend React |
| `GenerarDatawareHouse` | DataWarehouse | App JavaFX que realiza el ETL hacia el servidor DW |

---

## Orden de uso

```
1. VendiaUpdater        →  levantar primero (daemon en el Servidor de BD)
2. VendiaWeb            →  levantar en el Servidor de Aplicaciones
3. VendiaApp            →  cajero usa durante todo el turno
4. VendiaSender         →  cajero usa al cerrar el turno
5. GenerarDatawareHouse →  administrador ejecuta para actualizar el DW
```

---

## 1. VendiaUpdater — Daemon en el Servidor de BD

Debe estar corriendo **antes** de que cualquier sede intente enviar ventas.

**Requisitos previos:**

1. Crear la base de datos en MySQL (una sola vez):
   ```sql
   CREATE DATABASE logimarket;
   ```
2. Crear la carpeta compartida, por ejemplo `C:\Users\ADMIN\Desktop\DATOS`.

**Configurar** `VendiaUpdater/updater.properties`:
```properties
carpeta.datos=C:\\Users\\ADMIN\\Desktop\\DATOS
intervalo.polling.ms=2000
db.url=jdbc:mysql://localhost:3306/logimarket
db.usuario=root
db.password=tu_password
```

**Ejecutar:**
```bash
cd VendiaUpdater
mvn compile exec:java
```

El daemon revisa la carpeta cada `intervalo.polling.ms` ms. Por cada `.dat` nuevo
hace batch insert en MySQL y escribe un `.ack` de confirmación.
La tabla `ventas` se crea automáticamente. Detener con **ENTER**.

---

## 2. VendiaWeb — Servidor de Aplicaciones Web (MVC)

Servidor Spring Boot con API REST y frontend React. Se conecta directamente a MySQL.

**Configurar** `VendiaWeb/src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/logimarket
spring.datasource.username=root
spring.datasource.password=tu_password

mirror.datasource.url=jdbc:mysql://localhost:3307/logimarket_mirror
mirror.datasource.username=root
mirror.datasource.password=tu_password

server.port=8080
```

**Ejecutar backend (Spring Boot):**
```bash
cd VendiaWeb
mvn spring-boot:run
```

**Desarrollo frontend (React + Vite):**
```bash
cd VendiaWeb/frontend
npm install        # solo la primera vez
npm run dev        # servidor en http://localhost:5173 con proxy al backend
```

**Build frontend para producción** (genera los archivos que sirve Spring Boot):
```bash
cd VendiaWeb/frontend
npm run build
```

Luego abrir `http://localhost:8080` en el navegador.

**Endpoints REST disponibles:**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/ventas` | Lista todas las ventas activas |
| GET | `/api/ventas/{id}` | Busca una venta por ID |
| GET | `/api/ventas/estadisticas` | Total y pendientes |
| POST | `/api/ventas/registrar` | Registra una nueva venta |
| PUT | `/api/ventas/{id}/monto` | Modifica el monto (solo estado P) |
| DELETE | `/api/ventas/{id}` | Elimina lógicamente (solo estado P) |
| POST | `/api/mirror/sincronizar` | Replica datos al servidor Mirror |
| GET | `/api/mirror/estado` | Verifica conectividad del Mirror |

---

## 3. VendiaApp — Registrar ventas (computadora del cajero)

El cajero usa esta app durante todo el turno. **No requiere conexión al servidor.**

**Ejecutar:**
```bash
cd VendiaApp
mvn javafx:run
```

| Acción | Cómo hacerlo |
|--------|-------------|
| Registrar venta | ID de vendedor + monto → botón "Registrar" |
| Buscar venta | ID de venta → botón "Buscar" |
| Modificar monto | Seleccionar en tabla → nuevo monto → "Modificar" |
| Eliminar venta | Seleccionar en tabla → botón "Eliminar" |

> Las ventas nuevas tienen estado **P** (Pendiente). Solo las pendientes pueden modificarse o eliminarse.

---

## 4. VendiaSender — Enviar ventas al servidor (al cerrar el turno)

**Ejecutar:**
```bash
cd VendiaSender
mvn javafx:run
```

**Pasos dentro de la app:**

1. **Examinar...** → seleccionar `ventas.dat` (carpeta `VendiaApp/`)
2. **Examinar carpeta...** → seleccionar la carpeta `DATOS\` del Updater
3. **Enviar al Servidor**

Log esperado:
```
Escribiendo 5 registro(s) en ventas_20260615_143022.dat...
Archivo enviado. Esperando confirmacion del servidor...
ACK recibido: ventas_20260615_143022.ack
Envio confirmado: OK 5
Ventas marcadas como enviadas (estado=E) en ventas.dat.
```

---

## 5. GenerarDatawareHouse — Cargar el DataWarehouse

Ejecutado por el administrador cuando necesita datos actualizados para análisis.

**Ejecutar:**
```bash
cd GenerarDatawareHouse
mvn javafx:run
```

**Configurar** `GenerarDatawareHouse/dw.properties`:
```properties
bd.url=jdbc:mysql://localhost:3306/logimarket
bd.usuario=root
bd.password=tu_password

dw.url=jdbc:mysql://localhost:3306/logimarket_dw
dw.usuario=root
dw.password=tu_password
```

Los campos se precargan automáticamente desde `dw.properties` al abrir la app.
Presionar **"Generar DataWarehouse"**. El schema `logimarket_dw` y sus tablas se
crean automáticamente si no existen.

**Lo que hace el ETL:**
- Lee todas las ventas del Servidor de BD
- Agrupa por vendedor y mes → carga `dim_vendedor`, `dim_fecha`, `fact_ventas`
- Es idempotente: ejecutarlo varias veces no duplica datos

---

## Despliegue en Servidor de Aplicaciones

Los ejecutables deben copiarse a una carpeta compartida, por ejemplo:
```
C:\ServidorApps\Vendia\
├── VendiaApp\
├── VendiaSender\
├── VendiaWeb\
└── GenerarDatawareHouse\
```

Cada PC cliente crea **accesos directos** que apuntan a esa ruta de red.
El cliente actúa solo como unidad de procesamiento (CPU y RAM locales),
mientras los ejecutables y datos residen en el servidor.

> **Demo en una sola máquina:** crear la carpeta `C:\ServidorApps\Vendia\`,
> copiar los módulos ahí y usar accesos directos desde el escritorio.

---

## Requisitos

| Herramienta | Versión mínima | Dónde se usa |
|-------------|---------------|--------------|
| Java JDK    | 21            | Todos los módulos Java |
| Maven       | 3.8           | Todos los módulos Java |
| Node.js     | 18            | VendiaWeb / frontend React |
| npm         | 9             | VendiaWeb / frontend React |
| MySQL       | 8.0           | Servidor de BD, Mirror y DW |

---

## Estructura del proyecto

```
Vendia_V2/
├── VendiaApp/              # Cliente desktop JavaFX (cajero)
├── VendiaSender/           # Envío FTP / carpeta compartida
├── VendiaUpdater/          # Daemon servidor de BD
├── VendiaWeb/              # Servidor web Spring Boot + React
│   └── frontend/           # Proyecto React (Vite)
└── GenerarDatawareHouse/   # ETL hacia DataWarehouse
```

---

## Más información

- [`SISTEMA.md`](SISTEMA.md) — protocolo de archivos, formato binario, esquemas SQL
- [`JUSTIFICACION_DW.md`](JUSTIFICACION_DW.md) — por qué se usó MySQL para el DataWarehouse
