**Caso #2**

**Soltura**

IC-4301 Bases de Datos I

Instituto Tecnológico de Costa Rica

Campus Tecnológico Central Cartago

Escuela de Ingeniería en Computación

II Semestre 2024

Prof. Msc. Rodrigo Núñez Núñez

José Julián Monge Brenes

Carné: 2024247024

Fecha de entrega: 6 de mayo de 2025

# **Diseño de la base de datos**

# **Test de la base de datos**
Ahora que ya Soltura cuenta con un diseño de base de datos aprobados por los ingenieros, CTO, contrapartes ingenieros de Soltura, se les ha pedido que realicen pruebas contextuales para medir el comportamiento, técnicas, rendimiento y semántica de la base de datos diseñada en SQL Server. A continuación se detallan todos los test requeridos.

## **Población de datos**
Una vez aprobado el diseño de base de datos, ocupamos los scripts de llenado para la base de datos [Script de inserción completo](scriptInsercion.sql)

El sistema opera al menos con dos monedas
```sql
INSERT INTO sol_currencies(name, acronym, country, symbol)
VALUES
  ('Colón costarricense', 'CRC', 'Costa Rica', '₡'),
  ('Dólar estadounidense', 'USD', 'Estados Unidos', '$');
```

Cargar los catálogos base del sistema: tipos de servicios (gimnasios, salud, parqueos, etc.), tipos de planes, métodos de pago, monedas, estados de suscripción, etc.

```sql
-- sol_servicetype
INSERT INTO sol_servicetype(name)
VALUES
  ('Gimnasios'),
  ('Salud'),
  ('Parqueos'),
  ('Coworking'),
  ('Educación'),
  ('Streaming'),
  ('Comida saludable');

-- sol_subscriptionstatus
INSERT INTO sol_subscriptionstatus(name)
VALUES
  ('Activa'),
  ('Inactiva'),
  ('Cancelada');

-- sol_category
INSERT INTO sol_category(name)
VALUES
  ('Gimnasios'),
  ('Salud'),
  ('Educación'),
  ('Streaming'),
  ('Comida saludable');

-- sol_providers
INSERT INTO sol_providers(brand_name, legal_name, legal_identification, enabled, categoryId)
VALUES
  ('Spotify',             'Spotify S.A.',              '3101123456', 1, 4),
  ('Netflix',             'Netflix Inc.',              '3101123457', 1, 4),
  ('Smart Fit',           'Smart Fit Costa Rica',      '3101123458', 1, 1),
  ('Vindi Supermercados', 'Vindi S.A.',                '3101123459', 1, 2),
  ('Puma Energy',         'Puma Energy Centroamérica', '3101123460', 1, 5),
  ('Cinemark',            'Cinemark C.R.',             '3101123461', 1, 3),
  ('Amazon Prime Video',  'Amazon Corp.',              '3101123462', 1, 4);

-- api_integrations
INSERT INTO api_integrations(name, public_key, private_key, url, creation_date, last_update, enabled, idProvider)
VALUES
  ('Integración BAC',    'public_bac',   'private_bac',   'https://api.bac.com',      GETDATE(), GETDATE(), 1, 1),
  ('Integración SINPE',  'public_sinpe', 'private_sinpe', 'https://api.sinpe.fi.cr',  GETDATE(), GETDATE(), 1, 2),
  ('Integración PayPal', 'pk_paypal',    'sk_paypal',     'https://api.paypal.com',   GETDATE(), GETDATE(), 1, 3),
  ('Integración SINPE',  'pk_sinpe',     'sk_sinpe',      'https://api.sinpe.fi.cr',  GETDATE(), GETDATE(), 1, 4);

-- sol_pay_methods
INSERT INTO sol_pay_methods(name, secret_key, logo_icon_url, enabled, idApiIntegration)
VALUES
  ('Tarjeta de Crédito',     CONVERT(VARBINARY(255),'clave_bac'),    'https://logo.bac.com/card.png',     1, 1),
  ('Transferencia Bancaria', CONVERT(VARBINARY(255),'clave_bn'),     'https://logo.bncr.fi.cr/bank.png',  1, 2),
  ('PayPal',                 CONVERT(VARBINARY(255),'clave_paypal'), 'https://logo.paypal.com/paypal.png',1, 3),
  ('Sinpe Móvil',            CONVERT(VARBINARY(255),'clave_sinpe'),  'https://logo.sinpe.fi.cr/sinpe.png',1, 4);

-- sol_available_pay_methods
INSERT INTO sol_available_pay_methods(name, token, exp_token, mask_account, idMethod)
VALUES
  ('Tarjeta de Crédito BAC',     'tok_bac_ABC123',    DATEADD(MONTH,6,GETDATE()), '****4321', 1),
  ('Transferencia Bancaria BNCR','tok_bncr_DEF456',   DATEADD(MONTH,6,GETDATE()), NULL,      2),
  ('PayPal principal',            'tok_paypal_GHI789', DATEADD(MONTH,6,GETDATE()), 'user@****.com', 3),
  ('Sinpe Móvil',                 'tok_sinpe_JKL012',  DATEADD(MONTH,6,GETDATE()), '8888-****',     4);

-- sol_recurrencetypes
INSERT INTO sol_recurrencetypes(name)
VALUES
  ('Diaria'),
  ('Semanal'),
  ('Mensual'),
  ('Trimestral'),
  ('Anual');

-- sol_schedules
INSERT INTO sol_schedules(name, description, recurrencetypeid, active, [interval], startdate, endtype, repetitions)
VALUES
  ('Mensual',    'Pago mensual',       1, 1,  30, GETDATE(), 'NEVER', NULL),
  ('Trimestral', 'Pago cada 3 meses',  1, 1,  90, GETDATE(), 'NEVER', NULL),
  ('Anual',      'Pago anual',         1, 1, 365, GETDATE(), 'NEVER', NULL),
  ('Semanal',    'Pago semanal',       1, 1,   7, GETDATE(), 'NEVER', NULL),
  ('Bimestral',  'Pago bimestral',     1, 1,  60, GETDATE(), 'NEVER', NULL),
  ('Semestral',  'Pago semestral',     1, 1, 180, GETDATE(), 'NEVER', NULL),
  ('Diario',     'Pago diario',        1, 1,   1, GETDATE(), 'NEVER', NULL),
  ('Especial',   'Condición especial', 1, 1,  15, GETDATE(), 'NEVER', NULL),
  ('Bienal',     'Cada dos años',      1, 1, 730, GETDATE(), 'NEVER', NULL);

-- sol_countries
INSERT INTO sol_countries(name)
VALUES
  ('Costa Rica'),
  ('México'),
  ('Guatemala'),
  ('El Salvador'),
  ('Honduras'),
  ('Nicaragua'),
  ('Panamá'),
  ('Colombia'),
  ('Perú'),
  ('Chile');

-- sol_states
INSERT INTO sol_states(name, countryid)
VALUES
  ('San José',          1),
  ('Alajuela',          1),
  ('Jalisco',           2),
  ('Nuevo León',        2),
  ('Guatemala',         3),
  ('Petén',             3),
  ('San Salvador',      4),
  ('La Libertad',       4),
  ('Francisco Morazán', 5),
  ('Cortés',            5),
  ('León',              6),
  ('Granada',           6),
  ('Panamá',            7),
  ('Chiriquí',          7),
  ('Bogotá D.C.',       8),
  ('Antioquia',         8),
  ('Lima',              9),
  ('Cusco',             9),
  ('Santiago',         10),
  ('Valparaíso',       10);

-- sol_cities
INSERT INTO sol_cities(name, stateid)
VALUES
  ('San Pedro',           1),
  ('Escazú',              1),
  ('Quesada',             2),
  ('San Ramón',           2),
  ('Guadalajara',         3),
  ('Tepatitlán',          3),
  ('Monterrey',           4),
  ('San Nicolás',         4),
  ('Mixco',               5),
  ('Villa Nueva',         5),
  ('Flores',              6),
  ('Melchor de Mencos',   6),
  ('Soyapango',           7),
  ('Ilopango',            7),
  ('Santa Tecla',         8),
  ('Zaragoza',            8),
  ('Tegucigalpa',         9),
  ('Comayagüela',         9),
  ('San Pedro Sula',     10),
  ('Puerto Cortés',      10),

-- sol_contracts sin especificar el contratoId (IDENTITY lo genera)
INSERT INTO sol_contracts(description, start_date, end_date, enabled, providerid)
VALUES
  ('Contrato con Spotify',             GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 1),
  ('Contrato con Netflix',             GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 2),
  ('Contrato con Smart Fit',           GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 3),
  ('Contrato con Vindi Supermercados', GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 4),
  ('Contrato con Puma Energy',         GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 5),
  ('Contrato con Cinemark',            GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 6),
  ('Contrato con Amazon Prime Video',  GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 7);

-- sol_price_configurations sin especificar el price_config_id (IDENTITY lo genera)
INSERT INTO sol_price_configurations(provider_price, margin_type, margin_value, soltura_percent, client_percent)
VALUES
  (100.00, 'Porcentaje', 20.00, 50.00, 50.00);
```

Carga de al menos 40 usuarios en el sistema

```sql
-- Creación de los Usuarios
DECLARE @UserCount INT = 40;

-- Arreglos simulados
DECLARE @FirstNames TABLE (Name VARCHAR(100));
DECLARE @LastNames TABLE (Surname VARCHAR(100));
DECLARE @EmailDomains TABLE (Domain VARCHAR(100));

INSERT INTO @FirstNames VALUES ('Carlos'), ('María'), ('José'), ('Ana'), ('Luis'), ('Laura'), ('David'), ('Carmen');
INSERT INTO @LastNames VALUES ('Ramírez'), ('González'), ('Fernández'), ('Rojas'), ('Soto'), ('Vargas'), ('Pérez'), ('Jiménez');
INSERT INTO @EmailDomains VALUES ('@gmail.com'), ('@hotmail.com'), ('@outlook.com');

DECLARE @i INT = 1;

WHILE @i <= @UserCount
BEGIN
    DECLARE @FirstName VARCHAR(100) = (SELECT TOP 1 Name FROM @FirstNames ORDER BY NEWID());
    DECLARE @LastName VARCHAR(100) = (SELECT TOP 1 Surname FROM @LastNames ORDER BY NEWID());
    DECLARE @EmailDomain VARCHAR(100) = (SELECT TOP 1 Domain FROM @EmailDomains ORDER BY NEWID());

    DECLARE @Username VARCHAR(100) = LOWER(@FirstName + LEFT(@LastName, 2) + CAST(@i AS VARCHAR));
    DECLARE @Email VARCHAR(150) = LOWER(@FirstName + '.' + @LastName + CAST(@i AS VARCHAR) + @EmailDomain);

    -- Crear dirección aleatoria
    DECLARE @CityId INT = (SELECT TOP 1 cityid FROM sol_cities ORDER BY NEWID());

	-- Crear coordenadas aleatorias
    DECLARE @Lat FLOAT = 9.9 + (RAND() * 0.2);
    DECLARE @Lon FLOAT = -84.2 + (RAND() * 0.2);

    INSERT INTO sol_address (line1, line2, zipcode, location, cityid)
    VALUES (
        'Calle ' + CAST((ABS(CHECKSUM(NEWID())) % 100 + 1) AS VARCHAR),
        'Casa ' + CAST((ABS(CHECKSUM(NEWID())) % 200 + 1) AS VARCHAR),
        CAST((10000 + ABS(CHECKSUM(NEWID())) % 90000) AS VARCHAR),
        geography::Point(@Lat, @Lon, 4326),
        @CityId
    );

    -- Insertar usuario con address generado
    INSERT INTO sol_users (username, firstname, lastname, email, password, isActive, addressid)
    VALUES (@Username, @FirstName, @LastName, @Email, 0x70617373776F7264, 1, @i);

    SET @i = @i + 1;
END
```

Llenar la tabla de planes de suscripción, con variaciones como: Joven deportista, Familia de Verano, Viajero frecuente, Nomada Digiital, etc.
```sql

-- sol_plans
INSERT INTO sol_plans(name, description, customizable, limit_people, enabled, codigoid)
VALUES
  ('Joven deportista',   'Ideal para jóvenes entre 18-25 con enfoque en gimnasios y salud', 1, 7, 1, 101),
  ('Familia de Verano',  'Planes para familias en época de vacaciones, incluye parqueos y comida', 1, 10, 1, 102),
  ('Viajero frecuente',  'Acceso a parqueos y coworkings en diferentes zonas',               1, 6, 1, 103),
  ('Nómada Digital',     'Acceso a coworking, gimnasio y educación continua',                1, 8, 1, 104),
  ('Estudiante Streaming','Ideal para estudiantes que consumen educación y entretenimiento',1, 5, 1, 105),
  ('Oficina Saludable',  'Planes para oficinas que ofrecen salud y comida saludable',        1, 9, 1, 106),
  ('Movilidad Total',    'Parqueo, coworking y comida saludable en un solo paquete',         1, 6, 1, 107),
  ('Pro Plus',           'Servicios premium para profesionales',                           1, 8, 1, 108),
  ('Básico Urbano',      'Servicios básicos para el trabajador urbano',                      1, 7, 1, 109);
```

Incluir al menos 7 empresas proveedoras de servicios (Ya fueron incluidas anteriormente, esto para poder crear las API_integrations), cada uno ofreciendo 2 a 4 combinaciones de servicios que se deben usar para crear de 7 a 9 planes diferentes.
En este script por medio de los contratos con los proveedores ya creados, se le asignara a cada proveedor de 2 a 4 servicios que brindar.
```sql
-- Definir posibles tipos de servicio
DECLARE @ServiceTypes TABLE (typeid INT IDENTITY(1,1), typeName VARCHAR(50));
INSERT INTO @ServiceTypes(typeName)
VALUES
  ('Subscripcion'),
  ('Dinero'),
  ('Cantidad'),
  ('Duracion'),
  ('Porcentaje');

DECLARE 
  @nextServiceId  INT = 1,
  @contractId     INT,
  @numServices    INT,
  @svcCounter     INT,
  @typeCount      INT,
  @pick           INT,
  @dataType       VARCHAR(50),
  @randVal        INT;

-- Contar cuántos tipos tenemos
SELECT @typeCount = COUNT(*) FROM @ServiceTypes;

-- Recorrer cada contrato
DECLARE contract_cursor CURSOR FOR 
  SELECT contractid FROM sol_contracts;
OPEN contract_cursor;
FETCH NEXT FROM contract_cursor INTO @contractId;

WHILE @@FETCH_STATUS = 0
BEGIN
  -- Determinar aleatoriamente entre 2 y 4 servicios
  SET @numServices = ABS(CHECKSUM(NEWID())) % 3 + 2;
  SET @svcCounter  = 1;

  WHILE @svcCounter <= @numServices
  BEGIN
    -- Elegir un dataType al azar
    SET @pick = ABS(CHECKSUM(NEWID())) % @typeCount + 1;
    SELECT @dataType = typeName FROM @ServiceTypes WHERE typeid = @pick;

    -- Elegir currencyid aleatorio entre 1 y 2
    SET @randVal = ABS(CHECKSUM(NEWID())) % 2 + 1;
    
    -- Elegir servicetypeid aleatorio entre 1 y 7
    DECLARE @randSvcType INT = ABS(CHECKSUM(NEWID())) % 7 + 1;

    SET @nextServiceId = @nextServiceId + 1;

    INSERT INTO sol_service
      (name,description,dataType,original_amount,sale_amount,enabled,contractid,currencyid,servicetypeid,price_config_id)
    VALUES
      (
        'Srv_' + CAST(@contractId AS VARCHAR(5)) + '_' + CAST(@svcCounter AS VARCHAR(2)),
        'Srv ' + CAST(@svcCounter AS VARCHAR(2)) + ' para contrato ' + CAST(@contractId AS VARCHAR(5)),
        @dataType,
        CAST(ROUND((RAND(CHECKSUM(NEWID())) * 200 + 50), 2) AS DECIMAL(10,2)),
        CAST(ROUND((RAND(CHECKSUM(NEWID())) * 200 + 50) * 1.2, 2) AS DECIMAL(10,2)),
        1,
        @contractId,
        @randVal,
        @randSvcType,
        1   -- price_config_id
      );

    SET @svcCounter = @svcCounter + 1;
  END

  FETCH NEXT FROM contract_cursor INTO @contractId;
END

CLOSE contract_cursor;
DEALLOCATE contract_cursor;

SELECT * FROM dbo.sol_service
```
Ahora con estos servicios creados, por medio de cursor y viendo los servicios creados a cada plan se le asignarán los diferentes servicios
```sql
INSERT INTO sol_quantitytypes(typename,description,iscumulative)
VALUES
('UNIDAD','Cantidad de unidades',1),
('PORCENTAJE','Porcentaje aplicado',0),
('HORAS','Duración en horas',1),
('DÍAS','Duración en días',1),
('MONTO','Cantidad monetaria',1);

DECLARE 
  @nextPlanFeatureId INT = 1,
  @idplan           INT,
  @services       INT,
  @conta        INT,
  @sid               INT;

DECLARE plan_cursor CURSOR FOR
  SELECT planid
    FROM sol_plans
   ORDER BY planid;

OPEN plan_cursor;
FETCH NEXT FROM plan_cursor INTO @idplan;

WHILE @@FETCH_STATUS = 0
BEGIN
  -- Número aleatorio de servicios (2–4) para este plan
  SET @services = ABS(CHECKSUM(NEWID())) % 3 + 2;
  SET @conta  = 1;

  WHILE @conta <= @services
  BEGIN
    -- Elegir un servicio no asignado aún a este plan
    SELECT TOP 1 @sid = serviceid
      FROM sol_service
     WHERE serviceid NOT IN (
           SELECT serviceid 
             FROM sol_planfeatures 
            WHERE plantid = @idplan
         )
     ORDER BY NEWID();

    -- Asignar nuevo planfeatureid
    SET @nextPlanFeatureId = @nextPlanFeatureId + 1;

	DECLARE @qtid INT = ABS(CHECKSUM(NEWID())) % 5 + 1;

    INSERT INTO sol_planfeatures
      (value, enabled, quantitytypeid, serviceid, plantid)
    VALUES ('1', 1, @qtid, @sid, @idplan);

    SET @conta = @conta + 1;
  END

  FETCH NEXT FROM plan_cursor INTO @idplan;
END

CLOSE plan_cursor;
DEALLOCATE plan_cursor;
```
Para cada plan de servicios, debe haber 3 a 6 subscripciones a usuarios diferentes no repetidos en otra combinación (Se le resta a UserCount 5 que son los 5 usuarios sin subscripción).
```sql
SET @UserCount = @UserCount - 5;

-- 2) Para cada uno de los 9 planes existentes, generar un número aleatorio de suscripciones (3–6)
DECLARE @PlanCounts TABLE (planid INT PRIMARY KEY, cnt INT);
INSERT INTO @PlanCounts(planid,cnt)
SELECT
  planid,
  ABS(CHECKSUM(NEWID(),planid)) % 4 + 3
FROM sol_plans;

-- 3) Sumar totales y barajar usuarios 1..@UserCount
WITH NumberedUsers AS (
  SELECT TOP(@UserCount) number AS userid
  FROM master..spt_values
  WHERE type='P' AND number BETWEEN 1 AND @UserCount
  ORDER BY NEWID()
),
AssignedUsers AS (
  SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum, userid
  FROM NumberedUsers
),
PlanSegments AS (
  SELECT
    planid,
    cnt,
    SUM(cnt) OVER(ORDER BY planid
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - cnt + 1 AS startRow,
    SUM(cnt) OVER(ORDER BY planid) AS endRow
  FROM @PlanCounts
)

-- 4) Insertar suscripciones asignando planid por registro
INSERT INTO sol_subscriptions
  (startdate, enddate, autorenew, statusid, scheduleid, userid, planid)
SELECT
  GETDATE()                                              AS startdate,
  DATEADD(YEAR,1,GETDATE())                              AS enddate,
  1                                                      AS autorenew,
  1                                                      AS statusid,
  ps.planid                                              AS scheduleid,  -- si scheduleid coincide con planid
  au.userid                                              AS userid,
  ps.planid                                              AS planid
FROM PlanSegments ps
JOIN AssignedUsers au
  ON au.rownum BETWEEN ps.startRow AND ps.endRow;
```

## **Demostraciones T-SQL**

## **Mantenimiento de la Seguridad**

## **Consultas Misceláneas**
Vista dinámica indexada con al menos 4 tablas

```sql
```

Crear un procedimiento almacenado transaccional que realice una operación del sistema, relacionado a subscripciones, pagos, servicios, transacciones o planes, y que dicha operación requiera insertar y/o actualizar al menos 3 tablas.
```sql
-- 2. SP Transaccional
CREATE PROCEDURE dbo.CrearSubscripcionMensual
  @UserId         INT,
  @PlanId         INT,
  @Amount         DECIMAL(10,2),
  @PaymentMethodId INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN;

  BEGIN TRY
   

    INSERT INTO sol_subscriptions (startdate, enddate, autorenew, statusid, scheduleid, userid, planid)
    VALUES (GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, 1, 1, @UserId, @PlanId);

	DECLARE @SubId INT = SCOPE_IDENTITY();

    
    INSERT INTO sol_payments (amount, taxamount, discountporcent, realamount, date, statusid, paymentmethodid, availablemethodid)
    VALUES (@Amount, @Amount*0.13, 0, @Amount*1.13, GETDATE(), 1, @PaymentMethodId, @PaymentMethodId);

	DECLARE @PayId INT = SCOPE_IDENTITY();

    INSERT INTO sol_transactions
      (name,description,amount,referencenumber,transactiondate,officetime,checksum,transactiontypeid,transactionsubtypeid,currencyid,exchangerateid,payid)
    VALUES
      ('Subscripción Mensual', 'Transacción generada por CrearSubscripcionMensual',@Amount, CAST(@PayId AS VARCHAR(50)), GETDATE(), GETDATE(), CAST(HASHBYTES('MD5',CAST(@PayId AS VARCHAR(50))) AS VARBINARY(250)), 1, 1, 1, 1, @PayId);

    COMMIT;
  END TRY
  BEGIN CATCH
    ROLLBACK;
    THROW;
  END CATCH
END
GO
```
Prueba Existosa
```sql
EXEC dbo.CrearSubscripcionMensual @UserId=1,@PlanId=1,@Amount=120.00,@PaymentMethodId=1; 
```

Prueba Fallida
```sql
EXEC dbo.CrearSubscripcionMensual @UserId=1,@PlanId=1,@Amount=200.00,@PaymentMethodId=999;
```

Escribir un SELECT que use CASE para crear una columna calculada que agrupe dinámicamente datos (por ejemplo, agrupar cantidades de usuarios por plan en rangos de monto, no use este ejemplo).
```sql
-- 3.Consulta con CASE
SELECT
  price_category,
  COUNT(*) AS cantidad_servicios
FROM (
  SELECT
    CASE
      WHEN sale_amount < 100               THEN 'Económico'
      WHEN sale_amount BETWEEN 100 AND 200 THEN 'Medio'
      ELSE 'Premium'
    END AS price_category
  FROM sol_service
) AS sub
GROUP BY price_category
ORDER BY price_category;
```

Imagine una cosulta que el sistema va a necesitar para mostrar cierta información, o reporte o pantalla

Crear una consulta con al menos 3 JOINs que analice información donde podría ser importante obtener un SET DIFFERENCE y un INTERSECTION
```sql
-- Encuentra los planes que ofrecen tanto Gimnasios como Coworking (INTERSECTION)
SELECT 
  p.planid, 
  p.name 
FROM dbo.sol_plans AS p
JOIN dbo.sol_planfeatures AS pf ON p.planid = pf.plantid
JOIN dbo.sol_service      AS s  ON pf.serviceid = s.serviceid
JOIN dbo.sol_servicetype  AS st ON s.servicetypeid = st.servicetypeid
WHERE st.name = 'Gimnasios'
INTERSECT
SELECT 
  p.planid, 
  p.name 
FROM dbo.sol_plans AS p
JOIN dbo.sol_planfeatures AS pf ON p.planid = pf.plantid
JOIN dbo.sol_service      AS s  ON pf.serviceid = s.serviceid
JOIN dbo.sol_servicetype  AS st ON s.servicetypeid = st.servicetypeid
WHERE st.name = 'Coworking';

-- Encuentra los planes que ofrecen Gimnasios pero NO Coworking (SET DIFFERENCE)
SELECT 
  p.planid, 
  p.name 
FROM dbo.sol_plans AS p
JOIN dbo.sol_planfeatures AS pf ON p.planid = pf.plantid
JOIN dbo.sol_service      AS s  ON pf.serviceid = s.serviceid
JOIN dbo.sol_servicetype  AS st ON s.servicetypeid = st.servicetypeid
WHERE st.name = 'Gimnasios'
EXCEPT
SELECT 
  p.planid, 
  p.name 
FROM dbo.sol_plans AS p
JOIN dbo.sol_planfeatures AS pf ON p.planid = pf.plantid
JOIN dbo.sol_service      AS s  ON pf.serviceid = s.serviceid
JOIN dbo.sol_servicetype  AS st ON s.servicetypeid = st.servicetypeid
WHERE st.name = 'Coworking';
```

Crear un procedimiento almacenado transaccional que llame a otro SP transaccional, el cual a su vez llame a otro SP transaccional. Cada uno debe modificar al menos 2 tablas. Se debe demostrar que es posible hacer COMMIT y ROLLBACK con ejemplos exitosos y fallidos sin que haya interrumpción de la ejecución correcta de ninguno de los SP en ninguno de los niveles del llamado.
```sql
-- 6. 3 niveles SP Transaccionales
-- Nivel 3: inserta en sol_log_type y sol_log_severity, devuelve sus IDs
CREATE OR ALTER PROCEDURE dbo.sp_Level3
  @OutLogTypeId     INT OUTPUT,
  @OutLogSeverityId INT OUTPUT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  BEGIN TRAN;
  BEGIN TRY
    INSERT INTO sol_log_type(name, description)
    VALUES ('Type_Level3','Creado en Level3');
    SET @OutLogTypeId = SCOPE_IDENTITY();

    INSERT INTO sol_log_severity(name, severity_level)
    VALUES ('Severity_Level3',1);
    SET @OutLogSeverityId = SCOPE_IDENTITY();

    COMMIT;
  END TRY
  BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    THROW;
  END CATCH
END;
GO

-- Nivel 2: llama a Level3, luego inserta/actualiza sol_log_source y sol_log_type
CREATE OR ALTER PROCEDURE dbo.sp_Level2
  @Fail                BIT                = 0,
  @InOutLogTypeId      INT           OUTPUT,
  @InOutLogSeverityId  INT           OUTPUT,
  @OutLogSourceId      INT           OUTPUT
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  BEGIN TRAN;
  BEGIN TRY
    -- 1) Ejecuta Nivel 3 y captura IDs
    EXEC dbo.sp_Level3
      @OutLogTypeId     = @InOutLogTypeId     OUTPUT,
      @OutLogSeverityId = @InOutLogSeverityId OUTPUT;

    -- 2) Inserta nuevo source y captura su ID
    INSERT INTO sol_log_source(name, system_component)
    VALUES ('Source_Level2','Component2');
    SET @OutLogSourceId = SCOPE_IDENTITY();

    -- 3) Actualiza el log_type que creó Nivel 3
    UPDATE sol_log_type
      SET description = 'Actualizado en Level2'
    WHERE log_typeid = @InOutLogTypeId;

    -- 4) Forzar error si @Fail=1
    IF @Fail = 1
      THROW 50000, 'Error forzado en Level2', 1;

    COMMIT;
  END TRY
  BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    THROW;
  END CATCH
END;
GO

-- Nivel 1: llama a Level2, luego inserta/actualiza sol_logs y sol_log_source
CREATE OR ALTER PROCEDURE dbo.sp_Level1
  @Fail BIT = 0
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  DECLARE 
    @LogTypeId     INT,
    @LogSeverityId INT,
    @LogSourceId   INT;

  BEGIN TRAN;
  BEGIN TRY
    -- 1) Llama a Nivel 2 y captura todos los IDs
    EXEC dbo.sp_Level2
      @Fail               = @Fail,
      @InOutLogTypeId     = @LogTypeId      OUTPUT,
      @InOutLogSeverityId = @LogSeverityId  OUTPUT,
      @OutLogSourceId     = @LogSourceId    OUTPUT;

    -- 2) Inserta en sol_logs usando los IDs correctos
    INSERT INTO sol_logs
      (description, posttime, computer, checksum,
       log_typeid, log_sourceid, log_severityid)
    VALUES
      ('Log_Level1', GETDATE(), 'Server1', 'CHK1',
       @LogTypeId, @LogSourceId, @LogSeverityId);

    -- 3) Actualiza el source creado en Nivel 2
    UPDATE sol_log_source
      SET system_component = 'Actualizado en Level1'
    WHERE log_sourceid = @LogSourceId;

    -- 4) Forzar error si @Fail=1
    IF @Fail = 1
      THROW 50001, 'Error forzado en Level1', 1;

    COMMIT;
  END TRY
  BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    THROW;
  END CATCH
END;
GO
```

Demostraciones de llamadas exitosas y llamadas fallidas
```sql
-- Ejecución EXITOSA (no forzamos error)
EXEC dbo.sp_Level1 @Fail = 0;

-- Ejecución FALLIDA (forzamos error en Level2)
BEGIN TRY
  EXEC dbo.sp_Level1 @Fail = 1;
END TRY
BEGIN CATCH
  PRINT 'Error capturado: ' + ERROR_MESSAGE();
END CATCH

SELECT * FROM sol_log_type     WHERE name  = 'Type_Level3';
SELECT * FROM sol_log_severity WHERE name  = 'Severity_Level3'; 
SELECT * FROM sol_log_source   WHERE name  = 'Source_Level2';
SELECT * FROM sol_logs         WHERE description = 'Log_Level1';

DELETE FROM sol_logs
DELETE FROM sol_log_source
DELETE FROM sol_log_severity
DELETE FROM sol_log_type

```

Será posible que haciendo una consulta SQL en esta base de datos se pueda obtener un JSON para ser consumido por alguna de las pantallas de la aplicación que tenga que ver con los planes, subscripciones, servicios o pagos. Justifique cuál pantalla podría requerir esta consulta.
Si es posible realizar una consulta con SQL para que este obtenga un JSON, como por ejemplo la siguiente consulta. Esto retorna todos los planes que tienen todos los usuarios, esto nos serviria para la pantalla de dashboard de planes, o ver los registros de todas las subscripciones.
```sql
SELECT
  p.planid,
  p.name      AS plan_name,
  (
    SELECT 
      s.userid,
      s.startdate,
      s.enddate
    FROM sol_subscriptions AS s
    WHERE s.planid = p.planid
    FOR JSON PATH
  ) AS subscripciones
FROM sol_plans AS p
FOR JSON PATH, ROOT('Planes');
```
Podrá su base de datos soportar un SP transaccional que actualice los contratos de servicio de un proveedor, el proveedor podría ya existir o ser nuevo, si es nuevo, solo se inserta. Las condiciones del contrato del proveedor, deben ser suministradas por un Table-Valued Parameter (TVP), si las condiciones son sobre items existentes, entonces se actualiza o inserta realizando las modificacinoes que su diseño requiera, si son condiciones nuevas, entonces se insertan.
```sql
CREATE TYPE dbo.TVP_ContractCondition AS TABLE(
  ServiceID         INT           NOT NULL,  -- FK a sol_service
  ConditionTypeID   INT           NOT NULL,  -- FK a sol_conditiontypes
  Description       VARCHAR(100)  NOT NULL,
  QuantityCondition VARCHAR(100)  NOT NULL,
  Discount          DECIMAL(5,2)  NOT NULL,
  AmountToPay       DECIMAL(10,2) NOT NULL,
  Enabled           BIT           NOT NULL,
  PriceConfigID     INT           NOT NULL
);
GO

-- 2) Alteramos el SP para hacer MERGE sobre sol_conditions
CREATE OR ALTER PROCEDURE dbo.usp_UpsertProviderContract
  @ProviderId    INT,                            -- 0 si es nuevo
  @BrandName     VARCHAR(100),
  @LegalName     VARCHAR(150),
  @LegalID       VARCHAR(50),
  @CategoryId    INT,
  @Conditions    dbo.TVP_ContractCondition READONLY
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;
  BEGIN TRAN;

  BEGIN TRY
    -- a) Upsert de sol_providers
    IF @ProviderId = 0 OR NOT EXISTS (SELECT 1 FROM sol_providers WHERE providerid = @ProviderId)
    BEGIN
      INSERT INTO sol_providers(brand_name, legal_name, legal_identification, enabled, categoryId)
      VALUES(@BrandName, @LegalName, @LegalID, 1, @CategoryId);
      SET @ProviderId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
      UPDATE sol_providers
        SET brand_name = @BrandName,
            legal_name = @LegalName,
            legal_identification = @LegalID,
            categoryId = @CategoryId
      WHERE providerid = @ProviderId;
    END

    -- b) Upsert de sol_contracts
    DECLARE @ContractId INT = (SELECT contractid FROM sol_contracts WHERE providerid = @ProviderId);
    IF @ContractId IS NULL
    BEGIN
      INSERT INTO sol_contracts(description, start_date, end_date, enabled, providerid)
      VALUES('Contrato proveedor ' + CAST(@ProviderId AS VARCHAR), GETDATE(), DATEADD(YEAR,1,GETDATE()), 1, @ProviderId);
      SET @ContractId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
      UPDATE sol_contracts
        SET end_date = DATEADD(YEAR,1,GETDATE()), enabled = 1
      WHERE contractid = @ContractId;
    END

    -- c) MERGE en sol_conditions con PriceConfigID
    MERGE dbo.sol_conditions AS T
    USING @Conditions AS S
      ON T.serviceid=S.ServiceID AND T.conditiontypeid=S.ConditionTypeID
    WHEN MATCHED THEN
      UPDATE SET
        description       = S.Description,
        quantity_condition= S.QuantityCondition,
        discount          = S.Discount,
        amount_to_pay     = S.AmountToPay,
        enabled           = S.Enabled,
        price_config_id   = S.PriceConfigID
    WHEN NOT MATCHED BY TARGET THEN
      INSERT(description,conditiontypeid,quantity_condition,discount,amount_to_pay,enabled,serviceid,price_config_id)
      VALUES(S.Description,S.ConditionTypeID,S.QuantityCondition,S.Discount,S.AmountToPay,S.Enabled,S.ServiceID,S.PriceConfigID);

    COMMIT;
  END TRY
  BEGIN CATCH
    ROLLBACK;
    THROW;
  END CATCH
END;
GO
```

Ejemplos de uso del procedimiento almacenado
```sql
-- Ejemplo 1: insertar proveedor nuevo con 2 condiciones
DECLARE @conds1 dbo.TVP_ContractCondition;
INSERT INTO @conds1
  (PriceConfigID, ServiceID, ConditionTypeID, Description, QuantityCondition, Discount, AmountToPay, Enabled)
VALUES
  (1, 1, 1, 'Descuento volumen',    '>=10 unidades',  5.00, 95.00, 1),
  (1, 2, 2, 'Promoción lanzamiento','<=5 servicios', 10.00, 90.00, 1);

EXEC dbo.usp_UpsertProviderContract
  @ProviderId = 0,
  @BrandName  = 'Proveedor Nuevo',
  @LegalName  = 'Proveedor Nuevo S.A.',
  @LegalID    = '999999999',
  @CategoryId = 2,
  @Conditions = @conds1;


-- Ejemplo 2: actualizar proveedor existente (providerid=1), actualiza e inserta condiciones
DECLARE @conds2 dbo.TVP_ContractCondition;
INSERT INTO @conds2
  (PriceConfigID, ServiceID, ConditionTypeID, Description, QuantityCondition, Discount, AmountToPay, Enabled)
VALUES
  (1,   1, 1, 'Ajuste precio estándar', '>=1 unidad',   3.00, 97.00, 1),  -- actualiza condición ID=1
  (1, 3, 3, 'Bono fidelidad',       '>=12 meses',   8.00, 92.00, 1);  -- nueva condición

EXEC dbo.usp_UpsertProviderContract
  @ProviderId = 1,
  @BrandName  = 'Spotify Updated',
  @LegalName  = 'Spotify S.A. (CR)',
  @LegalID    = '3101123456X',
  @CategoryId = 4,
  @Conditions = @conds2;


-- Ejemplo 3: insertar otro proveedor nuevo con 3 condiciones
DECLARE @conds3 dbo.TVP_ContractCondition;
INSERT INTO @conds3
  (PriceConfigID, ServiceID, ConditionTypeID, Description, QuantityCondition, Discount, AmountToPay, Enabled)
VALUES
  (1, 4, 2, 'Descuento especial', '>=3 servicios',   7.50, 112.50, 1),
  (1, 5, 1, 'Promoción premium',  '>=1 paquete',     15.00, 85.00, 1),
  (1, 6, 3, 'Tasa reducida',      '>=6 meses',       5.00, 95.00, 1);

EXEC dbo.usp_UpsertProviderContract
  @ProviderId = 0,
  @BrandName  = 'XYZ Servicios S.A.',
  @LegalName  = 'XYZ Servicios S.A.',
  @LegalID    = '888888888',
  @CategoryId = 3,
  @Conditions = @conds3;


Select * from sol_contracts
Select * from sol_providers
Select * from sol_conditions
```

Crear un SELECT que genere un archivo CSV de datos basado en un JOIN entre dos tablas
```sql
-- 9. CSV
SELECT
  u.userid,
  u.username,
  s.planid
FROM sol_users u
JOIN sol_subscriptions s ON s.userid=u.userid
FOR XML RAW('row'), ROOT('rows'), TYPE
```

Configurar una tabla de bitácora en otro servidor SQL Server accesible vía Linked Servers con impersonación segura desde los SP del sistema. Ahora haga un SP genérico para que cualquier SP en el servidor principal, pueda dejar bitácora en la nueva tabla que se hizo en el Linked Server.
