USE SolturaDB;
GO

-- 1. Creación de usuarios de prueba y manejo de acceso básico
CREATE LOGIN [UsuarioSoloLectura] WITH PASSWORD = 'Lectura123*';
CREATE LOGIN [UsuarioSinAcceso] WITH PASSWORD = 'SinAcceso123*';
CREATE LOGIN [UsuarioEjecutorSP] WITH PASSWORD = 'EjecutorSP123*';
CREATE LOGIN [UsuarioRLS] WITH PASSWORD = 'RLSuser123*';
GO

USE SolturaDB;
GO

CREATE USER [UsuarioSoloLectura] FOR LOGIN [UsuarioSoloLectura]; --podrá SELECT en todas las tablas
CREATE USER [UsuarioSinAcceso] FOR LOGIN [UsuarioSinAcceso];
CREATE USER [UsuarioEjecutorSP] FOR LOGIN [UsuarioEjecutorSP]; --podrá ejecutar el SP pero no hacer SELECT directo en la tabla
CREATE USER [UsuarioRLS] FOR LOGIN [UsuarioRLS];
GO

DENY CONNECT TO [UsuarioSinAcceso];
GO

-- 2. Permisos SELECT específicos y roles
-- Crear roles
CREATE ROLE [RolLecturaGeneral];
CREATE ROLE [RolLecturaRestringida];
GO

ALTER ROLE [RolLecturaGeneral] ADD MEMBER [UsuarioSoloLectura];
GO

GRANT SELECT ON SCHEMA::dbo TO [RolLecturaGeneral];
GO

GRANT SELECT ON OBJECT::[sol_users] TO [RolLecturaRestringida];
GO

-- 3. Permisos para SPs con restricción de tablas
CREATE OR ALTER PROCEDURE sp_GetUserInfo
AS
BEGIN
    SELECT userid, username, firstname, lastname, email 
    FROM sol_users;
END;
GO

GRANT EXECUTE ON OBJECT::[sp_GetUserInfo] TO [UsuarioEjecutorSP];
GO

DENY SELECT ON OBJECT::[sol_users] TO [UsuarioEjecutorSP];
GO

-- 4. Implementación de Row-Level Security (RLS)
CREATE SCHEMA Security;
GO

-- Crear tabla de mapeo para RLS
CREATE TABLE Security.UserAccess
(
    username SYSNAME PRIMARY KEY,
    cityid INT NOT NULL
);
GO

INSERT INTO Security.UserAccess (username, cityid)
VALUES
('UsuarioRLS', 1);
GO

CREATE FUNCTION Security.fn_securitypredicate(@cityid AS INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result
FROM Security.UserAccess
WHERE USER_NAME() = username AND cityid = @cityid;
GO

CREATE SECURITY POLICY Security.UserFilter
ADD FILTER PREDICATE Security.fn_securitypredicate(cityid)
ON dbo.sol_cities
WITH (STATE = ON);
GO

GRANT SELECT ON [sol_cities] TO [UsuarioRLS];
GRANT SELECT ON [sol_address] TO [UsuarioRLS];
GRANT SELECT ON [sol_users] TO [UsuarioRLS];
GO

-- 5. Creación de certificado y llave asimétrica
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKeyPassword123*';
GO

CREATE CERTIFICATE CertificadoSoltura
WITH SUBJECT = 'Certificado para cifrado SolturaDB';
GO

CREATE ASYMMETRIC KEY LlaveAsimetricaSoltura
WITH ALGORITHM = RSA_2048;
GO

-- 6. Creación de llave simétrica
CREATE SYMMETRIC KEY LlaveSimetricaSoltura
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertificadoSoltura;
GO

-- 7. Cifrado de datos sensibles y protección con llaves
ALTER TABLE sol_users ADD email_cifrado VARBINARY(MAX);
GO

-- Datos cifrados
OPEN SYMMETRIC KEY LlaveSimetricaSoltura
DECRYPTION BY CERTIFICATE CertificadoSoltura;

UPDATE sol_users
SET email_cifrado = ENCRYPTBYKEY(KEY_GUID('LlaveSimetricaSoltura'), email);
GO

-- 8. Creación de SP para descifrar datos
CREATE OR ALTER PROCEDURE sp_GetEmailDecrypted
    @userid INT
AS
BEGIN
    OPEN SYMMETRIC KEY LlaveSimetricaSoltura
    DECRYPTION BY CERTIFICATE CertificadoSoltura;
    
    SELECT 
        userid,
        username,
        CONVERT(VARCHAR(150), DECRYPTBYKEY(email_cifrado)) AS email_decrypted
    FROM sol_users
    WHERE userid = @userid;
    
    CLOSE SYMMETRIC KEY LlaveSimetricaSoltura;
END;
GO

GRANT EXECUTE ON OBJECT::[sp_GetEmailDecrypted] TO [UsuarioSoloLectura];
GO