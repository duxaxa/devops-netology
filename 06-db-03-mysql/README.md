# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume:  
[docker-compose.yml](src/mysql/docker-compose.yml)

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него:  
```shell
vagrant@test-netology:/mysql-db/mysql-13/etc $ docker exec -it mysql-8.0 bash

bash-4.4# mysql -p -e "create database test_db"
Enter password:

bash-4.4# mysql test_db -p < /var/lib/mysql/test_dump.sql
Enter password:

bash-4.4# mysql test_db -p
Enter password:

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test_db            |
+--------------------+
5 rows in set (0.00 sec)
```

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД:  
_Server version:         8.0.31 MySQL Community Server - GPL_
```shell
mysql> status
--------------
mysql  Ver 8.0.31 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          65
Current database:       test_db
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.31 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/lib/mysql/mysql.sock
Binary data as:         Hexadecimal
Uptime:                 27 min 10 sec

Threads: 2  Questions: 220  Slow queries: 0  Opens: 219  Flush tables: 3  Open tables: 135  Queries per second avg: 0.134
--------------
```


Подключитесь к восстановленной БД и получите список таблиц из этой БД:  

```shell
mysql> use test_db;
Database changed

mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.01 sec)
```


**Приведите в ответе** количество записей с `price` > 300:  

```shell
mysql> desc orders;
+-------+--------------+------+-----+---------+----------------+
| Field | Type         | Null | Key | Default | Extra          |
+-------+--------------+------+-----+---------+----------------+
| id    | int unsigned | NO   | PRI | NULL    | auto_increment |
| title | varchar(80)  | NO   |     | NULL    |                |
| price | int          | YES  |     | NULL    |                |
+-------+--------------+------+-----+---------+----------------+
3 rows in set (0.01 sec)

mysql> select * from orders where price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```

В следующих заданиях мы будем продолжать работу с данным контейнером.

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

[create_user.sql](src/sql/create_user.sql)

```shell
mysql> CREATE USER 'test'
    -> IDENTIFIED WITH mysql_native_password
    -> BY 'test-pass'
    -> WITH
    -> MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"first_name": "Pretty", "last_name": "James"}';
Query OK, 0 rows affected (0.34 sec)
```

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`:  

[grant_select.sql](src/sql/grant_select.sql)  

```shell
mysql> GRANT SELECT
    -> ON test_db.*
    -> TO 'test';
Query OK, 0 rows affected (0.31 sec)
```

    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**:  

[](src/sql/user_attributes.sql)

```shell
mysql> SELECT * FROM information_schema.user_attributes
    -> WHERE user='test';
+------+------+------------------------------------------------+
| USER | HOST | ATTRIBUTE                                      |
+------+------+------------------------------------------------+
| test | %    | {"last_name": "James", "first_name": "Pretty"} |
+------+------+------------------------------------------------+
1 row in set (0.01 sec)
```


## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`:  

```shell
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> SHOW PROFILES;
+----------+------------+----------------------+
| Query_ID | Duration   | Query                |
+----------+------------+----------------------+
|        1 | 0.00622125 | show tables          |
|        2 | 0.00073250 | select * from orders |
|        3 | 0.00013725 | SET profiling = 1    |
|        4 | 0.00335875 | select * from orders |
|        5 | 0.00009075 | SHOW PROFILES:       |
+----------+------------+----------------------+
5 rows in set, 1 warning (0.01 sec)

mysql> select * from orders where price < 300;
+----+---------------+-------+
| id | title         | price |
+----+---------------+-------+
|  1 | War and Peace |   100 |
|  5 | Log gossips   |   123 |
+----+---------------+-------+
2 rows in set (0.00 sec)

mysql> SHOW PROFILES;
+----------+------------+----------------------------------------+
| Query_ID | Duration   | Query                                  |
+----------+------------+----------------------------------------+
|        1 | 0.00622125 | show tables                            |
|        2 | 0.00073250 | select * from orders                   |
|        3 | 0.00013725 | SET profiling = 1                      |
|        4 | 0.00335875 | select * from orders                   |
|        5 | 0.00009075 | SHOW PROFILES:                         |
|        6 | 0.00061425 | select * from orders where price < 300 |
+----------+------------+----------------------------------------+
6 rows in set, 1 warning (0.00 sec)
```

`SET profiling = 1;` - включает профилирование sql-запросов.  
`SHOW PROFILES` - выводит информацию об выполненных sql-запросах, их идентификатор и время выполнения каждого запроса.


Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**:  

[show_engine.sql](src/sql/show_engine.sql)  

```shell
mysql> SELECT TABLE_SCHEMA, TABLE_NAME, ENGINE FROM information_schema.TABLES
    -> WHERE TABLE_SCHEMA = 'test_db';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.00 sec)
```



Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

```shell
mysql> SET PROFILING = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> SELECT * FROM orders; SELECT * FROM orders where title like '%ve%'; SELECT * FROM orders where price < 300;
+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  1 | War and Peace         |   100 |
|  2 | My little pony        |   500 |
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
|  5 | Log gossips           |   123 |
+----+-----------------------+-------+
5 rows in set (0.00 sec)

+----+-----------------------+-------+
| id | title                 | price |
+----+-----------------------+-------+
|  3 | Adventure mysql times |   300 |
|  4 | Server gravity falls  |   300 |
+----+-----------------------+-------+
2 rows in set (0.00 sec)

+----+---------------+-------+
| id | title         | price |
+----+---------------+-------+
|  1 | War and Peace |   100 |
|  5 | Log gossips   |   123 |
+----+---------------+-------+
2 rows in set (0.00 sec)

mysql> SHOW PROFILES;
+----------+------------+----------------------------------------------+
| Query_ID | Duration   | Query                                        |
+----------+------------+----------------------------------------------+
|        1 | 0.00395650 | SELECT * FROM ORDERS                         |
|        2 | 0.00677375 | show tables                                  |
|        3 | 0.00030875 | SELECT * FROM orders                         |
|        4 | 0.00052900 | SELECT * FROM orders                         |
|        5 | 0.00554525 | SELECT * FROM orders where title like '%ve%' |
|        6 | 0.00032525 | SELECT * FROM orders where price < 300       |
|        7 | 0.00028000 | SELECT * FROM orders                         |
|        8 | 0.00039275 | SELECT * FROM orders where title like '%ve%' |
|        9 | 0.00106625 | SELECT * FROM orders where price < 300       |
|       10 | 0.00030525 | SELECT * FROM orders                         |
|       11 | 0.00147575 | SELECT * FROM orders where title like '%ve%' |
|       12 | 0.00029125 | SELECT * FROM orders where price < 300       |
+----------+------------+----------------------------------------------+
12 rows in set, 1 warning (0.00 sec)

mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.10 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+----------------------------------------------+
| Query_ID | Duration   | Query                                        |
+----------+------------+----------------------------------------------+
|       11 | 0.00147575 | SELECT * FROM orders where title like '%ve%' |
|       12 | 0.00029125 | SELECT * FROM orders where price < 300       |
|       13 | 0.10330525 | ALTER TABLE orders ENGINE = MyISAM           |
|       14 | 0.00093150 | SELECT * FROM orders                         |
|       15 | 0.00037300 | SELECT * FROM orders where title like '%ve%' |
|       16 | 0.00030375 | SELECT * FROM orders where price < 300       |
|       17 | 0.00028875 | SELECT * FROM orders                         |
|       18 | 0.00048500 | SELECT * FROM orders where title like '%ve%' |
|       19 | 0.00032475 | SELECT * FROM orders where price < 300       |
|       20 | 0.00090475 | SELECT * FROM orders                         |
|       21 | 0.00031825 | SELECT * FROM orders where title like '%ve%' |
|       22 | 0.00030175 | SELECT * FROM orders where price < 300       |
|       23 | 0.00025975 | SELECT * FROM orders                         |
|       24 | 0.00019525 | SELECT * FROM orders where title like '%ve%' |
|       25 | 0.00025850 | SELECT * FROM orders where price < 300       |
+----------+------------+----------------------------------------------+
15 rows in set, 1 warning (0.00 sec)
```
  
Запрос на изменение `engine = MyISAM` таблицы `orders` выполнился за `0.10330525` секунд, идентификатор запроса `13`.   




## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`: [my.cnf](src/mysql/my.cnf) 

```properties
# Скорость IO важнее сохранности данных:
innodb_flush_method=O_DSYNC
innodb_flush_log_at_trx_commit=2

# Нужна компрессия таблиц для экономии места на диске:
innodb_file_per_table=ON

# Размер буффера с незакомиченными транзакциями 1 Мб:
innodb_log_buffer_size=1M

# Буффер кеширования 30% от ОЗУ:   512 Мб * 0,3* = ~154 Мб
innodb_buffer_pool_size=154M
innodb_buffer_pool_chunk_size=154M

# Размер файла логов операций 100 Мб:
innodb_log_file_size=100M
```

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
