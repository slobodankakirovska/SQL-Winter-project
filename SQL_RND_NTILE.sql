select *
,	NTILE(10) OVER (ORDER BY CountryID) as C1
,	NTILE(10) OVER (ORDER BY FormalName) as C2
,	NTILE(20) OVER (ORDER BY Continent) as C3
from
	WideWorldImporters.[Application].[Countries]
order by
	CountryID
--	FormalName
--	Continent

--Ocekuvani random vrednosti 5,6,7
declare
	@RN int
,	@RN2 int
-- MIN(MAX(RAND*65000, 18000), 60000)

SELECT FLOOR(RAND()*(60000-18000+1)+18000)
SELECT
	@RN = 5 + ABS(CHECKSUM(NewID())) % 3
,	@RN2 = FLOOR(RAND()*(7-5+1)+5)
SELECT @RN as RN, @RN2 as RN2

select
	*
,	5 + ABS(CHECKSUM(NewID())) % 3 as RN
,	FLOOR(RAND()*(7-5+1)+5) as RN2,
	FLOOR(RAND()*(7-5+1)+5) as RandIDs

from
	WideWorldImporters.[Application].[Countries]
