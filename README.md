# Vendia — Sistema de Punto de Venta
## LogiMarket Perú S.A.

Sistema para registrar ventas por sede y consolidarlas en un servidor central.
Está compuesto por tres aplicaciones que se usan en un orden específico.

---

## Orden de uso

```
1. VendiaUpdater  →  servidor siempre encendido
2. VendiaApp      →  cajero usa durante todo el turno
3. VendiaSender   →  cajero usa solo al cerrar el turno
```

---

## 1. VendiaUpdater — Levantar el daemon (solo en el servidor central)

Esta app debe estar corriendo **antes** de que cualquier sede intente enviar ventas.
Es una aplicación de consola que queda vigilando una carpeta compartida en segundo plano.

**Requisitos previos:**

1. Crear la base de datos en MySQL una sola vez:
   ```sql
   CREATE DATABASE logimarket;
   ```
2. Crear la carpeta compartida que actuará como buzón de mensajes,
   por ejemplo `C:\Users\USER\Desktop\DATOS`.

**Configurar credenciales y ruta** en `VendiaUpdater/updater.properties`:
```properties
carpeta.datos=C:\\Users\\USER\\Desktop\\DATOS
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

Verás en consola:
```
  VendiaUpdater — LogiMarket Peru S.A.
  Carpeta DATOS : C:\Users\USER\Desktop\DATOS
  Polling (ms)  : 2000
  BD URL        : jdbc:mysql://localhost:3306/logimarket
  ...
Daemon activo. Presione ENTER para detener.
```

El daemon revisa la carpeta cada `intervalo.polling.ms` milisegundos buscando
archivos `.dat` nuevos. Por cada uno los inserta en MySQL (batch insert) y escribe
un archivo `.ack` con el mismo nombre base para confirmar al cliente.
La tabla `ventas` se crea automáticamente en MySQL si no existe.
Para detenerlo, presionar **ENTER**.

---

## 2. VendiaApp — Registrar ventas (en la computadora del cajero)

El cajero usa esta app durante todo el turno para registrar las ventas del día.
**No necesita internet ni conexión al servidor** — todo se guarda localmente.

**Ejecutar:**
```bash
cd VendiaApp
mvn javafx:run
```

**Operaciones disponibles:**

| Acción | Cómo hacerlo |
|--------|-------------|
| Registrar venta | Ingresar ID de vendedor y monto → botón "Registrar" |
| Buscar venta | Ingresar el ID de venta → botón "Buscar" |
| Modificar monto | Seleccionar venta en la tabla → ingresar nuevo monto → "Modificar" |
| Eliminar venta | Seleccionar venta en la tabla → botón "Eliminar" |

> Las ventas recién registradas aparecen con estado **P** (Pendiente).
> Las ventas eliminadas desaparecen de la tabla pero se conservan en el archivo con estado **X**.

---

## 3. VendiaSender — Enviar ventas al servidor (al cerrar el turno)

Al terminar el turno, el cajero abre esta app para enviar todas las ventas
pendientes al servidor central depositando un archivo en la carpeta compartida.

**Ejecutar:**
```bash
cd VendiaSender
mvn javafx:run
```

**Pasos dentro de la app:**

1. **Seleccionar el archivo de ventas** → botón "Examinar..." → buscar `ventas.dat`
   (se encuentra en la carpeta `VendiaApp/`)
2. **Seleccionar la carpeta compartida** → botón "Examinar carpeta..." → elegir
   la misma carpeta `DATOS\` configurada en VendiaUpdater
3. **Hacer clic en "Enviar al Servidor"**

Si todo va bien, verás en el log:
```
Escribiendo 5 registro(s) en ventas_20260518_143022.dat...
Archivo enviado. Esperando confirmacion del servidor...
ACK recibido: ventas_20260518_143022.ack
Envio confirmado: OK 5
Ventas marcadas como enviadas (estado=E) en ventas.dat.
```

Internamente VendiaSender escribe un archivo `ventas_<timestamp>.dat` en la carpeta
compartida y se queda haciendo polling hasta que VendiaUpdater deja un
`ventas_<timestamp>.ack` con la respuesta (timeout 30 s). Tras recibir un `OK`
las ventas cambian a estado **E** (Enviada) en `ventas.dat`.
Si se ejecuta dos veces por error, el servidor las ignora sin duplicarlas
gracias al `INSERT IGNORE` por clave primaria.

---

## Requisitos

| Herramienta | Versión mínima |
|-------------|---------------|
| Java JDK    | 21            |
| Maven       | 3.8           |
| MySQL       | 8.0 (solo en el servidor) |

---

## Más información

Para detalles técnicos sobre el protocolo de carpeta compartida, el formato binario
de los archivos y el esquema de la base de datos, ver [`SISTEMA.md`](SISTEMA.md).
