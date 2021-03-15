-- hamsterwheel_db.sql

CREATE TABLE customers (
    customer_id     STRING(36)      NOT NULL,
    customer_name   STRING(100)     NOT NULL,
    address         STRING(1000)    NULL,
    phone_number    STRING(20)      NULL,
    is_active       BOOL            NOT NULL    AS  TRUE
) PRIMARY KEY (customer_id)
;

CREATE TABLE sales(
    sale_id         STRING(36)      NOT NULL,
    sale_price      FLOAT64         NOT NULL,
    sale_timestamp  TIMESTAMP       NOT NULL,
    customer_id     STRING(36)      NOT NULL
    ) PRIMARY KEY (sale_id)
    , FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
;