-- TRANSACCIÓN B
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    -- 1. Bloquear suscripción
    UPDATE dbo.sol_subscriptions
    SET statusid = 3
    WHERE subid = 1;
    
    PRINT 'B: Bloqueada suscripción 1 - esperando 5 segundos';
    WAITFOR DELAY '00:00:05';
    
    -- 2. Intentar bloquear pago
    UPDATE dbo.sol_payments
    SET amount = amount * 1.1
    WHERE paymentid = 1;
    
    PRINT 'B: Bloqueado pago 1';
COMMIT;
PRINT 'B: Transacción completada';