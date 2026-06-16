-- ============================================================
--  DATOS DEMO — LogiMarket Perú S.A. — CUBO OLAP 3D
--  Dimensiones: Vendedor × Producto × Trimestre
--  Llena: logimarket, logimarket_mirror, logimarket_dw
--  Ejecutar:
--    Get-Content datos_demo.sql | & "C:\Program Files\MySQL\MySQL Server 9.7\bin\mysql.exe" -u root -pMachita_19631
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ════════════════════════════════════════════════════════════
--  1. BASE OPERACIONAL: logimarket
-- ════════════════════════════════════════════════════════════
CREATE DATABASE IF NOT EXISTS logimarket;
USE logimarket;

DROP TABLE IF EXISTS ventas;
CREATE TABLE ventas (
    id_venta     VARCHAR(20) PRIMARY KEY,
    id_vendedor  VARCHAR(20) NOT NULL,
    id_producto  VARCHAR(20) NOT NULL DEFAULT 'P001',
    fecha        VARCHAR(20) NOT NULL,
    monto_total  DOUBLE      NOT NULL,
    estado       CHAR(1)     NOT NULL DEFAULT 'E',
    recibido_en  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ventas (id_venta, id_vendedor, id_producto, fecha, monto_total, estado) VALUES
-- ── V001 · Carlos Rios — P001=Laptop, P002=Monitor, P003=Teclado ─────────
('VTA-001','V001','P001','2025-01-15 09:15',1250.00,'E'),
('VTA-002','V001','P001','2025-02-20 11:30',1430.00,'E'),
('VTA-003','V001','P001','2025-04-07 10:00',1380.00,'E'),
('VTA-004','V001','P001','2025-05-12 14:45',1650.00,'E'),
('VTA-005','V001','P001','2025-07-03 09:30',1200.00,'E'),
('VTA-006','V001','P001','2025-08-15 16:00',1750.00,'E'),
('VTA-007','V001','P001','2025-10-10 08:45',1550.00,'E'),
('VTA-008','V001','P001','2025-11-20 13:20',1100.00,'E'),
('VTA-009','V001','P002','2025-01-22 10:00', 980.00,'E'),
('VTA-010','V001','P002','2025-02-10 15:30', 760.00,'E'),
('VTA-011','V001','P002','2025-04-21 13:20', 920.00,'E'),
('VTA-012','V001','P002','2025-05-28 09:00', 840.00,'E'),
('VTA-013','V001','P002','2025-07-18 14:00', 990.00,'E'),
('VTA-014','V001','P002','2025-08-06 09:30', 870.00,'E'),
('VTA-015','V001','P002','2025-10-22 16:15',1100.00,'E'),
('VTA-016','V001','P002','2025-11-01 12:00', 930.00,'E'),
('VTA-017','V001','P003','2025-02-05 10:00', 280.00,'E'),
('VTA-018','V001','P003','2025-03-25 14:45', 350.00,'E'),
('VTA-019','V001','P003','2025-04-15 09:30', 290.00,'E'),
('VTA-020','V001','P003','2025-06-09 16:00', 380.00,'E'),
('VTA-021','V001','P003','2025-08-06 08:45', 310.00,'E'),
('VTA-022','V001','P003','2025-09-20 13:20', 340.00,'E'),
('VTA-023','V001','P003','2025-11-05 10:10', 360.00,'E'),
('VTA-024','V001','P003','2025-12-18 15:30', 295.00,'E'),

-- ── V002 · Maria Lopez — P001=Laptop, P004=Mouse, P005=Impresora ─────────
('VTA-025','V002','P001','2025-01-10 09:00',1300.00,'E'),
('VTA-026','V002','P001','2025-02-25 11:45',1200.00,'E'),
('VTA-027','V002','P001','2025-04-03 14:00',1450.00,'E'),
('VTA-028','V002','P001','2025-05-20 09:15',1350.00,'E'),
('VTA-029','V002','P001','2025-07-08 10:30',1250.00,'E'),
('VTA-030','V002','P001','2025-08-22 16:00',1350.00,'E'),
('VTA-031','V002','P001','2025-10-07 09:45',1400.00,'E'),
('VTA-032','V002','P001','2025-11-18 14:30',1500.00,'E'),
('VTA-033','V002','P004','2025-01-18 10:00', 150.00,'E'),
('VTA-034','V002','P004','2025-02-08 14:15', 130.00,'E'),
('VTA-035','V002','P004','2025-04-14 09:00', 160.00,'E'),
('VTA-036','V002','P004','2025-05-25 11:30', 150.00,'E'),
('VTA-037','V002','P004','2025-07-12 13:45', 145.00,'E'),
('VTA-038','V002','P004','2025-08-28 10:00', 145.00,'E'),
('VTA-039','V002','P004','2025-10-16 16:30', 160.00,'E'),
('VTA-040','V002','P004','2025-11-25 09:00', 160.00,'E'),
('VTA-041','V002','P005','2025-01-28 11:00', 680.00,'E'),
('VTA-042','V002','P005','2025-03-10 15:30', 670.00,'E'),
('VTA-043','V002','P005','2025-05-06 09:00', 720.00,'E'),
('VTA-044','V002','P005','2025-06-20 14:00', 780.00,'E'),
('VTA-045','V002','P005','2025-07-25 10:30', 690.00,'E'),
('VTA-046','V002','P005','2025-09-10 16:00', 690.00,'E'),
('VTA-047','V002','P005','2025-10-29 09:15', 710.00,'E'),
('VTA-048','V002','P005','2025-12-02 13:30', 710.00,'E'),

-- ── V003 · Juan Torres — P002=Monitor, P003=Teclado, P006=Auriculares ────
('VTA-049','V003','P002','2025-01-20 09:00', 850.00,'E'),
('VTA-050','V003','P002','2025-02-15 14:30', 850.00,'E'),
('VTA-051','V003','P002','2025-04-10 10:00', 900.00,'E'),
('VTA-052','V003','P002','2025-05-22 15:00', 900.00,'E'),
('VTA-053','V003','P002','2025-07-14 09:30', 820.00,'E'),
('VTA-054','V003','P002','2025-08-20 11:00', 830.00,'E'),
('VTA-055','V003','P002','2025-10-12 14:00', 950.00,'E'),
('VTA-056','V003','P002','2025-11-28 10:30', 950.00,'E'),
('VTA-057','V003','P003','2025-01-25 10:00', 300.00,'E'),
('VTA-058','V003','P003','2025-03-05 15:00', 300.00,'E'),
('VTA-059','V003','P003','2025-04-18 09:30', 310.00,'E'),
('VTA-060','V003','P003','2025-06-02 14:30', 310.00,'E'),
('VTA-061','V003','P003','2025-07-22 10:15', 290.00,'E'),
('VTA-062','V003','P003','2025-09-08 15:45', 290.00,'E'),
('VTA-063','V003','P003','2025-10-25 09:00', 320.00,'E'),
('VTA-064','V003','P003','2025-12-10 13:30', 320.00,'E'),
('VTA-065','V003','P006','2025-02-08 11:00', 250.00,'E'),
('VTA-066','V003','P006','2025-03-20 16:00', 250.00,'E'),
('VTA-067','V003','P006','2025-04-28 09:00', 260.00,'E'),
('VTA-068','V003','P006','2025-06-15 14:00', 260.00,'E'),
('VTA-069','V003','P006','2025-08-05 10:30', 240.00,'E'),
('VTA-070','V003','P006','2025-09-22 15:30', 240.00,'E'),
('VTA-071','V003','P006','2025-11-10 09:15', 255.00,'E'),
('VTA-072','V003','P006','2025-12-22 14:00', 255.00,'E'),

-- ── V004 · Ana Vargas — P001=Laptop, P005=Impresora, P006=Auriculares ────
('VTA-073','V004','P001','2025-01-12 09:00',1450.00,'E'),
('VTA-074','V004','P001','2025-02-26 14:30',1450.00,'E'),
('VTA-075','V004','P001','2025-04-04 10:00',1550.00,'E'),
('VTA-076','V004','P001','2025-05-16 15:00',1550.00,'E'),
('VTA-077','V004','P001','2025-07-09 09:30',1400.00,'E'),
('VTA-078','V004','P001','2025-08-21 11:00',1400.00,'E'),
('VTA-079','V004','P001','2025-10-14 14:00',1600.00,'E'),
('VTA-080','V004','P001','2025-11-24 10:30',1600.00,'E'),
('VTA-081','V004','P005','2025-01-30 11:00', 680.00,'E'),
('VTA-082','V004','P005','2025-03-14 15:00', 680.00,'E'),
('VTA-083','V004','P005','2025-05-08 09:00', 725.00,'E'),
('VTA-084','V004','P005','2025-06-22 14:00', 725.00,'E'),
('VTA-085','V004','P005','2025-07-28 10:30', 660.00,'E'),
('VTA-086','V004','P005','2025-09-12 16:00', 660.00,'E'),
('VTA-087','V004','P005','2025-10-31 09:15', 750.00,'E'),
('VTA-088','V004','P005','2025-12-08 13:30', 750.00,'E'),
('VTA-089','V004','P006','2025-02-12 11:00', 270.00,'E'),
('VTA-090','V004','P006','2025-03-26 16:00', 270.00,'E'),
('VTA-091','V004','P006','2025-05-02 09:00', 290.00,'E'),
('VTA-092','V004','P006','2025-06-18 14:00', 290.00,'E'),
('VTA-093','V004','P006','2025-08-08 10:30', 260.00,'E'),
('VTA-094','V004','P006','2025-09-24 15:30', 260.00,'E'),
('VTA-095','V004','P006','2025-11-14 09:15', 280.00,'E'),
('VTA-096','V004','P006','2025-12-26 14:00', 280.00,'E'),

-- ── V005 · Pedro Silva — P002=Monitor, P004=Mouse, P006=Auriculares ──────
('VTA-097','V005','P002','2025-01-17 09:00', 900.00,'E'),
('VTA-098','V005','P002','2025-02-28 14:30', 900.00,'E'),
('VTA-099','V005','P002','2025-04-15 10:00', 950.00,'E'),
('VTA-100','V005','P002','2025-05-24 15:00', 950.00,'E'),
('VTA-101','V005','P002','2025-07-18 09:30', 875.00,'E'),
('VTA-102','V005','P002','2025-08-26 11:00', 875.00,'E'),
('VTA-103','V005','P002','2025-10-18 14:00',1000.00,'E'),
('VTA-104','V005','P002','2025-11-28 10:30',1000.00,'E'),
('VTA-105','V005','P004','2025-01-24 10:00', 150.00,'E'),
('VTA-106','V005','P004','2025-03-08 15:00', 150.00,'E'),
('VTA-107','V005','P004','2025-04-22 09:30', 160.00,'E'),
('VTA-108','V005','P004','2025-06-05 14:30', 160.00,'E'),
('VTA-109','V005','P004','2025-07-26 10:15', 140.00,'E'),
('VTA-110','V005','P004','2025-09-14 15:45', 140.00,'E'),
('VTA-111','V005','P004','2025-10-28 09:00', 170.00,'E'),
('VTA-112','V005','P004','2025-12-12 13:30', 170.00,'E'),
('VTA-113','V005','P006','2025-02-18 11:00', 240.00,'E'),
('VTA-114','V005','P006','2025-03-30 16:00', 240.00,'E'),
('VTA-115','V005','P006','2025-05-12 09:00', 250.00,'E'),
('VTA-116','V005','P006','2025-06-25 14:00', 250.00,'E'),
('VTA-117','V005','P006','2025-08-12 10:30', 230.00,'E'),
('VTA-118','V005','P006','2025-09-26 15:30', 230.00,'E'),
('VTA-119','V005','P006','2025-11-18 09:15', 260.00,'E'),
('VTA-120','V005','P006','2025-12-28 14:00', 260.00,'E');

-- ════════════════════════════════════════════════════════════
--  2. BASE MIRROR: logimarket_mirror (mismos datos)
-- ════════════════════════════════════════════════════════════
CREATE DATABASE IF NOT EXISTS logimarket_mirror;
USE logimarket_mirror;

DROP TABLE IF EXISTS ventas;
CREATE TABLE ventas (
    id_venta     VARCHAR(20) PRIMARY KEY,
    id_vendedor  VARCHAR(20) NOT NULL,
    id_producto  VARCHAR(20) NOT NULL DEFAULT 'P001',
    fecha        VARCHAR(20) NOT NULL,
    monto_total  DOUBLE      NOT NULL,
    estado       CHAR(1)     NOT NULL DEFAULT 'E',
    recibido_en  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO logimarket_mirror.ventas
    SELECT id_venta, id_vendedor, id_producto, fecha, monto_total, estado, recibido_en
    FROM logimarket.ventas;

-- ════════════════════════════════════════════════════════════
--  3. DATAWAREHOUSE: logimarket_dw
-- ════════════════════════════════════════════════════════════
CREATE DATABASE IF NOT EXISTS logimarket_dw;
USE logimarket_dw;

-- Reconstruir esquema con dimension producto
DROP TABLE IF EXISTS crosstab_ventas;
DROP TABLE IF EXISTS fact_ventas;
DROP TABLE IF EXISTS dim_fecha;
DROP TABLE IF EXISTS dim_producto;
DROP TABLE IF EXISTS dim_vendedor;

CREATE TABLE dim_vendedor (
    id_vendedor VARCHAR(20) PRIMARY KEY
);

CREATE TABLE dim_producto (
    id_producto  VARCHAR(20) PRIMARY KEY,
    nombre       VARCHAR(60) NOT NULL
);

CREATE TABLE dim_fecha (
    id_fecha  VARCHAR(7) PRIMARY KEY,
    mes       INT        NOT NULL,
    anio      INT        NOT NULL,
    trimestre INT        NOT NULL
);

CREATE TABLE fact_ventas (
    id_vendedor VARCHAR(20) NOT NULL,
    id_producto VARCHAR(20) NOT NULL DEFAULT 'P000',
    id_fecha    VARCHAR(7)  NOT NULL,
    monto_total DOUBLE      NOT NULL DEFAULT 0,
    cantidad    INT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id_vendedor, id_producto, id_fecha),
    FOREIGN KEY (id_vendedor) REFERENCES dim_vendedor(id_vendedor),
    FOREIGN KEY (id_fecha)    REFERENCES dim_fecha(id_fecha)
);

CREATE TABLE crosstab_ventas (
    id_vendedor  VARCHAR(20) NOT NULL,
    id_producto  VARCHAR(20) NOT NULL DEFAULT 'P000',
    anio         INT         NOT NULL,
    q1_monto     DOUBLE      NOT NULL DEFAULT 0,
    q2_monto     DOUBLE      NOT NULL DEFAULT 0,
    q3_monto     DOUBLE      NOT NULL DEFAULT 0,
    q4_monto     DOUBLE      NOT NULL DEFAULT 0,
    total_anual  DOUBLE      NOT NULL DEFAULT 0,
    q1_cantidad  INT         NOT NULL DEFAULT 0,
    q2_cantidad  INT         NOT NULL DEFAULT 0,
    q3_cantidad  INT         NOT NULL DEFAULT 0,
    q4_cantidad  INT         NOT NULL DEFAULT 0,
    total_cant   INT         NOT NULL DEFAULT 0,
    generado_en  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_vendedor, id_producto, anio)
);

-- ── Poblar dimensiones ───────────────────────────────────────
INSERT INTO dim_vendedor (id_vendedor)
SELECT DISTINCT id_vendedor FROM logimarket.ventas ORDER BY id_vendedor;

INSERT INTO dim_producto (id_producto, nombre) VALUES
('P001','Laptop'),
('P002','Monitor'),
('P003','Teclado'),
('P004','Mouse'),
('P005','Impresora'),
('P006','Auriculares');

INSERT INTO dim_fecha (id_fecha, mes, anio, trimestre)
SELECT DISTINCT
    SUBSTRING(fecha, 1, 7)                                        AS id_fecha,
    CAST(SUBSTRING(fecha, 6, 2) AS UNSIGNED)                      AS mes,
    CAST(SUBSTRING(fecha, 1, 4) AS UNSIGNED)                      AS anio,
    (CAST(SUBSTRING(fecha, 6, 2) AS UNSIGNED) - 1) DIV 3 + 1     AS trimestre
FROM logimarket.ventas
ORDER BY id_fecha;

-- ── Poblar fact_ventas (una fila por vendedor+producto+mes) ─
INSERT INTO fact_ventas (id_vendedor, id_producto, id_fecha, monto_total, cantidad)
SELECT
    id_vendedor,
    id_producto,
    SUBSTRING(fecha, 1, 7) AS id_fecha,
    SUM(monto_total)       AS monto_total,
    COUNT(*)               AS cantidad
FROM logimarket.ventas
GROUP BY id_vendedor, id_producto, SUBSTRING(fecha, 1, 7)
ORDER BY id_vendedor, id_producto, id_fecha;

-- ── Poblar crosstab_ventas (cubo OLAP 3D) ───────────────────
INSERT INTO crosstab_ventas (
    id_vendedor, id_producto, anio,
    q1_monto, q2_monto, q3_monto, q4_monto, total_anual,
    q1_cantidad, q2_cantidad, q3_cantidad, q4_cantidad, total_cant
)
SELECT
    fv.id_vendedor,
    fv.id_producto,
    df.anio,
    SUM(CASE WHEN df.trimestre = 1 THEN fv.monto_total ELSE 0 END),
    SUM(CASE WHEN df.trimestre = 2 THEN fv.monto_total ELSE 0 END),
    SUM(CASE WHEN df.trimestre = 3 THEN fv.monto_total ELSE 0 END),
    SUM(CASE WHEN df.trimestre = 4 THEN fv.monto_total ELSE 0 END),
    SUM(fv.monto_total),
    SUM(CASE WHEN df.trimestre = 1 THEN fv.cantidad ELSE 0 END),
    SUM(CASE WHEN df.trimestre = 2 THEN fv.cantidad ELSE 0 END),
    SUM(CASE WHEN df.trimestre = 3 THEN fv.cantidad ELSE 0 END),
    SUM(CASE WHEN df.trimestre = 4 THEN fv.cantidad ELSE 0 END),
    SUM(fv.cantidad)
FROM fact_ventas fv
JOIN dim_fecha df ON fv.id_fecha = df.id_fecha
GROUP BY fv.id_vendedor, fv.id_producto, df.anio
ORDER BY fv.id_vendedor, fv.id_producto;

SET FOREIGN_KEY_CHECKS = 1;

-- ════════════════════════════════════════════════════════════
--  RESUMEN ESPERADO
-- ════════════════════════════════════════════════════════════
-- logimarket.ventas:        120 filas (5 vendedores x 3 productos x 8 transacciones)
-- logimarket_mirror.ventas: 120 filas (copia exacta)
-- logimarket_dw:
--   dim_vendedor:    5  filas (V001-V005)
--   dim_producto:    6  filas (P001-P006)
--   dim_fecha:      12  filas (2025-01 a 2025-12)
--   fact_ventas:   120  filas (una por vendedor+producto+mes)
--   crosstab_ventas: 15 filas (5 vendedores x 3 productos, anio=2025)
--
-- Vendedores:
--   V001 Carlos Rios   → Laptop, Monitor, Teclado
--   V002 Maria Lopez   → Laptop, Mouse, Impresora
--   V003 Juan Torres   → Monitor, Teclado, Auriculares
--   V004 Ana Vargas    → Laptop, Impresora, Auriculares
--   V005 Pedro Silva   → Monitor, Mouse, Auriculares
-- ════════════════════════════════════════════════════════════
