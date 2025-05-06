**Caso #2**

**Soltura**

IC-4301 Bases de Datos I

Instituto Tecnológico de Costa Rica

Campus Tecnológico Central Cartago

Escuela de Ingeniería en Computación

II Semestre 2024

Prof. Msc. Rodrigo Núñez Núñez

José Julián Monge Brenes

Carné: 2024247024

Fecha de entrega: 6 de mayo de 2025

# **Diseño de la base de datos**

# **Test de la base de datos**

## **Población de datos**
Una vez aprobado el diseño de base de datos, ocupamos los scripts de llenado para la base de datos [Script de inserción completo](scriptInsercion.sql)
```sql
INSERT INTO sol_currencies(name, acronym, country, symbol)
VALUES
  ('Colón costarricense', 'CRC', 'Costa Rica', '₡'),
  ('Dólar estadounidense', 'USD', 'Estados Unidos', '$');
```
