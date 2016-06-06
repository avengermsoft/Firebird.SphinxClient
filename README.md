# Firebird.SphinxClient
Библиотека позволяет делать запросы к Sphinx из PL/SQL Firebird. Поставляется в двух вариантах - UDF (Firebird 2.5/3.0) и UDR (Firebird 3.0)

##### Настройка UDF
* Windows
  1.	Необходимо в каталог UDF сервера Firebird скопировать два файла udf_SphinxClient.dll и udf_SphinxClient.ini
  2.	Произвести первичную настройку в файле udf_SphinxClient.ini, где указать адрес и порт Sphinx сервера, библиотеку доступа к SphinxQL.
  3.	Пролить в базу файл udf_SphinxClient.sql
* Linux
  1.	Необходимо в каталог UDF сервера Firebird скопировать файл libudf_SphinxClient.so. В каталог /etc/firebird скопировать файл udf_SphinxClient.conf
  2.	Произвести первичную настройку в файле udf_SphinxClient.conf, где указать адрес и порт Sphinx сервера, библиотеку доступа к SphinxQL.
  3.	Пролить в базу файл udf_SphinxClient.sql
  
##### Сборка UDF на Linux
> fpc -Cg -B -O2 -Xs -Xg -XX -CX -Ur -dRELEASE -dx86_64 -Tlinux udf_SphinxClient.dpr

##### Пример использование UDF
```sql
EXECUTE BLOCK RETURNS (
  PARSER_ID INTEGER,
  MODULE_ID INTEGER, 
  ROW_ID    VARCHAR(128) CHARACTER SET OCTETS
)
AS
DECLARE VARIABLE SQL_TEXT VARCHAR(8000);
BEGIN
  SQL_TEXT =
    'SELECT MODULE_ID, ROW_ID FROM Cashs2_Operations ' ||
    'WHERE MATCH(''иванов иван владимирович'')' ||
    '  AND TDATE BETWEEN 42000 AND 50000';
  PARSER_ID = SPHINXCLIENT$CREATE();
  IF (SPHINXCLIENT$EXEC_SQL(PARSER_ID, SQL_TEXT) = 1) THEN
  BEGIN
    WHILE (SPHINXCLIENT$EOF(PARSER_ID) = 1) DO
    BEGIN
      MODULE_ID = SPHINXCLIENT$CURRENT_VALUE(PARSER_ID, 0);
      ROW_ID    = SPHINXCLIENT$CURRENT_VALUE(PARSER_ID, 1);
      SUSPEND;
      SPHINXCLIENT$NEXT(PARSER_ID);
    END
  END
  SPHINXCLIENT$FREE(PARSER_ID);
END
```

##### Настройка UDR
1.	Необходимо в каталог UDR сервера Firebird скопировать два файла udr_SphinxClient.dll и udr_SphinxClient.ini
2.	Произвести первичную настройку в файле udr_SphinxClient.ini, где указать адрес и порт Sphinx сервера, библиотеку доступа к SphinxQL.
3.	Пролить в базу файл udr_SphinxClient.sql

##### Пример использование UDR
```sql
EXECUTE BLOCK RETURNS (
  MODULE_ID INTEGER, 
  ROW_ID    VARCHAR(128) CHARACTER SET OCTETS
)
AS
DECLARE VARIABLE SQL_TEXT VARCHAR(8000);
BEGIN
  SQL_TEXT =
    'SELECT MODULE_ID, ROW_ID FROM Cashs2_Operations ' ||
    'WHERE MATCH(''иванов иван владимирович'')' ||
    '  AND TDATE BETWEEN 42000 AND 50000';
  FOR
    SELECT MODULE_ID, ROW_ID
    FROM SPHINXSEARCH$EXECUTE(:SQL_TEXT)
    INTO :MODULE_ID, :ROW_ID
  DO
  BEGIN
    SUSPEND;
  END
END
```
