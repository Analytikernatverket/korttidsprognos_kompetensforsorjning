IF OBJECT_ID('P0927.KP_syssPerUtbGrp', 'U') IS NOT NULL
    DROP TABLE P0927.KP_syssPerUtbGrp;
GO
select
	t1.ar,
	t1.kommun,
	t1.alder,
	t1.sunRuapGrp,
	t1.totalt,
	t2.syss
into
	p0927.KP_syssPerUtbGrp
from
	(
		select
			t1.ar,
			t1.kommun,
			t1.alder,
			t2.Sun2000GrpJust as sunRuapGrp,
			count(*) as totalt
		from
			[P0927].KP_stativ t1,
			[P0927].[KP_utbTillhorighet] t2
		where
			t1.ar > 2014
			and t1.ar = t2.ar
			and t1.P0927_LopNr_PersonNr=t2.P0927_LopNr_PersonNr

		group by
			t1.ar,
			t1.kommun,
			t1.alder,
			t2.Sun2000GrpJust
	) t1,
	(
		select
			t1.ar,
			t1.kommun,
			t1.alder,
			t2.Sun2000GrpJust as sunRuapGrp,
			count(*) as syss
		from
			[P0927].KP_stativ t1,
			[P0927].[KP_utbTillhorighet] t2
		where
			t1.ar > 2014
			and t1.ar = t2.ar
			and t1.P0927_LopNr_PersonNr=t2.P0927_LopNr_PersonNr
			and SyssStat = '1'
		group by
			t1.ar,
			t1.kommun,
			t1.alder,
			t2.Sun2000GrpJust
	) t2
where
	t1.ar=t2.ar
	and t1.kommun=t2.kommun
	and t1.alder=t2.alder
	and t1.sunRuapGrp=t2.sunRuapGrp