/*
    Qual entre as cripto moedas (BTC, ETH, XRP, LTC, DSH, XMR, NEO, XLM, NEM e DOGE) tiveram maior rendimento no ano de 2018?
    Obs: Consulta a melhorar utilizando CUBO
*/
SELECT
    a.id_dim_coin,
    (close - open) AS revenue,
    c.coin_name
FROM (
        SELECT
            open,
            fc.id_dim_coin
        FROM
            fact_coin fc
        LEFT JOIN dim_date d ON (
            d.id_dim_date = fc.id_dim_date
        )
        LEFT JOIN dim_time t ON (
            t.id_dim_time = fc.id_dim_time
        )
        WHERE
                d.year  = 2018
            AND d.month = 1
            AND d.day   = 1
            AND t.id_dim_time = 1
) AS a
LEFT JOIN (
            SELECT
                close,
                fc.id_dim_coin
            FROM
                fact_coin fc
            LEFT JOIN dim_date d ON (
                d.id_dim_date = fc.id_dim_date
            )
            LEFT JOIN dim_time t ON (
                t.id_dim_time = fc.id_dim_time
            )
            WHERE
                    d.year  = 2018
                AND d.month = 12
                AND d.day   = 31
                AND t.id_dim_time = 24
) AS b ON (
    a.id_dim_coin = b.id_dim_coin
)
LEFT JOIN dim_coin c ON (
    c.id_dim_coin = a.id_dim_coin 
);


/*
    Qual entre as cripto moedas (BTC, ETH, XRP, LTC, DSH, XMR, NEO, XLM, NEM e DOGE) tiveram maior rendimento no ano de 2019 até os dias atuais?
    Obs: Consulta a melhorar utilizando CUBO
*/
SELECT
    a.id_dim_coin,
    (close - open) AS revenue,
    c.coin_name
FROM (
        SELECT
            open,
            fc.id_dim_coin
        FROM
            fact_coin fc
        LEFT JOIN dim_date d ON (
            d.id_dim_date = fc.id_dim_date
        )
        LEFT JOIN dim_time t ON (
            t.id_dim_time = fc.id_dim_time
        )
        WHERE
                d.year  = 2019
            AND d.month = 1
            AND d.day   = 1
            AND t.id_dim_time = 1
) AS a
LEFT JOIN (
            SELECT
                close,
                fc.id_dim_coin
            FROM
                fact_coin fc
            LEFT JOIN dim_date d ON (
                d.id_dim_date = fc.id_dim_date
            )
            LEFT JOIN dim_time t ON (
                t.id_dim_time = fc.id_dim_time
            )
            WHERE
                    d.year  = 2019
                AND d.month = 2
                AND d.day   = 9
                AND t.id_dim_time = 24
) AS b ON (
    a.id_dim_coin = b.id_dim_coin
)
LEFT JOIN dim_coin c ON (
    c.id_dim_coin = a.id_dim_coin 
);


/*
    Quantas exchanges existem que contém "bit" no nome?
*/
SELECT
    COUNT(1)
FROM
    dim_exchange
WHERE
    LOWER(name) LIKE '%bit%';
    

/*
    No ano de 2018, qual foi o mês em que o BTC teve o maior número de diAS em alta (ou variação positiva) cONsecutivos? E quantos dias?
    Obs: Dias consecutivos não realizado
*/
SELECT
    SUM(IF(close - open > 0, 1, 0)) AS days,
    d.month
FROM (
    SELECT
        open,
        id_dim_coin,
        id_dim_date
    FROM
        fact_coin
    WHERE
        id_dim_time = 1
) AS a
LEFT JOIN (
    SELECT
        close,
        id_dim_coin,
        id_dim_date
    FROM
        fact_coin
    WHERE
        id_dim_time = 24
) AS b ON (
        a.id_dim_coin = b.id_dim_coin
    AND a.id_dim_date = b.id_dim_date
)
LEFT JOIN dim_coin c ON (
    c.id_dim_coin = a.id_dim_coin
)
LEFT JOIN dim_date d ON (
    d.id_dim_date = a.id_dim_date
)
WHERE
        c.coin_name = 'Bitcoin'
    AND d.year      = 2018 
GROUP BY
    d.month
ORDER BY
    1 DESC
LIMIT 1;


/*
    Em média, qual o horário com maior volume (em USD) de transações para o BTC no mês de Janeiro de 2019?
*/
SELECT
    AVG(fc.volume_to_usd),
    t.time
FROM
    fact_coin fc
LEFT JOIN dim_time t ON (
    t.id_dim_time = fc.id_dim_time
)
LEFT JOIN dim_date d ON (
    d.id_dim_date = fc.id_dim_date
)
LEFT JOIN dim_coin c ON (
    c.id_dim_coin = fc.id_dim_coin
)
WHERE
        d.year      = 2019
    AND d.month     = 1
    AND c.coin_name = 'Bitcoin'
GROUP BY
    t.time,
    c.coin_name
ORDER BY
    1 DESC
LIMIT 1;


/*
    Quais são as top 3 exchanges em volume de transações em: Janeiro de 2019, Janeiro de 2018 e Janeiro de 2017?
*/
SELECT
	d.year,
    e.name,
    SUM(volume)    
FROM
    fact_exchange AS fc
LEFT JOIN dim_date AS d ON (
    d.id_dim_date = fc.id_dim_date
)
INNER JOIN dim_exchange AS e ON (
    e.id_dim_exchange = fc.id_dim_exchange
)
WHERE
        d.year  = 2019
    AND d.month = 1
GROUP BY
    1, 2
ORDER BY
    1 DESC
LIMIT 3;
