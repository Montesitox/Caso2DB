
-- 1) INTENTO DE UPDATE SOBRE LA MISMA FILA
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;
  PRINT 'Intentando UPDATE sobre Id=1 (debe quedar BLOQUEADO hasta COMMIT de Sesión1)...';
  UPDATE dbo.TestLocks
    SET Value = 'Other'
  WHERE Id = 1;
 ROLLBACK;
GO

-- 2) SELECT CON NOLOCK (LECTURA SUCIA PERMITIDA)
PRINT 'SELECT WITH (NOLOCK) sobre Id=1 (no bloquea, devuelve dato aunque esté locked)...';
SELECT *
FROM dbo.TestLocks WITH (NOLOCK)
WHERE Id = 1;
GO

-- 3) UPDATE SOBRE OTRA FILA (no bloqueada por el cursor)
BEGIN TRAN;
  PRINT 'UPDATE sobre Id=2 (no está locked, debe ejecutarse inmediatamente)...';
  UPDATE dbo.TestLocks
    SET Value = 'Other2'
  WHERE Id = 2;
COMMIT;
GO