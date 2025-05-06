USE SolturaDB
GO;

BEGIN TRANSACTION;

-- C bloquea algo que A usará
UPDATE sol_services SET service_name = service_name WHERE serviceid = 1;

WAITFOR DELAY '00:00:10';

-- Luego C necesita algo que B tiene
UPDATE sol_users SET username = username WHERE userid = 1;

COMMIT;

--para obtener un ciclo completo, hace falta mucha coordinación y suerte.

--En caso de conseguirse, SQL detectará el deadlock y eliminará una transacción