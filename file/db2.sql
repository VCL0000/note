SELECT
	SUBSTR(
		CONSTNAME,
		1,
		18
	) AS CONSTNAME,
	SUBSTR(
		TABNAME,
		1,
		18
	) AS TABNAME,
	SUBSTR(
		FK_COLNAMES,
		1,
		14
	) AS FK_COLNAMES,
	SUBSTR(
		REFTABSCHEMA,
		1,
		14
	) AS REF_SCHEMA,
	SUBSTR(
		REFTABNAME,
		1,
		14
	) AS REF_TABNANE,
	SUBSTR(
		PK_COLNAMES,
		1,
		14
	) AS K_COLNAMES,
	DELETERULE
FROM
	SYSCAT.REFERENCES
WHERE
	TABSCHEMA = 'TEST';


























end
