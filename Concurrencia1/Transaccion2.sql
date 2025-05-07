-- TRANSACCI�N 2 -
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    DECLARE @subStatus INT;
    SELECT @subStatus = statusid 
    FROM dbo.sol_subscriptions WITH (UPDLOCK)
    WHERE subid = 1;
    
    PRINT 'T2: Consult� estado de suscripci�n 1: ' + CAST(@subStatus AS VARCHAR);
    
    WAITFOR DELAY '00:00:03';
    
    UPDATE dbo.sol_service
    SET sale_amount = sale_amount * 1.1
    WHERE serviceid = 1;
    
    PRINT 'T2: Actualiz� servicio 1';
COMMIT;
PRINT 'T2: Transacci�n completada';