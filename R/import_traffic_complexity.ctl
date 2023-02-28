load data 
infile 'traffic_complexity.csv' "str '\n'"
append
into table AUA_COMPLEXITY_3_15
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( UNIT_CODE CHAR(4000),
             FL CHAR(4000),
             FT CHAR(4000),
             FD CHAR(4000),
             DH CHAR(4000),
             TX CHAR(4000),
             TXH CHAR(4000),
             TXV CHAR(4000),
             TXS CHAR(4000),
             N CHAR(4000),
             NCELL CHAR(4000),
             CPLX_DATE DATE "YYYY-MM-DD",
             BADA_VERSION CHAR(4000),
             SOURCE CHAR(4000),
             LAST_UPDATE DATE "YYYY-MM-DD"
           )
