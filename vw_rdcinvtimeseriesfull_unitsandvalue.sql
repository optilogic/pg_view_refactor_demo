EXPLAIN WITH daily_inventory AS (
    SELECT DISTINCT ON (scenarioname, facilityname, productname, "time"::date)
        scenarioname,
        facilityname,
        productname,
        "time"::date AS simdate,
        inventoryonhandquantity
    FROM simulationinventoryonhandreport
    WHERE scenarioname = 'RDC HW'
    ORDER BY scenarioname, facilityname, productname, "time"::date, "time" DESC
)
SELECT di.scenarioname,
    ip.flowpath,
    SUM(di.inventoryonhandquantity) AS unitsonhand,
    SUM(pr.unitvalue::numeric * di.inventoryonhandquantity) AS valueonhand,
    di.simdate
FROM daily_inventory di
LEFT JOIN inventorypolicies ip
    ON di.facilityname = replace(replace(lower(ip.facilityname), 'w12901x', 'w12901'), 'w12901', 'w12901x')
    AND di.productname = lower(ip.productname)
LEFT JOIN products pr
    ON di.productname = lower(pr.productname)
GROUP BY di.scenarioname, ip.flowpath, di.simdate;