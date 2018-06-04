
CREATE SCHEMA shutterfly
    AUTHORIZATION postgres;

-- creating tables with appropriate columns

-- customer
CREATE TABLE shutterfly.customer (
customer_id varchar(255) NOT NULL,
event_time varchar(255) NOT NULL,
last_name varchar(255),
adr_city varchar(255),
adr_state varchar(255),
PRIMARY KEY (customer_id)
);


-- Site Visit
CREATE TABLE shutterfly.site_visit(
visit_id varchar(255) NOT NULL,
event_time varchar(255) NOT NULL,
customer_id varchar(255),
tags varchar(255),
PRIMARY KEY (visit_id)
);


-- image upload
CREATE TABLE shutterfly.image(
image_id varchar(255) NOT NULL,
event_time varchar(255) NOT NULL,
customer_id varchar(255) NOT NULL,
camera_make varchar(255),
camera_model varchar(255), 
PRIMARY KEY (image_id)
);


-- order
CREATE TABLE shutterfly.order(
order_id varchar(255) NOT NULL,
event_time varchar(255) NOT NULL,
customer_id varchar(255),
total_amount varchar(255),
PRIMARY KEY (order_id)
);


-- extra table to keep weeks.
CREATE TABLE shutterfly.week(
week_start TIMESTAMP,
week_end TIMESTAMP,
week INT
);


insert into shutterfly.week
SELECT date_trunc('day', dd):: date as week_start, date_trunc('day', dd):: date +7 as week_end, 
row_number() over () week_no
FROM generate_series
        ( '2017-12-31'::timestamp 
        , '2018-06-30'::timestamp
        , '7 day'::interval) dd
        ;


-- View for CUSTOMER_LTV

CREATE OR REPLACE VIEW SHUTTERFLY.CUSTOMER_LTV AS 
WITH CUSTOMER_AQUISITION_WEEK AS
(SELECT 
A.CUSTOMER_ID,
B.WEEK,
SUM(CAST(REPLACE(A.TOTAL_AMOUNT,' USD','')
								AS DECIMAL(4,2)))/COUNT(DISTINCT(B.WEEK))  AS AMOUNT 
FROM SHUTTERFLY.ORDER A,SHUTTERFLY.WEEK B 
WHERE TO_TIMESTAMP( A.EVENT_TIME, 'YYYY-MM-DD HH24:MI:SS' )  BETWEEN B.WEEK_START AND B.WEEK_END
GROUP BY A.CUSTOMER_ID,B.WEEK
),
CUSTOMER_SITEVISIT	AS
(SELECT 
A.CUSTOMER_ID,
B.WEEK,
COUNT(*)/COUNT(DISTINCT(B.WEEK)) VISITS 
FROM SHUTTERFLY.SITE_VISIT A,SHUTTERFLY.WEEK B 
WHERE TO_TIMESTAMP( A.EVENT_TIME, 'YYYY-MM-DD HH24:MI:SS' )  BETWEEN B.WEEK_START AND B.WEEK_END
GROUP BY A.CUSTOMER_ID,B.WEEK 
 ),
 LTV_PERWK AS
(SELECT 
A.CUSTOMER_ID, 
A.WEEK,
A.AMOUNT,
B.VISITS,
52*A.AMOUNT*B.VISITS*10 AS LTV  
FROM CUSTOMER_AQUISITION_WEEK A, CUSTOMER_SITEVISIT B 
WHERE A.CUSTOMER_ID = B.CUSTOMER_ID
AND A.WEEK = B.WEEK	
)
SELECT 
	D.LAST_NAME,
	D.ADR_CITY,
	D.ADR_STATE,
	D.CUSTOMER_ID,
	C.LTV
FROM LTV_PERWK C, SHUTTERFLY.CUSTOMER D
WHERE C.CUSTOMER_ID = D.CUSTOMER_ID
ORDER BY C.LTV DESC;









