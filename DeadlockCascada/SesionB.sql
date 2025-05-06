use SolturaDB
Go;

BEGIN TRANSACTION;

-- B bloquea algo que C usará
UPDATE sol_payments SET amount = amount WHERE paymentid = 1;

WAITFOR DELAY '00:00:10';

-- Luego B necesita algo que A tiene
UPDATE sol_services SET service_name = service_name WHERE serviceid = 1;

COMMIT;