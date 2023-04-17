CREATE INDEX ADR_CUST_ID ON Addresses(CUST_ID);
CREATE INDEX ADR_CTR_CODE ON ADDRESSES(CTR_CODE);
CREATE INDEX ADR_CITY ON ADDRESSES(CITY);
CREATE INDEX ADR_ZIP_CITY ON ADDRESSES(ZIP_CODE, CITY);

SELECT i.index_name, i.index_type, i.uniqueness,
LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.column_position)
column_list
FROM user_indexes i
JOIN user_ind_columns c ON (c.index_name = i.index_name)
WHERE i.table_name = 'ADDRESSES'
GROUP BY i.index_name, i.index_type, i.uniqueness;

