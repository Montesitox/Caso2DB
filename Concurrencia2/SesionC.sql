-- TRANSACCIÓN C
USE SolturaDB;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    -- 1. Bloquear pago
    UPDATE dbo.sol_payments
    SET amount = amount * 0.9
    WHERE paymentid = 1;
    
    PRINT 'C: Bloqueado pago 1 - esperando 5 segundos';
    WAITFOR DELAY '00:00:05';
    
    -- 2. Intentar bloquear servicio
    UPDATE dbo.sol_service
    SET description = 'Modificado por Transacción C'
    WHERE serviceid = 1;
    
    PRINT 'C: Bloqueado servicio 1';
COMMIT;
PRINT 'C: Transacción completada';