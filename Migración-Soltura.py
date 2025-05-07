"""
Script de Migración: PayAssistant a Soltura
Estudiantes: 
Carlos Ávalos Mendieta 
Jose Monge Brenes 
Daniel Monterrosa Quirós
Sebastian Donoso Chaves
Fecha: 06/05/2025

Descripción:
Migración completa de datos desde MySQL (PayAssistant) a SQL Server (Soltura),
incluyendo usuarios, permisos, planes de suscripción y configuraciones de pagos.

Estructura:
1. Conexiones a bases de datos
2. Migración de usuarios y contactos
3. Migración de roles y permisos
4. Migración de planes y suscripciones
5. Migración de schedules y fechas de pago
"""

# ==========================================================
# 1. IMPORTACIÓN DE LIBRERÍAS NECESARIAS
# ==========================================================

import pandas as pd
import random 
from sqlalchemy import text
from sqlalchemy import create_engine
from sqlalchemy.dialects.mssql import VARBINARY

# ==========================================================
# 2. CONEXIÓN A BASE DE DATOS MYSQL (PayAssistant)
# ==========================================================

# Datos de conexión
usuario = "root"
contrasena = "root"
host = "localhost"
puerto = "6000"
base_datos = "PayAssistantDB"

# Creación de la URL de conexión
url = f"mysql+pymysql://{usuario}:{contrasena}@{host}:{puerto}/{base_datos}"
engine_mysql = create_engine(url)

# ==========================================================
# 3. CONEXIÓN A BASE DE DATOS SQL SERVER (Soltura)
# ==========================================================

# Cadena de conexión usando Trusted Connection (Windows Authentication)
connection_string = (
    "mssql+pyodbc://localhost/SolturaDB?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"
)
sqlserver_engine = create_engine(connection_string)

# ==========================================================
# 4. MIGRACIÓN DE USUARIOS
# ==========================================================

df = pd.read_sql("SELECT * FROM paya_users", engine_mysql)
# Limpiar los bits a enteros y convierte a 1 o 0 explícitamente
df['enable'] = df['enable'].apply(lambda x: int.from_bytes(x, 'little') if isinstance(x, bytes) else x)
df['enable'] = df['enable'].astype(int)

# Crear nuevo DataFrame solo con columnas necesarias para sol_users
df_users = pd.DataFrame({
    'username': df['username'],
    'firstname': df['fname'],
    'lastname': df['lname'],
    'email': df['email'],
    'password': 0x70617373776F7264,
    'isActive': df['enable'],
    'addressid': 1  # Ejemplo: usa una dirección dummy o relacionada previamente
})

# Inserción de usuarios en sol_users
df_users.to_sql('sol_users', con=sqlserver_engine, if_exists='append', index=False)

# ==========================================================
# 5. MIGRACIÓN DE TELÉFONOS A sol_contact_info
# ==========================================================

df_inserted = pd.read_sql("SELECT userid, username FROM sol_users", sqlserver_engine)
df = df.merge(df_inserted, on='username', how='inner', suffixes=('', '_new'))

df_contact_type = pd.read_sql("""
    SELECT contact_typeid 
    FROM sol_contact_types 
    WHERE name = 'Teléfono'
    """, sqlserver_engine)
contact_type_id = df_contact_type['contact_typeid'].iloc[0]

df_contact_info = pd.DataFrame({
    'value': df['phone'],
    'notes': ['Teléfono principal'] * len(df),
    'enabled': df['enable'],
    'userid': df['userid_new'],
    'contact_typeid': contact_type_id
})

# Inserción de los números de teléfono
df_contact_info.to_sql('sol_contact_info', con=sqlserver_engine, if_exists='append', index=False)

# ==========================================================
# 6. REGISTRO EN TABLA DE USUARIOS MIGRADOS
# ==========================================================

# Obtener los IDs de los usuarios recién insertados (esto requiere que no haya otros inserts en medio)
with sqlserver_engine.connect() as conn:
    result = conn.execute(text(f"SELECT TOP {len(df_users)} userid FROM sol_users ORDER BY userid DESC"))
    inserted_ids = [row[0] for row in result.fetchall()][::-1]  # Invertir para que estén en orden de inserción

# Creación de DataFrame para sol_migrated_users
df_migrated = pd.DataFrame({
    'userid': inserted_ids,
    'platform_name': ['Payment Assistant'] * len(inserted_ids),
    'password_changed': [0] * len(inserted_ids)
})

df_migrated.to_sql('sol_migrated_users', con=sqlserver_engine, if_exists='append', index=False)

# ==========================================================
# 7. MIGRACIÓN DE ROLES Y PERMISOS
# ==========================================================

# --- Módulos ---
df_modules = pd.read_sql("SELECT * FROM paya_modules", engine_mysql)
df_modules = df_modules[['name']]
df_modules.to_sql('sol_modules', con=sqlserver_engine, if_exists='append', index=False)

# --- Roles ---
df_roles = pd.read_sql("SELECT rolename, description, asignationdate, is_system_role FROM paya_roles", engine_mysql)
# Convertir BIT a INT para SQL Server
df_roles['is_system_role'] = df_roles['is_system_role'].apply(lambda x: int.from_bytes(x, 'little')) if isinstance(df_roles['is_system_role'].iloc[0], bytes) else df_roles['is_system_role'].astype(int)
df_roles.to_sql('sol_roles', con=sqlserver_engine, if_exists='append', index=False)

# --- Permisos ---
df_permissions = pd.read_sql("""
    SELECT p.*, m.moduleid as new_moduleid 
    FROM paya_permissions p
    JOIN paya_modules m ON p.moduleid = m.moduleid
""", engine_mysql)

# Solo mantener las columnas necesarias para SQL Server
df_permissions = df_permissions[['permissioncode', 'description', 'htmlObjectid', 'new_moduleid']]
df_permissions.rename(columns={'new_moduleid': 'moduleid'}, inplace=True)
df_permissions.to_sql('sol_permissions', con=sqlserver_engine, if_exists='append', index=False)


# --- Roles-Permisos ---
# Primero necesitamos mapear los IDs antiguos a los nuevos
with sqlserver_engine.connect() as conn:
    # Obtener mapeo de roles
    result = conn.execute(text("SELECT roleid, rolename FROM sol_roles"))
    role_map = {row[1]: row[0] for row in result.fetchall()}
    
    # Obtener mapeo de permisos
    result = conn.execute(text("SELECT permissionid, permissioncode FROM sol_permissions"))
    permission_map = {row[1]: row[0] for row in result.fetchall()}

# Obtener datos originales de MySQL
df_roles_permissions = pd.read_sql("""
    SELECT rp.*, r.rolename, p.permissioncode
    FROM paya_rolespermissions rp
    JOIN paya_roles r ON rp.roleid = r.roleid
    JOIN paya_permissions p ON rp.permissionid = p.permissionid
""", engine_mysql)

# Mapear a los nuevos IDs
df_roles_permissions['new_roleid'] = df_roles_permissions['rolename'].map(role_map)
df_roles_permissions['new_permissionid'] = df_roles_permissions['permissioncode'].map(permission_map)

# Preparar datos para SQL Server
df_roles_permissions_sql = pd.DataFrame({
    'asignationdate': df_roles_permissions['asignationdate'],
    'enable': df_roles_permissions['enable'].apply(lambda x: int.from_bytes(x, 'little')) if isinstance(df_roles_permissions['enable'].iloc[0], bytes) else df_roles_permissions['enable'].astype(int),
    'deleted': df_roles_permissions['deleted'].apply(lambda x: int.from_bytes(x, 'little')) if isinstance(df_roles_permissions['deleted'].iloc[0], bytes) else df_roles_permissions['deleted'].astype(int),
    'lastupdate': df_roles_permissions['lastupdate'],
    'checksum': df_roles_permissions['checksum'],
    'roleid': df_roles_permissions['new_roleid'],
    'permissionid': df_roles_permissions['new_permissionid']
})

# Filtrar nulos por si hay inconsistencias
df_roles_permissions_sql = df_roles_permissions_sql.dropna(subset=['roleid', 'permissionid'])
# Inserción a la tabla rolespermissions
df_roles_permissions_sql.to_sql('sol_rolespermissions', con=sqlserver_engine, if_exists='append', index=False, dtype={'checksum': VARBINARY(250)})

# ==========================================================
# 8. MIGRACIÓN DE USERS-ROLES 
# ==========================================================

# Obtener datos originales de MySQL
df_users_roles = pd.read_sql("""
    SELECT ur.*, r.rolename, u.userid as old_userid
    FROM paya_usersroles ur
    JOIN paya_roles r ON ur.roleid = r.roleid
    JOIN paya_users u ON ur.paya_users_userid = u.userid
""", engine_mysql)

# Obtener mapeo de usuarios migrados
with sqlserver_engine.connect() as conn:
    result = conn.execute(text("SELECT userid FROM sol_migrated_users"))
    user_map = {i+1: row[0] for i, row in enumerate(result.fetchall())}  # Asume correlación 1:1 por orden

# Mapear a los nuevos IDs
df_users_roles['new_userid'] = df_users_roles['old_userid'].map(user_map)
df_users_roles['new_roleid'] = df_users_roles['rolename'].map(role_map)

# Preparar datos para SQL Server
df_users_roles_sql = pd.DataFrame({
    'asignationdate': df_users_roles['asginationdate'],  # Nota: corrige nombre de columna si es necesario
    'checksum': df_users_roles['checksum'],
    'enable': df_users_roles['enable'].apply(lambda x: int.from_bytes(x, 'little')) if isinstance(df_users_roles['enable'].iloc[0], bytes) else df_users_roles['enable'].astype(int),
    'deleted': df_users_roles['deleted'].apply(lambda x: int.from_bytes(x, 'little')) if isinstance(df_users_roles['deleted'].iloc[0], bytes) else df_users_roles['deleted'].astype(int),
    'roleid': df_users_roles['new_roleid'],
    'userid': df_users_roles['new_userid']
})

# Filtrar nulos por si hay inconsistencias
df_users_roles_sql = df_users_roles_sql.dropna(subset=['roleid', 'userid'])
df_users_roles_sql.to_sql('sol_usersroles', con=sqlserver_engine, if_exists='append', index=False, dtype={'checksum': VARBINARY(250)})

print("Migración de roles y permisos completada exitosamente!")


# ==========================================================
# 8. MIGRACIÓN DE PLANES 
# ==========================================================

df_paya_services = pd.read_sql("""
    SELECT DISTINCT
        s.subscriptionid, 
        s.description, 
        pp.amount,
        pp.currencyid, 
        c.acronym as currency,
        CASE 
            WHEN s.description LIKE '%%Netflix%%' THEN 'Streaming'
            WHEN s.description LIKE '%%SmartFit%%' THEN 'Deporte'
            ELSE 'General' 
        END as service_type,
        pp.planpriceid
    FROM paya_subscriptions s
    JOIN paya_planprices pp ON s.subscriptionid = pp.subscriptionid
    JOIN paya_currencies c ON pp.currencyid = c.currencyid
    JOIN paya_scheduledetails sd ON pp.scheduledetailsid = sd.scheduledetailsid
    WHERE pp.current = 1
""", engine_mysql)

# Mapear tipos de servicio a IDs de Soltura
service_type_map = {
    'Streaming': 6,  # ID para Streaming en Soltura
    'Deporte': 1     # ID para Gimnasios en Soltura
}

# Creación de servicios en Soltura (uno por cada planpriceid)
df_sol_services = pd.DataFrame({
    'name': 'Migrado - ' + df_paya_services['description'] + ' ' + df_paya_services['planpriceid'].astype(str),
    'description': 'Servicio migrado desde PayAssistant: ' + df_paya_services['description'],
    'dataType': 'Subscripcion',
    'original_amount': df_paya_services['amount'],
    'sale_amount': df_paya_services['amount'],
    'enabled': 1,
    'contractid': 1,
    'currencyid': 1,
    'servicetypeid': df_paya_services['service_type'].map(service_type_map),
    'price_config_id': 1
})

# Insertar servicios
df_sol_services.to_sql('sol_service', con=sqlserver_engine, if_exists='append', index=False)

# Obtener IDs insertados usando los nombres únicos que generamos
with sqlserver_engine.connect() as conn:
    result = conn.execute(
        text("SELECT serviceid FROM sol_service WHERE name LIKE :pattern"),
        {'pattern': 'Migrado - %'}
    )
    service_ids = [row[0] for row in result.fetchall()]

# Asignar IDs manteniendo el mismo orden de inserción
df_paya_services['soltura_service_id'] = service_ids[:len(df_paya_services)]

def create_custom_plans_for_users(df_paya_services):
    # Obtener usuarios únicos con sus servicios
    df_user_services = pd.read_sql("""
        SELECT DISTINCT u.userid, s.subscriptionid, s.description,
               pp.amount, pp.currencyid, sch.recurrencytype,
               sd.basedate, sd.datepart
        FROM paya_users u
        JOIN paya_plans p ON u.userid = p.userid
        JOIN paya_planprices pp ON p.planpriceid = pp.planpriceid
        JOIN paya_subscriptions s ON pp.subscriptionid = s.subscriptionid
        JOIN paya_scheduledetails sd ON pp.scheduledetailsid = sd.scheduledetailsid
        JOIN paya_schedules sch ON sd.scheduleid = sch.scheduleid
        WHERE u.enable = 1 AND p.enabled = 1
    """, engine_mysql)

    # Mapear a servicios en Soltura
    df_user_plans = df_user_services.merge(
        df_paya_services[['subscriptionid', 'soltura_service_id']],
        on='subscriptionid'
    )
    
    # Crear 1 plan por usuario (agrupando por userid)
    df_users_grouped = df_user_plans.groupby('userid').first().reset_index()
    
    # Crear 1 plan por usuario
    df_plans = pd.DataFrame({
        'name': 'Plan Personalizado Usuario ' + df_users_grouped['userid'].astype(str),
        'description': 'Contiene servicios migrados de PayAssistant',
        'customizable': 0,
        'limit_people': 1,
        'enabled': 1,
        'codigoid': 1000 + df_users_grouped.index  # IDs únicos
    })
    
    # Insertar planes y obtener sus IDs
    df_plans.to_sql('sol_plans', con=sqlserver_engine, if_exists='append', index=False)
    
    # Obtener IDs de planes
    with sqlserver_engine.connect() as conn:
        result = conn.execute(text("SELECT planid FROM sol_plans WHERE name LIKE 'Plan Personalizado Usuario %'"))
        plan_ids = [row[0] for row in result.fetchall()]
    
    df_users_grouped['soltura_planid'] = plan_ids

    df_user_plans = df_user_plans.merge(
    df_users_grouped[['userid', 'soltura_planid']],
    on='userid',
    how='left'
    )
    
    # Vincular features (servicios)
    plan_features = []
    for _, row in df_users_grouped.iterrows():
        # Servicio original
        plan_features.append({
            'value': '1',
            'enabled': 1,
            'quantitytypeid': 1,
            'serviceid': row['soltura_service_id'],
            'plantid': row['soltura_planid']
        })
        
        # servicios adicionales
        extra_services = pd.read_sql(f"""
            SELECT TOP 2 serviceid FROM sol_service 
            WHERE serviceid != {row['soltura_service_id']}
            ORDER BY NEWID()
        """, sqlserver_engine)['serviceid'].tolist()
        
        for service_id in extra_services:
            plan_features.append({
                'value': '1',
                'enabled': 1,
                'quantitytypeid': 1,
                'serviceid': service_id,
                'plantid': row['soltura_planid']
            })
    
    # Insertar todos los features
    pd.DataFrame(plan_features).to_sql('sol_planfeatures', con=sqlserver_engine, if_exists='append', index=False)
    
    # Crear precios para los planes (mismo precio que el original)
    df_plan_prices = pd.DataFrame({
        'amount': df_user_plans['amount'],
        'postTime': pd.to_datetime('now'),
        'endDate': pd.to_datetime('2030-12-31'),
        'current': 1,
        'planid': df_user_plans['soltura_planid']
    })
    df_plan_prices.to_sql('sol_planprices', con=sqlserver_engine, if_exists='append', index=False)
    
    # Crear suscripciones para los usuarios
    df_subscriptions = pd.DataFrame({
        'startdate': pd.to_datetime('now'),
        'enddate': pd.to_datetime('now') + pd.DateOffset(years=1),
        'autorenew': 1,
        'statusid': 1,  # Activa
        'scheduleid': df_user_plans['recurrencytype'].map({'MONTHLY': 1, 'YEARLY': 3}),  # IDs de schedules en Soltura
        'userid': df_user_plans['userid'],
        'planid': df_user_plans['soltura_planid']
    })
    df_subscriptions.to_sql('sol_subscriptions', con=sqlserver_engine, if_exists='append', index=False)
    
    print(f"Migración completada: {len(df_users_grouped)} planes creados (1 por usuario)")

create_custom_plans_for_users(df_paya_services)

# ==========================================================
# 8. MIGRACIÓN DE FECHAS  
# ==========================================================

def migrate_schedules_and_details(df_paya_services):
    # Obtiene schedules originales con sus detalles
    df_schedules_with_details = pd.read_sql("""
        SELECT 
            s.scheduleid as original_scheduleid,
            s.name,
            s.recurrencytype,
            s.repeat,
            s.endtype,
            s.repetitions,
            s.enddate,
            sd.scheduledetailsid as original_detailid,
            sd.basedate,
            sd.datepart,
            sd.lastexecution,
            sd.nextexecution,
            sd.deleted
        FROM paya_schedules s
        JOIN paya_scheduledetails sd ON s.scheduleid = sd.scheduleid
        JOIN paya_planprices pp ON sd.scheduledetailsid = pp.scheduledetailsid
        WHERE pp.current = 1
    """, engine_mysql)

    # Mapear a estructura de Soltura para schedules principales
    df_soltura_schedules = pd.DataFrame({
        'name': 'Migrado - ' + df_schedules_with_details['name'],
        'description': 'Schedule migrado de PayAssistant - ' + df_schedules_with_details['name'],
        'recurrencetypeid': df_schedules_with_details['recurrencytype'].map({
            'MONTHLY': 3, 'YEARLY': 5, 'WEEKLY': 2, 'DAILY': 1
        }),
        'active': 1,
        'interval': df_schedules_with_details['recurrencytype'].map({
            'MONTHLY': 30, 'YEARLY': 365, 'WEEKLY': 7, 'DAILY': 1
        }),
        'startdate': pd.to_datetime('now'),
        'endtype': df_schedules_with_details['endtype'],
        'repetitions': df_schedules_with_details['repetitions']
    }).drop_duplicates()

    # Insertar schedules y obtener IDs generados
    df_soltura_schedules.to_sql('sol_schedules', con=sqlserver_engine, if_exists='append', index=False)
    
    # Obtener los IDs de los schedules recién insertados
    with sqlserver_engine.connect() as conn:
        result = conn.execute(
            text("SELECT scheduleid, name FROM sol_schedules WHERE name LIKE 'Migrado - %'")
        )
        schedule_map = {row[1].replace('Migrado - ', ''): row[0] for row in result.fetchall()}

    # Preparar los scheduledetails para migración
    df_soltura_details = df_schedules_with_details.merge(
        pd.DataFrame.from_dict(schedule_map, orient='index', columns=['newscheduleid']),
        left_on='name',
        right_index=True
    )
    
    # Mapear a estructura de sol_scheduledetails
    df_soltura_details_transformed = pd.DataFrame({
        'deleted': df_soltura_details['deleted'].apply(lambda x: int.from_bytes(x, 'little') if isinstance(x, bytes) else int(x)),
        'basedate': df_soltura_details['basedate'],
        'datepart': df_soltura_details['datepart'],
        'maxdelaydays': 3,  # Valor por defecto
        'executiontime': df_soltura_details['lastexecution'],
        'scheduleid': df_soltura_details['newscheduleid'],
        'timezone': 'America/Costa_Rica'  # Ajustar según necesidad
    })

    # 6. Insertar los scheduledetails
    df_soltura_details_transformed.to_sql(
        'sol_schedulesdetails', 
        con=sqlserver_engine, 
        if_exists='append', 
        index=False
    )

    # 7. Retornar mapeo de IDs para referencia en otras migraciones
    return {
        'schedule_map': schedule_map,
        'details_map': dict(zip(
            df_soltura_details['original_detailid'],
            df_soltura_details['newscheduleid']
        ))
    }

schedule_mappings = migrate_schedules_and_details(df_paya_services)




