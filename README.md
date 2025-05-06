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
Ahora con estos servicios creados, por medio de cursos y viendo los servicios creados a cada plan se le asignarán los diferentes servicios
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
