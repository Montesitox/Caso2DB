USE Soltura_DB;
GO

/*
=======================================================
SCRIPT DE DEMOSTRACIONES T-SQL PARA SOLTURA_DB
=======================================================
*/

-- ===============================================
-- 1 y 2. CURSORES LOCAL Y GLOBAL en un solo script
-- ===============================================
PRINT '1 y 2. Demostración de CURSORES LOCAL y GLOBAL';

DECLARE @planid INT, @planname VARCHAR(75);

-- Cursores LOCAL solo visibles en la sesión actual
DECLARE plan_cursor LOCAL CURSOR FOR 
SELECT planid, name FROM sol_plans WHERE enabled = 1;

DECLARE @userid INT, @username VARCHAR(100);

-- Cursores GLOBAL visibles desde otras sesiones
DECLARE user_cursor GLOBAL CURSOR FOR 
SELECT userid, username FROM sol_users WHERE isActive = 1;


OPEN plan_cursor;
FETCH NEXT FROM plan_cursor INTO @planid, @planname;
PRINT 'Primer plan (cursor LOCAL): ID=' + CAST(@planid AS VARCHAR) + ', Nombre=' + @planname;
CLOSE plan_cursor;
DEALLOCATE plan_cursor;

OPEN user_cursor;
FETCH NEXT FROM user_cursor INTO @userid, @username;
PRINT 'Primer usuario (cursor GLOBAL): ID=' + CAST(@userid AS VARCHAR) + ', Usuario=' + @username;
CLOSE user_cursor;

DEALLOCATE user_cursor;
GO

-- ===============================================
-- 3. TRIGGER con 4. RECOMPILACIÓN
-- ===============================================
PRINT '3. TRIGGER y 4. RECOMPILACIÓN';


IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'sol_payment_logs')
BEGIN
    CREATE TABLE dbo.sol_payment_logs (
        log_id INT IDENTITY(1,1) PRIMARY KEY,
        payment_id INT NOT NULL,
        amount DECIMAL(10,2) NOT NULL,
        action_type VARCHAR(20) NOT NULL,
        action_date DATETIME NOT NULL DEFAULT GETDATE(),
        user_id VARCHAR(50) NOT NULL DEFAULT SYSTEM_USER
    );
END;

-- Crear trigger para pagos 
CREATE OR ALTER TRIGGER trg_sol_payments_insert
ON dbo.sol_payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Registrar el pago en la tabla de logs
    INSERT INTO sol_payment_logs (payment_id, amount, action_type)
    SELECT paymentid, amount, 'INSERT'
    FROM inserted;
    
    -- Usar sp_recompile para forzar la recompilación del plan de ejecución
    -- de un procedimiento relacionado con pagos
    EXEC sp_recompile 'dbo.sol_payments';
    
    PRINT 'Pago registrado y se ha forzado la recompilación del plan de ejecución.';
END;
GO

-- Procedimiento para recompilar todos los SPs
CREATE OR ALTER PROCEDURE dbo.RecompileAllProcedures
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @procname NVARCHAR(255);
    DECLARE proc_cursor CURSOR FOR
        SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES
        WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_SCHEMA = 'dbo';
    
    OPEN proc_cursor;
    FETCH NEXT FROM proc_cursor INTO @procname;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC sp_recompile @procname;
            PRINT 'Recompilado: ' + @procname;
        END TRY
        BEGIN CATCH
            PRINT 'Error al recompilar ' + @procname + ': ' + ERROR_MESSAGE();
        END CATCH
        
        FETCH NEXT FROM proc_cursor INTO @procname;
    END
    
    CLOSE proc_cursor;
    DEALLOCATE proc_cursor;
END;
GO

-- ===============================================
-- 5. MERGE con 13. WITH ENCRYPTION y 14. EXECUTE AS
-- ===============================================
PRINT '5. MERGE, 13. WITH ENCRYPTION y 14. EXECUTE AS';

CREATE OR ALTER PROCEDURE dbo.SyncPlans
WITH ENCRYPTION, EXECUTE AS 'dbo'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verificar el contexto de ejecución
    PRINT 'Ejecutando como: ' + USER_NAME();
    
    -- Crear tabla temporal con datos "externos" para sincronizar
    CREATE TABLE #ExternalPlans (
        ext_id INT PRIMARY KEY,
        name VARCHAR(75) NOT NULL,
        description TEXT NULL,
        limit_people SMALLINT NOT NULL,
        enabled BIT NOT NULL
    );
    
    INSERT INTO #ExternalPlans VALUES 
        (1, 'Plan Básico v2', 'Actualización del plan básico', 5, 1),
        (2, 'Plan Premium v2', 'Actualización del plan premium', 10, 1),
        (3, 'Plan Empresarial Nuevo', 'Nuevo plan para empresas', 25, 1);
    
    -- MERGE para sincronizar
    MERGE dbo.sol_plans AS target
    USING #ExternalPlans AS source
    ON (target.codigoid = source.ext_id)
    WHEN MATCHED THEN
        UPDATE SET 
            target.name = source.name,
            target.description = source.description,
            target.limit_people = source.limit_people,
            target.enabled = source.enabled
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (name, description, customizable, limit_people, enabled, codigoid)
        VALUES (source.name, source.description, 1, source.limit_people, source.enabled, source.ext_id)
    OUTPUT $action, inserted.planid, inserted.name;
    
    DROP TABLE #ExternalPlans;
END;
GO

SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.SyncPlans')) AS encrypted_procedure;
GO

-- ===============================================
-- 6. COALESCE, 7. SUBSTRING, 8. LTRIM en una sola consulta
-- ===============================================
PRINT '6. COALESCE, 7. SUBSTRING, 8. LTRIM en una consulta';

SELECT 
    u.userid,
    -- COALESCE para manejar valores nulos
    COALESCE(u.username, 'Sin usuario') AS username,
    COALESCE(u.email, 'Sin correo') AS email,
    
    -- SUBSTRING para extraer partes de texto
    SUBSTRING(u.firstname, 1, 1) + '.' AS initial,
    SUBSTRING(u.email, 1, CHARINDEX('@', u.email) - 1) AS email_username,
    
    -- LTRIM para limpiar strings
    LTRIM(RTRIM(u.firstname)) + ' ' + LTRIM(RTRIM(u.lastname)) AS clean_fullname
FROM 
    sol_users u
LEFT JOIN 
    sol_user_preferences up ON u.userid = up.userid;
GO

-- ===============================================
-- 9. AVG con agrupamiento y 10. TOP
-- ===============================================
PRINT '9. AVG con agrupamiento y 10. TOP';

-- Obtener el TOP 5 usuarios con el promedio más alto de pagos
SELECT TOP 5
    u.userid,
    u.username,
    -- AVG con agrupamiento
    AVG(p.amount) AS avg_payment,
    COUNT(p.paymentid) AS payment_count,
    MAX(p.amount) AS max_payment
FROM 
    sol_users u
JOIN 
    sol_subscriptions s ON u.userid = s.userid
JOIN 
    sol_paymentschedules ps ON s.scheduleid = ps.scheduleid
JOIN 
    sol_payments p ON ps.paymentid = p.paymentid
GROUP BY 
    u.userid, u.username
HAVING 
    COUNT(p.paymentid) > 0
ORDER BY 
    AVG(p.amount) DESC;
GO

-- ===============================================
-- 11. && (AND) con 15. UNION y 16. DISTINCT
-- ===============================================
PRINT '11. AND (&&), 15. UNION y 16. DISTINCT';

SELECT DISTINCT -- Usar DISTINCT para eliminar duplicados
    'Individual' AS plan_type,
    p.planid,
    p.name,
    pp.amount
FROM 
    sol_plans p
JOIN 
    sol_planprices pp ON p.planid = pp.planid
WHERE 

    p.limit_people <= 5 AND
    pp.[current] = 1 AND
    p.enabled = 1

UNION 

-- Planes empresariales 
SELECT DISTINCT
    'Empresarial' AS plan_type,
    p.planid,
    p.name,
    pp.amount
FROM 
    sol_plans p
JOIN 
    sol_planprices pp ON p.planid = pp.planid
WHERE 
    p.limit_people > 5 AND
    pp.[current] = 1 AND
    p.enabled = 1
    
ORDER BY 
    plan_type, amount;
GO

-- ===============================================
-- 12. SCHEMABINDING en una vista
-- ===============================================
PRINT '12. SCHEMABINDING en una vista';

-- Crear vista con SCHEMABINDING
CREATE OR ALTER VIEW dbo.vw_ActiveSubscriptionsWithPrices
WITH SCHEMABINDING
AS
SELECT 
    s.subid, 
    u.userid,
    u.username,
    p.planid,
    p.name AS plan_name,
    pp.amount AS plan_price,
    s.startdate,
    s.enddate
FROM 
    dbo.sol_subscriptions s
JOIN 
    dbo.sol_users u ON s.userid = u.userid
JOIN 
    dbo.sol_plans p ON s.planid = p.planid
JOIN 
    dbo.sol_planprices pp ON p.planid = pp.planid
WHERE 
    pp.[current] = 1 AND
    s.autorenew = 1;
GO

-- ALTER TABLE dbo.sol_planprices DROP COLUMN [current];

-- Consultar la vista
SELECT 
    plan_name, 
    COUNT(*) AS subscription_count, 
    AVG(plan_price) AS avg_price
FROM 
    dbo.vw_ActiveSubscriptionsWithPrices
GROUP BY 
    plan_name
ORDER BY 
    subscription_count DESC;
GO