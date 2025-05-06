USE SolturaDB
GO;

BEGIN TRANSACTION;

-- Paso 1: SELECT en sol_users
SELECT * FROM sol_users WHERE userid = 1;

WAITFOR DELAY '00:00:05';

-- Paso 2: UPDATE en sol_services
UPDATE sol_services SET name = name
WHERE serviceid = 1;

COMMIT;
