-- TRANSACCIÓN 2 -
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    DECLARE @subStatus INT;
    SELECT @subStatus = statusid 
    FROM dbo.sol_subscriptions WITH (UPDLOCK)
    WHERE subid = 1;
    
    PRINT 'T2: Consultó estado de suscripción 1: ' + CAST(@subStatus AS VARCHAR);
    
    WAITFOR DELAY '00:00:03';
    
    UPDATE dbo.sol_service
    SET sale_amount = sale_amount * 1.1
    WHERE serviceid = 1;
    
    PRINT 'T2: Actualizó servicio 1';
COMMIT;
PRINT 'T2: Transacción completada';