-- TRANSACCI�N A - Ejecutar primero
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    -- 1. Bloquear servicio
    UPDATE dbo.sol_service 
    SET description = 'Modificado por Transacci�n A'
    WHERE serviceid = 1;
    
    PRINT 'A: Bloqueado servicio 1 - esperando 5 segundos';
    WAITFOR DELAY '00:00:05';
    
    -- 2. Intentar bloquear suscripci�n
    UPDATE dbo.sol_subscriptions
    SET statusid = 2
    WHERE subid = 1;
    
    PRINT 'A: Bloqueada suscripci�n 1';
COMMIT;
PRINT 'A: Transacci�n completada';