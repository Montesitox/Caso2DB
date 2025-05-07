-- Crear sesión de Extended Events
CREATE EVENT SESSION [Deadlock_Monitor] ON SERVER 
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(
    SET filename = N'Deadlock_Monitor',
    max_file_size = 5
)
WITH (STARTUP_STATE = OFF);
GO

-- Iniciar la sesión
ALTER EVENT SESSION [Deadlock_Monitor] ON SERVER STATE = START;
GO

-- Para saber la ubicación del archivo con el monitor
SELECT 
    CAST(target_data AS XML).value(
        '(EventFileTarget/File/@name)[1]', 
        'varchar(500)'
    ) AS xel_file_path
FROM sys.dm_xe_session_targets st
JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
WHERE s.name = 'Deadlock_Monitor';