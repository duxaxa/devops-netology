DROP TABLE orders;
--создаем секционированную таблицу "orders"
--столбец price необходимо добавить в составной первичный ключ:
CREATE TABLE orders (
    id serial4 NOT NULL,
    title varchar(80) NOT NULL,
    price int4 NULL DEFAULT 0,
    CONSTRAINT orders_pkey PRIMARY KEY (id, price)
)
PARTITION BY RANGE (price);

--создаем секции к таблице "orders":
CREATE TABLE orders_1
    PARTITION OF orders
    FOR
    VALUES FROM(499) TO (MAXVALUE);

CREATE TABLE orders_2
    PARTITION OF orders
    FOR
    VALUES FROM(MINVALUE) TO (499);

--Проверка работы сегментирования и сиквенса для столбца id:
INSERT INTO orders (title, price) VALUES ('Docker easy', 1500);
INSERT INTO orders (title, price) VALUES ('Openshift is power', 5);
INSERT INTO orders (title, price) VALUES ('Windows XP was not bad', 2050);
INSERT INTO orders (title, price) VALUES ('But Linux is better', 450);
SELECT * FROM orders ORDER BY id;
SELECT * FROM orders_1 ORDER BY id;
SELECT * FROM orders_2 ORDER BY id;
