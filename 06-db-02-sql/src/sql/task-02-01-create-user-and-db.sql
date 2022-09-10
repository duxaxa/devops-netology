--В БД из задачи 1:
--- создайте пользователя test-admin-user и БД test_db

CREATE USER "test-admin-user" WITH PASSWORD '12345';

CREATE DATABASE test_db TEMPLATE template0 ENCODING UTF8 CONNECTION
LIMIT 5;
--- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
--Таблица orders:
--- id (serial primary key)
--- наименование (string)
--- цена (integer)
--
--Таблица clients:
--- id (serial primary key)
--- фамилия (string)
--- страна проживания (string, index)
--- заказ (foreign key orders)

CREATE TABLE orders (order_id SERIAL PRIMARY KEY, name VARCHAR(100), price INTEGER);

CREATE TABLE clients (client_id SERIAL PRIMARY KEY, fio VARCHAR(100), country VARCHAR(50), order_id integer REFERENCES orders (order_id));
--- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db

GRANT ALL PRIVILEGES ON
ALL TABLES IN SCHEMA public TO "test-admin-user"
--- создайте пользователя test-simple-user

CREATE USER "test-simple-user" WITH PASSWORD '54321';
--- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

GRANT SELECT, INSERT, UPDATE, DELETE ON
ALL TABLES IN SCHEMA public TO "test-simple-user";
--Приведите:
--- итоговый список БД после выполнения пунктов выше

SELECT *
FROM pg_database;
--- описание таблиц (describe)

SELECT *
FROM pg_database;

SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'orders';

SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'clients';
--- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
--- список пользователей с правами над таблицами test_db

SELECT GRANTEE
FROM information_schema.role_table_grants
WHERE TABLE_CATALOG = 'test_db'
GROUP BY
    GRANTEE;
--Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

INSERT INTO orders (name, price)
VALUES ('Шоколад', 10);

INSERT INTO orders (name, price)
VALUES ('Принтер', 3000);

INSERT INTO orders (name, price)
VALUES ('Книга', 500);

INSERT INTO orders (name, price)
VALUES ('Монитор', 7000);

INSERT INTO orders (name, price)
VALUES ('Гитара', 4000);

INSERT INTO clients (fio, country)
VALUES ('Иванов Иван Иванович', 'USA');

INSERT INTO clients (fio, country)
VALUES ('Петров Петр Петрович', 'Canada');

INSERT INTO clients (fio, country)
VALUES ('Иоганн Себастьян Бах', 'Japan');

INSERT INTO clients (fio, country)
VALUES ('Ронни Джеймс Дио', 'Russia');

INSERT INTO clients (fio, country)
VALUES ('Ritchie Blackmore', 'Russia');
--Используя SQL синтаксис:
-- - вычислите количество записей для каждой таблицы
-- - приведите в ответе:
--   - запросы
--   - результаты их выполнения.

SELECT 'orders' AS "Таблица", count(*) AS "Кол-во записей"
FROM orders
UNION
SELECT 'clients', count(*)
FROM clients;
--Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
--Используя foreign keys свяжите записи из таблиц, согласно таблице:

UPDATE CLIENTS
SET
    ORDER_ID = (
    SELECT order_id
FROM orders o
WHERE name = 'Книга')
WHERE FIO = 'Иванов Иван Иванович';

UPDATE CLIENTS
SET
    ORDER_ID = (
    SELECT order_id
FROM orders o
WHERE name = 'Монитор')
WHERE FIO = 'Петров Петр Петрович';

UPDATE CLIENTS
SET
    ORDER_ID = (
    SELECT order_id
FROM orders o
WHERE name = 'Гитара')
WHERE FIO = 'Иоганн Себастьян Бах';

--Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса:

SELECT C.FIO, O."name", O.PRICE
FROM CLIENTS C
JOIN ORDERS O 
ON
C.ORDER_ID = O.ORDER_ID;

SELECT *
FROM CLIENTS C
WHERE C.ORDER_ID IS NULL;

