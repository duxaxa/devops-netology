--инструкции по пересозданию таблицы orders с использованием сегментирования необходимо
--выполнить в рамках одной транзакции
BEGIN TRANSACTION;

--создаем таблицу orders_1, как копию таблиц orders и наполняем ее данными согласно условию сегментирования:
CREATE TABLE orders_1
 (  id serial4 NOT NULL,
    title varchar(80) NOT NULL,
    price int4 NOT NULL DEFAULT 0
);
INSERT INTO orders_1 SELECT *
FROM ORDERS
WHERE PRICE > 499;

--создаем таблицу orders_2, как копию таблиц orders и наполняем ее данными согласно условию сегментирования:
CREATE TABLE orders_2
 (  id serial4 NOT NULL,
    title varchar(80) NOT NULL,
    price int4 NOT NULL DEFAULT 0
);
INSERT INTO ORDERS_2 SELECT *
FROM ORDERS
WHERE PRICE <= 499;

--запоминаем значение сиквенса для столбца id таблицы orders во временную таблицу:
CREATE TEMP TABLE seq_value (seq integer);
INSERT INTO seq_value 
SELECT "last_value"
FROM orders_id_seq;

--пересоздаем таблицу orders и сразу определяем ее как сегментированную:
DROP TABLE orders CASCADE;

CREATE TABLE orders (
    id serial4 NOT NULL,
    title varchar(80) NOT NULL,
    price int4 NULL DEFAULT 0,
    CONSTRAINT orders_pkey PRIMARY KEY (id, price)
)
PARTITION BY RANGE (price);

--восстанавливаем значение сиквенса столбца id для пересозданой таблицы orders:
SELECT setval('orders_id_seq', (SELECT seq FROM seq_value), true);

--добавляем сегменты к таблице orders:
ALTER TABLE orders
ATTACH PARTITION orders_2
FOR VALUES FROM (MINVALUE) TO (500);

ALTER TABLE orders
ATTACH PARTITION orders_1
FOR VALUES FROM (500) TO (MAXVALUE);

END;


--Проверка работы сегментирования и сиквенса для столбца id:
INSERT INTO orders (title, price) VALUES ('Docker easy', 1500);
INSERT INTO orders (title, price) VALUES ('Openshift is power', 5);
INSERT INTO orders (title, price) VALUES ('Windows XP was not bad', 2050);
INSERT INTO orders (title, price) VALUES ('But Linux is better', 450);
SELECT * FROM orders ORDER BY id;
SELECT * FROM orders_1 ORDER BY id;
SELECT * FROM orders_2 ORDER BY id;
