USE SolturaDB
-- sol_currencies
INSERT INTO sol_currencies(name, acronym, country, symbol)
VALUES
  ('Colón costarricense', 'CRC', 'Costa Rica', '₡'),
  ('Dólar estadounidense', 'USD', 'Estados Unidos', '$');

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
  ('León Viejo',         11),
  ('Telica',             11),
  ('Granada',            12),
  ('Diriomo',            12),
  ('Panamá City',        13),
  ('San Miguelito',      13),
  ('David',              14),
  ('Boquete',            14),
  ('Bogotá',             15),
  ('Suba',               15),
  ('Medellín',           16),
  ('Envigado',           16),
  ('Lima Metropolitana', 17),
  ('San Juan de Lurigancho',17),
  ('Cusco',              18),
  ('Urubamba',           18),
  ('Santiago Centro',    19),
  ('La Florida',         19),
  ('Valparaíso',         20),
  ('Viña del Mar',       20);


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


-- Definir posibles tipos de servicio para dataType
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

SELECT * FROM sol_planfeatures

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

SELECT * FROM sol_subscriptions

INSERT INTO sol_paymentstatus(name)
VALUES
  ('Pendiente'),
  ('Completado'),
  ('Fallido');

INSERT INTO sol_payments
  (amount
  ,taxamount
  ,discountporcent
  ,realamount
  ,result
  ,authcode
  ,referencenumber
  ,chargetoken
  ,date
  ,checksum
  ,statusid
  ,paymentmethodid
  ,availablemethodid)
VALUES
  (100.00         -- Monto base
  ,13.00          -- Impuesto
  ,5.00           -- % de descuento
  ,108.00         -- Monto real (100 + 13 - 5)
  ,'APPROVED'     -- Resultado
  ,'AUTH123'      -- Código de autorización
  ,'REF123456'    -- Número de referencia
  ,0xFEEDFACE     -- Token de cargo (binario)
  ,GETDATE()      -- Fecha
  ,0xDEADC0DE     -- Checksum (binario)
  ,2              -- statusid = Completado
  ,1              -- paymentmethodid → Tarjeta Demo
  ,1              -- availablemethodid → Tarjeta Demo disponible
  );



INSERT INTO sol_transactiontypes(name) VALUES
('Cobro'),('Reembolso'),('Ajuste');

INSERT INTO sol_transactionsubtypes(name) VALUES
('Pago inicial'), ('Pago recurrente'), ('Penalización');

INSERT INTO sol_exchangerates(startdate, enddate, exchangerate, currentexchangerate, currencyidsource, currencyiddestiny)
VALUES
  (GETDATE(), NULL, 0.0018, 1, 1, 2), (GETDATE(), NULL, 550.0000, 1, 2, 1);

INSERT INTO sol_contact_types (name, description) VALUES 
('Teléfono', 'Número de teléfono de usuario');

INSERT INTO sol_conditiontypes(name, datatype)
VALUES
  ('Cantidad de unidades',      'INT'),
  ('Porcentaje de descuento',   'DECIMAL'),
  ('Duración en días',          'INT'),
  ('Fecha límite',              'DATETIME'),
  ('Monto mínimo',              'DECIMAL'),
  ('Tasa fija',                 'DECIMAL'),
  ('Duración en horas',         'INT');

INSERT INTO sol_subscriptions (startdate, enddate, autorenew, statusid, scheduleid, userid, planid)
VALUES
    (DATEADD(DAY, -30, GETDATE()), DATEADD(YEAR, 1, GETDATE()), 1, 1, 3, 1, 1),
    (DATEADD(DAY, -15, GETDATE()), DATEADD(YEAR, 1, GETDATE()), 1, 1, 3, 2, 2),
    (DATEADD(DAY, -7, GETDATE()), DATEADD(YEAR, 1, GETDATE()), 1, 1, 3, 3, 3),
    (DATEADD(MONTH, -6, GETDATE()), DATEADD(MONTH, -1, GETDATE()), 0, 3, 2, 4, 1),
    (DATEADD(MONTH, -4, GETDATE()), DATEADD(MONTH, -2, GETDATE()), 0, 3, 2, 5, 2),
    (DATEADD(MONTH, -12, GETDATE()), DATEADD(MONTH, -6, GETDATE()), 0, 2, 1, 6, 3),
    (DATEADD(MONTH, -9, GETDATE()), DATEADD(MONTH, -3, GETDATE()), 0, 2, 1, 7, 4);

INSERT INTO sol_available_pay_methods(name, token, exp_token, mask_account, idMethod)
VALUES
    ('Tarjeta Oro', 'tok_gold_XYZ789', DATEADD(YEAR, 1, GETDATE()), '****5678', 1),
    ('PayPal Secundario', 'tok_paypal_ABC456', DATEADD(YEAR, 1, GETDATE()), 'backup@****.com', 3);

INSERT INTO sol_payments (amount, taxamount, discountporcent, realamount, result, authcode, referencenumber, date, statusid, paymentmethodid, availablemethodid)
VALUES
    (50.00, 6.50, 0.00, 56.50, 'APPROVED', 'AUTH001', 'REF1001', DATEADD(DAY, -30, GETDATE()), 2, 1, 1),
    (50.00, 6.50, 0.00, 56.50, 'APPROVED', 'AUTH002', 'REF1002', GETDATE(), 2, 1, 1),
    (75.00, 9.75, 5.00, 80.75, 'APPROVED', 'AUTH003', 'REF2001', DATEADD(DAY, -15, GETDATE()), 2, 3, 3),
    (100.00, 13.00, 10.00, 103.00, 'APPROVED', 'AUTH004', 'REF3001', DATEADD(DAY, -7, GETDATE()), 2, 1, 5),
    (50.00, 6.50, 0.00, 56.50, 'APPROVED', 'AUTH005', 'REF4001', DATEADD(MONTH, -6, GETDATE()), 2, 1, 1),
    (50.00, 6.50, 0.00, 56.50, 'APPROVED', 'AUTH006', 'REF4002', DATEADD(MONTH, -5, GETDATE()), 2, 1, 1),
    (75.00, 9.75, 0.00, 84.75, 'APPROVED', 'AUTH007', 'REF5001', DATEADD(MONTH, -4, GETDATE()), 2, 3, 3),
    (100.00, 13.00, 0.00, 113.00, 'APPROVED', 'AUTH008', 'REF6001', DATEADD(MONTH, -12, GETDATE()), 2, 1, 5),
    (100.00, 13.00, 0.00, 113.00, 'APPROVED', 'AUTH009', 'REF6002', DATEADD(MONTH, -11, GETDATE()), 2, 1, 5),
    (120.00, 15.60, 0.00, 135.60, 'APPROVED', 'AUTH010', 'REF7001', DATEADD(MONTH, -9, GETDATE()), 2, 1, 1);

INSERT INTO sol_paymentschedules (paymentid, scheduleid, nextpayment, lastpayment, remainingpayments, active)
VALUES
    (1, 3, DATEADD(MONTH, 1, DATEADD(DAY, -30, GETDATE())), DATEADD(DAY, -30, GETDATE()), 11, 1),
    (2, 3, DATEADD(MONTH, 2, GETDATE()), GETDATE(), 10, 1),
    (3, 3, DATEADD(MONTH, 1, DATEADD(DAY, -15, GETDATE())), DATEADD(DAY, -15, GETDATE()), NULL, 1),
    (4, 3, DATEADD(MONTH, 1, DATEADD(DAY, -7, GETDATE())), DATEADD(DAY, -7, GETDATE()), NULL, 1);

INSERT INTO dbo.sol_subsmemberstypes (name)
VALUES
  ('Administrador'),
  ('Invitado');

INSERT INTO sol_subscriptionmembers (membertype, isactive, usersubid)
VALUES
    (1, GETDATE(), 1),
    (1, GETDATE(), 2),
    (1, GETDATE(), 3),
    (1, DATEADD(MONTH, -6, GETDATE()), 4),
    (1, DATEADD(MONTH, -4, GETDATE()), 5),
    (1, DATEADD(MONTH, -12, GETDATE()), 6),
    (1, DATEADD(MONTH, -9, GETDATE()), 7);

INSERT INTO sol_accesscode (type, value, isactive, submembersid)
VALUES
    ('Gym Access', 0x01, 1, 3),
    ('Premium Access', 0x04, 1, 4),
    ('Coworking Access', 0x07, 1, 5);

INSERT INTO sol_featureusage (quantityused, porcentageconsumed, location, subid, submembersid, serviceid, codeid)
VALUES
    (10, 50, 'Location A', 1, 3, 1, 7),
    (5, 25, 'Location B', 1, 3, 2, 7),
    (15, 75, 'Location C', 2, 4, 3, 8),
    (20, 100, 'Location D', 2, 4, 4, 8),
    (8, 40, 'Location E', 3, 3, 5, 8),
    (12, 60, 'Location F', 4, 4, 1, 9),
    (18, 90, 'Location G', 5, 5, 3, 9),
    (7, 35, 'Location H', 6, 6, 5, 10),
    (9, 45, 'Location I', 7, 7, 2, 10);

INSERT INTO sol_planprices (amount, postTime, endDate, [current], planid)
VALUES
    (50.00, DATEADD(MONTH, -3, GETDATE()), DATEADD(MONTH, 3, GETDATE()), 0, 1),
    (55.00, GETDATE(), DATEADD(YEAR, 1, GETDATE()), 1, 1),
    (75.00, DATEADD(MONTH, -2, GETDATE()), DATEADD(MONTH, 4, GETDATE()), 1, 2),
    (100.00, DATEADD(MONTH, -1, GETDATE()), DATEADD(MONTH, 5, GETDATE()), 1, 3),
    (120.00, GETDATE(), DATEADD(YEAR, 1, GETDATE()), 1, 4);
GO