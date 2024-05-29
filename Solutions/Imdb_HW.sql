/* Query 1.)
Calculate the average of the ratings (rounded to 3 decimal places) of the movies
by genre for each year from 2010 to 2014 for each genre, Adventure, and
Comedy. */

SELECT
    tb1.startyear AS year,
    'Adventure'   AS genres,
    round(AVG(tr1.averagerating),
          3)      AS yearly_avg
FROM
    imdb00.title_ratings tr1,
    imdb00.title_basics  tb1
WHERE
        tr1.tconst = tb1.tconst
    AND tb1.titletype = 'movie'
    AND tb1.startyear >= '2010'
    AND tb1.startyear <= '2014'
    AND tb1.genres LIKE '%Adventure%'
GROUP BY
    tb1.startyear
UNION
(
    SELECT
        tb2.startyear AS year,
        'Comedy'      AS genres,
        round(AVG(tr2.averagerating),
              3)      AS yearly_avg
    FROM
        imdb00.title_ratings tr2,
        imdb00.title_basics  tb2
    WHERE
            tr2.tconst = tb2.tconst
        AND tb2.titletype = 'movie'
        AND tb2.startyear >= '2010'
        AND tb2.startyear <= '2014'
        AND tb2.genres LIKE '%Comedy%'
    GROUP BY
        tb2.startyear
);


 /* Query 2.)
For each year from 2007 to 2021 and for the Romance genre, find out the lead
actor/actress names with the highest average rating. In case there are multiple
actors/actresses with the same highest average rating, you need to display all of
them. */

SELECT
    startyear      AS year,
    'Romance'      AS genre,
    highest_avg_actorrating,
    nb.primaryname AS most_popular_actor
FROM
    imdb00.name_basics nb,
    (
        SELECT
            nconst,
            x.startyear,
            x.highest_avg_actorrating
        FROM
            (
                SELECT
                    tp.nconst,
                    MAX(tr.averagerating) AS highest_avg_actorrating,
                    tb.startyear
                FROM
                    imdb00.title_principals tp,
                    imdb00.title_ratings    tr,
                    imdb00.title_basics     tb
                WHERE
                    ( tp.tconst = tr.tconst
                      AND tr.tconst = tb.tconst
                      AND ( tp.ordering = 1
                            AND category LIKE '%act%'
                            AND tr.numvotes >= '75000' )
                      AND ( tb.startyear >= '2007'
                            AND tb.startyear <= '2021'
                            AND tb.genres LIKE '%Romance%' )
                      AND tb.titletype = 'movie' )
                GROUP BY
                    tp.nconst,
                    tb.startyear
            ) x,
            (
                SELECT
                    MAX(highest_avg_actorrating) AS highest_avg,
                    startyear
                FROM
                    (
                        SELECT
                            tp.nconst,
                            MAX(tr.averagerating) AS highest_avg_actorrating,
                            tb.startyear
                        FROM
                            imdb00.title_principals tp,
                            imdb00.title_ratings    tr,
                            imdb00.title_basics     tb
                        WHERE
                            ( tp.tconst = tr.tconst
                              AND tr.tconst = tb.tconst
                              AND ( tp.ordering = 1
                                    AND category LIKE '%act%'
                                    AND tr.numvotes >= '75000' )
                              AND ( tb.startyear >= '2007'
                                    AND tb.startyear <= '2021'
                                    AND tb.genres LIKE '%Romance%' )
                              AND tb.titletype = 'movie' )
                        GROUP BY
                            tp.nconst,
                            tb.startyear
                    ) x
                GROUP BY
                    startyear
            ) y
        WHERE
                x.startyear = y.startyear
            AND highest_avg_actorrating = highest_avg
    )                  z
WHERE
    z.nconst = nb.nconst
ORDER BY
    startyear;