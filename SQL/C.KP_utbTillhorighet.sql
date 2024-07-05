IF OBJECT_ID('P0927.KP_utbTillhorighet', 'U') IS NOT NULL
    DROP TABLE P0927.KP_utbTillhorighet;
GO
select
	[ar],
	[P0927_LopNr_PersonNr],
case
	when (t1.Sun2000Grp = '75N' and t1.sun2000Inr != '723a') then '75S'
	when (t1.Sun2000Grp = '75N' and t1.sun2020Inr != '723a') then '75S'
	else t1.Sun2000Grp
end as Sun2000GrpJust,
	Sun2000Grp,
	sun2000Inr,
	sun2020Inr
into P0927.KP_utbTillhorighet
FROM 
    [P0927].KP_stativ t1