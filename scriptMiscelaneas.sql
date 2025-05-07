USE SolturaDB

USE SolturaDB

-- 1. Crear la vista
CREATE VIEW dbo.vw_UserSubscriptions
WITH SCHEMABINDING
AS
SELECT
    u.userid,
    u.username,
    s.subid,
    s.planid,
    p.name       AS plan_name,
    COUNT_BIG(*) AS feature_count
FROM dbo.sol_users       AS u
JOIN dbo.sol_subscriptions AS s ON s.userid = u.userid
JOIN dbo.sol_plans        AS p ON p.planid = s.planid
JOIN dbo.sol_planfeatures AS pf ON pf.plantid = p.planid
GROUP BY
    u.userid,
    u.username,
    s.subid,
    s.planid,
    p.name;
GO

-- Crear el índice único agrupado sobre la vista
CREATE UNIQUE CLUSTERED INDEX IX_vw_UserSubscriptions
    ON dbo.vw_UserSubscriptions(userid, subid, planid);
GO

SELECT * 
FROM dbo.vw_UserSubscriptions
WHERE username = 'demo_user';
GO

-- 2) Insertar un usuario demo y capturar su UserID
DECLARE @NewUserID INT;
INSERT INTO dbo.sol_users (username, firstname, lastname, email, password, isActive, addressid)
VALUES ('demo_user','Demo','User','demo@example.com',0x706173,1,1);
SET @NewUserID = SCOPE_IDENTITY();

-- 3) Insertar una suscripción para ese usuario y capturar SubID
DECLARE @NewSubID INT;
INSERT INTO dbo.sol_subscriptions (startdate, enddate, autorenew, statusid, scheduleid, planid, userid)
VALUES (GETDATE(), DATEADD(MONTH,1,GETDATE()), 1, 1, 1, 1, @NewUserID);
SET @NewSubID = SCOPE_IDENTITY();
GO

SELECT * 
FROM dbo.vw_UserSubscriptions
WHERE username = 'demo_user';
GO

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

EXEC dbo.CrearSubscripcionMensual @UserId=1,@PlanId=1,@Amount=120.00,@PaymentMethodId=1; 
SELECT * FROM sol_subscriptions

EXEC dbo.CrearSubscripcionMensual @UserId=1,@PlanId=1,@Amount=200.00,@PaymentMethodId=999;
SELECT * FROM sol_subscriptions

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

-- 4. Reporte Analítico: Rendimiento de Planes con Métricas de Suscripción, Pagos y Uso de Características
USE SolturaDB;
GO

WITH SubscriptionsSummary AS (
    -- CTE 1: Resumen de suscripciones por plan
    SELECT 
        p.planid,
        p.name AS plan_name,
        COUNT(s.subid) AS total_subscriptions,
        SUM(CASE WHEN s.statusid = 1 THEN 1 ELSE 0 END) AS active_subscriptions,
        AVG(DATEDIFF(DAY, s.startdate, s.enddate)) AS avg_duration_days
    FROM 
        dbo.sol_subscriptions s
    JOIN 
        dbo.sol_plans p ON s.planid = p.planid
    GROUP BY 
        p.planid, p.name
),
PaymentAnalysis AS (
    -- CTE 2: Análisis de pagos por suscripción
    SELECT 
        sub.subid,
        SUM(p.amount) AS total_paid,
        AVG(p.amount) AS avg_payment,
        COUNT(p.paymentid) AS payment_count,
        MAX(p.date) AS last_payment_date
    FROM 
        dbo.sol_payments p
    JOIN 
        dbo.sol_paymentschedules ps ON p.paymentid = ps.paymentid
    JOIN
        dbo.sol_subscriptions sub ON ps.scheduleid = sub.scheduleid
    WHERE 
        p.statusid IN (SELECT paymentstatusid FROM dbo.sol_paymentstatus WHERE name IN ('Completado'))
    GROUP BY 
        sub.subid
),
FeatureUsageStats AS (
    -- CTE 3: Estadísticas de uso de características
    SELECT 
        fu.subid,
        fu.serviceid,
        sv.name AS service_name,
        SUM(fu.quantityused) AS total_usage,
        AVG(fu.porcentageconsumed) AS avg_consumption
    FROM 
        dbo.sol_featureusage fu
    JOIN 
        dbo.sol_service sv ON fu.serviceid = sv.serviceid
    GROUP BY 
        fu.subid, fu.serviceid, sv.name
)

SELECT 
    ss.planid,
    ss.plan_name,
    ss.total_subscriptions,
    ss.active_subscriptions,
    CONVERT(VARCHAR(10), ss.avg_duration_days) + ' days' AS avg_duration,
    pp.amount AS current_plan_price,
    COALESCE(SUM(pa.total_paid), 0) AS total_revenue,
    COALESCE(AVG(pa.avg_payment), 0) AS avg_revenue_per_subscription,
    (
        SELECT COUNT(*) 
        FROM dbo.sol_users u 
        WHERE u.userid IN (
            SELECT userid FROM dbo.sol_subscriptions WHERE planid = ss.planid
        )
    ) AS unique_users,
    CASE 
        WHEN ss.active_subscriptions > 0 THEN 'ACTIVE'
        WHEN ss.total_subscriptions > 0 THEN 'INACTIVE'
        ELSE 'NEW'
    END AS plan_status,
    (
        SELECT TOP 1 sv.name 
        FROM FeatureUsageStats fus 
        JOIN dbo.sol_service sv ON fus.serviceid = sv.serviceid
        WHERE fus.subid IN (
            SELECT subid FROM dbo.sol_subscriptions WHERE planid = ss.planid
        )
        ORDER BY fus.total_usage DESC
    ) AS most_used_feature
FROM 
    SubscriptionsSummary ss
LEFT JOIN 
    dbo.sol_planprices pp ON ss.planid = pp.planid AND pp.[current] = 1
LEFT JOIN 
    dbo.sol_subscriptions s ON ss.planid = s.planid
LEFT JOIN 
    PaymentAnalysis pa ON s.subid = pa.subid
WHERE 
    EXISTS (
        SELECT 1 FROM dbo.sol_planfeatures pf 
        WHERE pf.plantid = ss.planid AND pf.enabled = 1
    )
    AND ss.planid NOT IN (
        SELECT planid FROM dbo.sol_plans WHERE enabled = 0
    )
GROUP BY 
    ss.planid,
    ss.plan_name,
    ss.total_subscriptions,
    ss.active_subscriptions,
    ss.avg_duration_days,
    pp.amount
HAVING 
    COALESCE(SUM(pa.total_paid), 0) > 0
ORDER BY 
    total_revenue DESC,
    active_subscriptions DESC;
GO

-- 5. INTERSECT y SET DIFFERENCE
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


-- 6. 3 niveles SP Transaccionales (Duda)
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

----------------------------------------
-- DEMOSTRACIÓN: llamadas exitosas y fallidas
----------------------------------------

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

-- 7. JSON
-- Si es posible por medio de una consulta crear un JSON, esto retorna todos los planes que tienen todos los usuarios, esto nos
-- serviria para la pantalla de dashboard de planes, o ver los registros de todas las subscripciones
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

-- 8. TVP
USE Soltura_DB;
GO

-- 1) Definir el TVP con las columnas que definen cada condición del contrato
CREATE TYPE dbo.TVP_ContractCondition AS TABLE(
  ServiceID       INT          NOT NULL,  -- a qué servicio aplica
  ProviderPrice   DECIMAL(10,2) NOT NULL, -- precio que cobra el proveedor
  MarginType      VARCHAR(10)   NOT NULL, -- 'PERCENT' o 'FIXED'
  MarginValue     DECIMAL(10,2) NOT NULL, -- valor del margen
  SolturaPercent  DECIMAL(5,2)  NOT NULL, -- % que retiene Soltura
  ClientPercent   DECIMAL(5,2)  NOT NULL  -- % que va al cliente
);
GO


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

-- 9. CSV
SELECT
  u.userid,
  u.username,
  s.planid
FROM sol_users u
JOIN sol_subscriptions s ON s.userid=u.userid
FOR XML RAW('row'), ROOT('rows'), TYPE

-- 10. En servidor principal: (No se si está bien así)
USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.servers WHERE name = 'REMOTE_SRV')
BEGIN
  EXEC sp_addlinkedserver 
    @server     = N'REMOTE_SRV',
    @srvproduct = N'',
    @provider   = N'SQLNCLI',           -- proveedor OLE DB de SQL Server
    @datasrc    = N'RemoteHostName';    -- nombre o IP del servidor remoto

  EXEC sp_addlinkedsrvlogin
    @rmtsrvname  = N'REMOTE_SRV',
    @useself     = N'False',
    @locallogin  = NULL,                -- todas las conexiones locales
    @rmtuser     = N'remoteUser',       -- credenciales válidas en REMOTE_SRV
    @rmtpassword = N'remotePassword';
END
GO

EXEC sp_serveroption 
  @server   = N'REMOTE_SRV', 
  @optname  = N'rpc', 
  @optvalue = N'true';

-- Habilitar llamadas RPC salientes (desde este servidor hacia REMOTE_SRV)
EXEC sp_serveroption 
  @server   = N'REMOTE_SRV', 
  @optname  = N'rpc out', 
  @optvalue = N'true';
GO

EXECUTE(N'
  IF OBJECT_ID(''SolturaDB.dbo.SystemLog'', ''U'') IS NOT NULL
    DROP TABLE SolturaDB.dbo.SystemLog;

  CREATE TABLE SolturaDB.dbo.SystemLog (
    LogID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    LogDate   DATETIME         NOT NULL,
    Source    NVARCHAR(100)    NOT NULL,
    Message   NVARCHAR(MAX)    NOT NULL
  );
') AT REMOTE_SRV;
GO

USE SolturaDB;
GO

CREATE OR ALTER PROCEDURE dbo.WriteRemoteLog
  @Source  NVARCHAR(100),
  @Message NVARCHAR(MAX),
  @LogDate DATETIME = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
  SET NOCOUNT, XACT_ABORT ON;

  IF @LogDate IS NULL
    SET @LogDate = GETDATE();

  INSERT INTO REMOTE_SRV.SolturaDB.dbo.SystemLog
    (LogDate, Source, Message)
  VALUES
    (@LogDate, @Source, @Message);
END;
GO

EXEC dbo.WriteRemoteLog
  @Source  = 'NombreDelSP',
  @Message = 'Descripción del evento que quiero registrar';
