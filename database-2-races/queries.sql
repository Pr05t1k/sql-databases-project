-- =====================================================
-- База данных 2: Автомобильные гонки
-- Решения задач
-- =====================================================

-- -----------------------------------------------------
-- Задача 1
-- Для каждого класса найти автомобиль с наименьшей
-- средней позицией в гонках
-- -----------------------------------------------------
WITH CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
MinAvgPerClass AS (
    SELECT 
        car_class,
        MIN(average_position) AS min_avg_position
    FROM CarStats
    GROUP BY car_class
)
SELECT 
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count
FROM CarStats cs
JOIN MinAvgPerClass m ON cs.car_class = m.car_class 
    AND cs.average_position = m.min_avg_position
ORDER BY cs.average_position;

-- Ожидаемый результат:
-- +-----------------+-------------+------------------+------------+
-- | car_name        | car_class   | average_position | race_count |
-- +-----------------+-------------+------------------+------------+
-- | Ferrari 488     | Convertible | 1.0000           | 1          |
-- | Ford Mustang    | SportsCar   | 1.0000           | 1          |
-- | Toyota RAV4     | SUV         | 2.0000           | 1          |
-- | Mercedes S-Class| Luxury Sedan| 2.0000           | 1          |
-- | BMW 3 Series    | Sedan       | 3.0000           | 1          |
-- | Chevrolet Camaro| Coupe       | 4.0000           | 1          |
-- | Renault Clio    | Hatchback   | 5.0000           | 1          |
-- | Ford F-150      | Pickup      | 6.0000           | 1          |
-- +-----------------+-------------+------------------+------------+

-- -----------------------------------------------------
-- Задача 2
-- Найти автомобиль с наименьшей средней позицией
-- среди всех автомобилей
-- -----------------------------------------------------
WITH CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
)
SELECT 
    car_name,
    car_class,
    ROUND(average_position, 4) AS average_position,
    race_count,
    car_country
FROM CarStats
ORDER BY average_position, car_name
LIMIT 1;

-- Ожидаемый результат:
-- +-------------+-------------+------------------+------------+-------------+
-- | car_name    | car_class   | average_position | race_count | car_country |
-- +-------------+-------------+------------------+------------+-------------+
-- | Ferrari 488 | Convertible | 1.0000           | 1          | Italy       |
-- +-------------+-------------+------------------+------------+-------------+

-- -----------------------------------------------------
-- Задача 3
-- Найти классы с наименьшей средней позицией
-- и вывести все автомобили из этих классов
-- -----------------------------------------------------
WITH ClassAvg AS (
    SELECT 
        c.class AS car_class,
        AVG(r.position) AS class_avg_position
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
MinClassAvg AS (
    SELECT MIN(class_avg_position) AS min_avg
    FROM ClassAvg
),
TargetClasses AS (
    SELECT car_class
    FROM ClassAvg
    WHERE class_avg_position = (SELECT min_avg FROM MinClassAvg)
),
CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        cl.country AS car_country,
        (SELECT COUNT(DISTINCT race) FROM Results) AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    WHERE c.class IN (SELECT car_class FROM TargetClasses)
    GROUP BY c.name, c.class, cl.country
)
SELECT 
    car_name,
    car_class,
    ROUND(average_position, 4) AS average_position,
    race_count,
    car_country,
    total_races
FROM CarStats
ORDER BY average_position;

-- Ожидаемый результат:
-- +--------------+-------------+------------------+------------+-------------+-------------+
-- | car_name     | car_class   | average_position | race_count | car_country | total_races |
-- +--------------+-------------+------------------+------------+-------------+-------------+
-- | Ferrari 488  | Convertible | 1.0000           | 1          | Italy       | 8           |
-- | Ford Mustang | SportsCar   | 1.0000           | 1          | USA         | 8           |
-- +--------------+-------------+------------------+------------+-------------+-------------+

-- -----------------------------------------------------
-- Задача 4
-- Найти автомобили со средней позицией лучше
-- средней по классу (в классе минимум 2 автомобиля)
-- -----------------------------------------------------
WITH CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
),
ClassInfo AS (
    SELECT 
        c.class,
        AVG(r.position) AS class_avg_position,
        COUNT(DISTINCT c.name) AS cars_in_class
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
QualifiedClasses AS (
    SELECT class, class_avg_position
    FROM ClassInfo
    WHERE cars_in_class >= 2
)
SELECT 
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cs.car_country
FROM CarStats cs
JOIN QualifiedClasses qc ON cs.car_class = qc.class
WHERE cs.average_position < qc.class_avg_position
ORDER BY cs.car_class, cs.average_position;

-- Ожидаемый результат:
-- +---------------+-----------+------------------+------------+-------------+
-- | car_name      | car_class | average_position | race_count | car_country |
-- +---------------+-----------+------------------+------------+-------------+
-- | BMW 3 Series  | Sedan     | 3.0000           | 1          | Germany     |
-- | Toyota RAV4   | SUV       | 2.0000           | 1          | Japan       |
-- +---------------+-----------+------------------+------------+-------------+

-- -----------------------------------------------------
-- Задача 5
-- Найти классы с наибольшим количеством автомобилей,
-- имеющих среднюю позицию > 3.0
-- -----------------------------------------------------
WITH CarStats AS (
    SELECT 
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        cl.country AS car_country
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
),
ClassLowPositionCount AS (
    SELECT 
        car_class,
        COUNT(*) AS low_position_count
    FROM CarStats
    WHERE average_position > 3.0
    GROUP BY car_class
),
MaxLowPositionCount AS (
    SELECT MAX(low_position_count) AS max_count
    FROM ClassLowPositionCount
),
TargetClasses AS (
    SELECT car_class
    FROM ClassLowPositionCount
    WHERE low_position_count = (SELECT max_count FROM MaxLowPositionCount)
)
SELECT 
    cs.car_name,
    cs.car_class,
    ROUND(cs.average_position, 4) AS average_position,
    cs.race_count,
    cs.car_country,
    (SELECT COUNT(DISTINCT race) FROM Results) AS total_races,
    clpc.low_position_count
FROM CarStats cs
JOIN ClassLowPositionCount clpc ON cs.car_class = clpc.car_class
WHERE cs.car_class IN (SELECT car_class FROM TargetClasses)
ORDER BY clpc.low_position_count DESC, cs.average_position;

-- Ожидаемый результат:
-- +-----------------+-------------+------------------+------------+-------------+-------------+--------------------+
-- | car_name        | car_class   | average_position | race_count | car_country | total_races | low_position_count |
-- +-----------------+-------------+------------------+------------+-------------+-------------+--------------------+
-- | Audi A4         | Sedan       | 8.0000           | 1          | Germany     | 8           | 2                  |
-- | Chevrolet Camaro| Coupe       | 4.0000           | 1          | USA         | 8           | 1                  |
-- | Renault Clio    | Hatchback   | 5.0000           | 1          | France      | 8           | 1                  |
-- | Ford F-150      | Pickup      | 6.0000           | 1          | USA         | 8           | 1                  |
-- +-----------------+-------------+------------------+------------+-------------+-------------+--------------------+