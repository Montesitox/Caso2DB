USE SolturaDB
GO;

BEGIN TRANSACTION;

-- Paso 1: SELECT en sol_services
SELECT * FROM sol_services WHERE serviceid = 1;

WAITFOR DELAY '00:00:05';

-- Paso 2: UPDATE en sol_users
UPDATE sol_users SET username = username
WHERE userid = 1;

COMMIT;