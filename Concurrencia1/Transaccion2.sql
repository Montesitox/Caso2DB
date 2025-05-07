-- TRANSACCIÓN 2 - Ejecutar durante el WAITFOR de T1
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    -- 1. SELECT en sol_subscriptions (adquiere lock compartido)
    DECLARE @subStatus INT;
    SELECT @subStatus = statusid 
    FROM dbo.sol_subscriptions WITH (UPDLOCK) -- FORZAMOS lock de UPDATE para el SELECT
    WHERE subid = 1;
    
    PRINT 'T2: Consultó estado de suscripción 1: ' + CAST(@subStatus AS VARCHAR);
    
    -- Espera para permitir que T1 avance
    WAITFOR DELAY '00:00:03';
    
    -- 2. UPDATE en sol_service (necesita lock exclusivo)
    UPDATE dbo.sol_service
    SET sale_amount = sale_amount * 1.1 -- Aumenta precio 10%
    WHERE serviceid = 1;
    
    PRINT 'T2: Actualizó servicio 1';
COMMIT;
PRINT 'T2: Transacción completada';