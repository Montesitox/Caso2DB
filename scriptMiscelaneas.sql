-- 1. Crear la vista
CREATE VIEW dbo.vw_PagoSubscripciones
WITH SCHEMABINDING
AS
SELECT
    u.userid,
    u.username,
    s.subid,
    s.planid,
    p.paymentid,
    p.amount,
    srv.serviceid,
    srv.name AS service_name
FROM dbo.sol_users       AS u
JOIN dbo.sol_subscriptions AS s ON s.userid = u.userid
JOIN dbo.sol_payments      AS p ON p.paymentid = s.userid
JOIN dbo.sol_service       AS srv ON srv.contractid = p.statusid
GO


CREATE UNIQUE CLUSTERED INDEX IX_vw_PagoSubscripciones 
    ON dbo.vw_PagoSubscripciones(userid, subid, paymentid, serviceid);

SELECT * FROM dbo.vw_PagoSubscripciones

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
  serviceid,
  name,
  sale_amount,
  CASE
    WHEN sale_amount < 100    THEN 'Económico'
    WHEN sale_amount BETWEEN 100 AND 200 THEN 'Medio'
    ELSE 'Premium'
  END AS price_category
FROM sol_service;

-- 5. Intersection: usuarios con pago y suscripción (Dudas si se hace así)
SELECT u.userid
FROM sol_users u
JOIN sol_subscriptions s ON s.userid = u.userid
JOIN sol_payments      p ON p.paymentid = s.userid;

-- Difference: usuarios con suscripción pero sin pago (Dudas si se hace así)
SELECT s.userid
FROM sol_subscriptions s
WHERE s.userid NOT IN (SELECT paymentid FROM sol_payments);

-- 7. JSON
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

-- 9. CSV
SELECT
  u.userid,
  u.username,
  s.planid
FROM sol_users u
JOIN sol_subscriptions s ON s.userid=u.userid
FOR XML RAW('row'), ROOT('rows'), TYPE

-- 10. En servidor principal: (No se si está bien así)
CREATE PROCEDURE dbo.usp_LogToRemote
  @Msg NVARCHAR(4000)
AS
BEGIN
  EXEC [RemoteServer].SolturaLogDB.dbo.usp_InsertLog @Msg;
END;
GO

-- En servidor remoto (Linked Server):
CREATE PROCEDURE dbo.usp_InsertLog
  @Msg NVARCHAR(4000)
AS
BEGIN
  INSERT INTO dbo.LogTable(LogDate,Message)
  VALUES(GETDATE(),@Msg);
END;
GO

--Luego, desde cualquier SP en el servidor principal:
EXEC dbo.usp_LogToRemote 'Mensaje de bitácora';
