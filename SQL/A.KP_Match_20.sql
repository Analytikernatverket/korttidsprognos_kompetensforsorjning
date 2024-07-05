CREATE or ALTER VIEW P0927.KP_Match_20 AS
SELECT [P0927_LopNr_PersonNr], [Match_20], (2015) AS ar FROM [dbo].[Match_20_2015]
UNION
SELECT [P0927_LopNr_PersonNr], [Match_20], (2016) AS ar FROM [dbo].[Match_20_2016]
UNION
SELECT [P0927_LopNr_PersonNr], [Match_20], (2017) AS ar FROM [dbo].[Match_20_2017]
UNION
SELECT [P0927_LopNr_PersonNr], [Match_20], (2018) AS ar FROM [dbo].[Match_20_2018]
UNION
SELECT [P0927_LopNr_PersonNr], [Match_20], (2019) AS ar FROM [dbo].[Matchdata_2019]
UNION
SELECT [P0927_LopNr_PersonNr], [Match_20], (2020) AS ar FROM [dbo].[Match_2020]
UNION
SELECT [P0927_LopNr_PersonNr], [Match_20], (2021) AS ar FROM [dbo].[Match_2021]