-- TRANSACCI�N 1 -
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    DECLARE @servicePrice DECIMAL(10,2);
    SELECT @servicePrice = sale_amount 
    FROM dbo.sol_service WITH (UPDLOCK)
    WHERE serviceid = 1;
    
    PRINT 'T1: Consult� precio del servicio 1: ' + CAST(@servicePrice AS VARCHAR);
    
    WAITFOR DELAY '00:00:03';
    
    UPDATE dbo.sol_subscriptions
    SET statusid = 2
    WHERE subid = 1;
    
    PRINT 'T1: Actualiz� suscripci�n 1';
COMMIT;
PRINT 'T1: Transacci�n completada';