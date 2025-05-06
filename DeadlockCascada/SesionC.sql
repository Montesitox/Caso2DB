USE SolturaDB
GO;

BEGIN TRANSACTION;

-- C bloquea algo que A usar�
UPDATE sol_services SET service_name = service_name WHERE serviceid = 1;

WAITFOR DELAY '00:00:10';

-- Luego C necesita algo que B tiene
UPDATE sol_users SET username = username WHERE userid = 1;

COMMIT;

--para obtener un ciclo completo, hace falta mucha coordinaci�n y suerte.

--En caso de conseguirse, SQL detectar� el deadlock y eliminar� una transacci�n