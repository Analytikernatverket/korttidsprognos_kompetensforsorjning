IF OBJECT_ID('P0927.KP_IndataFlode', 'U') IS NOT NULL
    DROP TABLE P0927.KP_IndataFlode;
GO

-- Använd explicit JOIN-syntax för ökad läsbarhet och prestanda
SELECT
    t1.P0927_LopNr_PersonNr,
    t1.ar AS ar1,
    t2.ar AS ar2,
    t1.lan AS lan1,
    t2.lan AS lan2,
    t1.kommun AS kommun1,
    t2.kommun AS kommun2,
    t1.alder AS alder1,
    t2.alder AS alder2,
    t1.ExamAr AS ExamAr1,
    t2.ExamAr AS ExamAr2,
    t1.sunRuapGrp AS sunRuapGrp1,
    t2.sunRuapGrp AS sunRuapGrp2
INTO 
    P0927.KP_IndataFlode
FROM
    (
        SELECT
            t1.P0927_LopNr_PersonNr,
            t1.ar,
            t1.lan,
            t1.Kommun,
            t1.alder,
            t1.ExamAr,
            t2.Sun2000GrpJust AS sunRuapGrp
        FROM 
            [P0927].KP_stativ t1
            INNER JOIN P0927.KP_utbTillhorighet t2 ON t1.P0927_LopNr_PersonNr = t2.P0927_LopNr_PersonNr AND t1.ar = t2.ar
        WHERE
            t1.Alder < 69
    ) t1
INNER JOIN
    (
        SELECT
            t1.P0927_LopNr_PersonNr,
            t1.ar,
            t1.lan,
            t1.Kommun,
            t1.alder,
            t1.ExamAr,
            t2.Sun2000GrpJust AS sunRuapGrp
        FROM 
            [P0927].KP_stativ t1
            INNER JOIN P0927.KP_utbTillhorighet t2 ON t1.P0927_LopNr_PersonNr = t2.P0927_LopNr_PersonNr AND t1.ar = t2.ar
        WHERE
            t1.alder > 19
    ) t2 ON t1.P0927_LopNr_PersonNr = t2.P0927_LopNr_PersonNr AND t1.ar = t2.ar - 1
