--� �� �� ������ 1:
--- �������� ������������ test-admin-user � �� test_db

CREATE USER "test-admin-user" WITH PASSWORD '12345';

CREATE DATABASE test_db TEMPLATE template0 ENCODING UTF8 CONNECTION
LIMIT 5;
--- � �� test_db �������� ������� orders � clients (��e��������� ������ ����)
--������� orders:
--- id (serial primary key)
--- ������������ (string)
--- ���� (integer)
--
--������� clients:
--- id (serial primary key)
--- ������� (string)
--- ������ ���������� (string, index)
--- ����� (foreign key orders)

CREATE TABLE orders (order_id SERIAL PRIMARY KEY, name VARCHAR(100), price INTEGER);

CREATE TABLE clients (client_id SERIAL PRIMARY KEY, fio VARCHAR(100), country VARCHAR(50), order_id integer REFERENCES orders (order_id));
--- ������������ ���������� �� ��� �������� ������������ test-admin-user �� ������� �� test_db

GRANT ALL PRIVILEGES ON
ALL TABLES IN SCHEMA public TO "test-admin-user"
--- �������� ������������ test-simple-user

CREATE USER "test-simple-user" WITH PASSWORD '54321';
--- ������������ ������������ test-simple-user ����� �� SELECT/INSERT/UPDATE/DELETE ������ ������ �� test_db

GRANT SELECT, INSERT, UPDATE, DELETE ON
ALL TABLES IN SCHEMA public TO "test-simple-user";
--���������:
--- �������� ������ �� ����� ���������� ������� ����

SELECT *
FROM pg_database;
--- �������� ������ (describe)

SELECT *
FROM pg_database;

SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'orders';

SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'clients';
--- SQL-������ ��� ������ ������ ������������� � ������� ��� ��������� test_db
--- ������ ������������� � ������� ��� ��������� test_db

SELECT GRANTEE
FROM information_schema.role_table_grants
WHERE TABLE_CATALOG = 'test_db'
GROUP BY
    GRANTEE;
--��������� SQL ��������� - ��������� ������� ���������� ��������� �������:

INSERT INTO orders (name, price)
VALUES ('�������', 10);

INSERT INTO orders (name, price)
VALUES ('�������', 3000);

INSERT INTO orders (name, price)
VALUES ('�����', 500);

INSERT INTO orders (name, price)
VALUES ('�������', 7000);

INSERT INTO orders (name, price)
VALUES ('������', 4000);

INSERT INTO clients (fio, country)
VALUES ('������ ���� ��������', 'USA');

INSERT INTO clients (fio, country)
VALUES ('������ ���� ��������', 'Canada');

INSERT INTO clients (fio, country)
VALUES ('������ ��������� ���', 'Japan');

INSERT INTO clients (fio, country)
VALUES ('����� ������ ���', 'Russia');

INSERT INTO clients (fio, country)
VALUES ('Ritchie Blackmore', 'Russia');
--��������� SQL ���������:
-- - ��������� ���������� ������� ��� ������ �������
-- - ��������� � ������:
--   - �������
--   - ���������� �� ����������.

SELECT 'orders' AS "�������", count(*) AS "���-�� �������"
FROM orders
UNION
SELECT 'clients', count(*)
FROM clients;
--����� ������������� �� ������� clients ������ �������� ������ �� ������� orders.
--��������� foreign keys ������� ������ �� ������, �������� �������:

UPDATE CLIENTS
SET
    ORDER_ID = (
    SELECT order_id
FROM orders o
WHERE name = '�����')
WHERE FIO = '������ ���� ��������';

UPDATE CLIENTS
SET
    ORDER_ID = (
    SELECT order_id
FROM orders o
WHERE name = '�������')
WHERE FIO = '������ ���� ��������';

UPDATE CLIENTS
SET
    ORDER_ID = (
    SELECT order_id
FROM orders o
WHERE name = '������')
WHERE FIO = '������ ��������� ���';

--��������� SQL-������ ��� ������ ���� �������������, ������� ��������� �����, � ����� ����� ������� �������:

SELECT C.FIO, O."name", O.PRICE
FROM CLIENTS C
JOIN ORDERS O 
ON
C.ORDER_ID = O.ORDER_ID;

SELECT *
FROM CLIENTS C
WHERE C.ORDER_ID IS NULL;

