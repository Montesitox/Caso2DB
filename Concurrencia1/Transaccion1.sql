-- TRANSACCIÓN 1 - Ejecutar primero
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    -- 1. SELECT en sol_service (adquiere lock compartido)
    DECLARE @servicePrice DECIMAL(10,2);
    SELECT @servicePrice = sale_amount 
    FROM dbo.sol_service WITH (UPDLOCK) -- FORZAMOS lock de UPDATE para el SELECT
    WHERE serviceid = 1;
    
    PRINT 'T1: Consultó precio del servicio 1: ' + CAST(@servicePrice AS VARCHAR);
    
    -- Espera para permitir que T2 avance
    WAITFOR DELAY '00:00:03';
    
    -- 2. UPDATE en sol_subscriptions (necesita lock exclusivo)
    UPDATE dbo.sol_subscriptions
    SET statusid = 2 -- Cambia estado
    WHERE subid = 1;
    
    PRINT 'T1: Actualizó suscripción 1';
COMMIT;
PRINT 'T1: Transacción completada';