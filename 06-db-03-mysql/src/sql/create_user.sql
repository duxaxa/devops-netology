CREATE USER 'test'
IDENTIFIED WITH mysql_native_password
BY 'test-pass'
WITH 
MAX_QUERIES_PER_HOUR 100
PASSWORD EXPIRE INTERVAL 180 DAY
FAILED_LOGIN_ATTEMPTS 3
ATTRIBUTE '{"first_name": "Pretty", "last_name": "James"}';