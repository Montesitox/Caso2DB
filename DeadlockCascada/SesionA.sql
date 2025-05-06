USE SolturaDB
GO;

BEGIN TRANSACTION;

-- A bloquea algo que B usará
UPDATE sol_users SET username = username WHERE userid = 1;

WAITFOR DELAY '00:00:10';

-- Luego A necesita algo que C tiene
UPDATE sol_payments SET amount = amount WHERE paymentid = 1;

COMMIT;
