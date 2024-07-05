CREATE or ALTER VIEW P0927.KP_stativ AS
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], null as [sun2020Inr],  [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],  [ArbetsInk], [ForvErs], (2014) as ar from [dbo].[STATIV2014_tot]
union
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], null as [sun2020Inr],  [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],  [ArbetsInk], [ForvErs], (2015) as ar from [dbo].[STATIV2015_tot]
union
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], null as [sun2020Inr],  [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],  [ArbetsInk], [ForvErs], (2016) as ar from [dbo].[STATIV2016_tot]
union
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], null as [sun2020Inr],  [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],   [ArbetsInk], [ForvErs], (2017) as ar from [dbo].[STATIV2017_tot]
union
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], null as [sun2020Inr],  [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],  [ArbetsInk], [ForvErs], (2018) as ar from [dbo].[STATIV2018_tot]
union
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], [sun2020Inr],  null as [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],  [ArbetsInk], [ForvErs], (2019) as ar from [dbo].[STATIV2019_tot]
union
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], [sun2020Inr],  null as [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],  [ArbetsInk], [ForvErs], (2020) as ar from [dbo].[STATIV2020_tot]
union
select [P0927_LopNr_PersonNr], [Alder], [Kon], [Lan],[Kommun], [AstKommun], [SyssStat], [Sun2000Grp], [sun2020Inr],  null as [sun2000Inr], try_convert(int, [ExamAr]) as [ExamAr],  [ArbetsInk], [ForvErs], (2021) as ar from [dbo].[STATIV2021_tot]


