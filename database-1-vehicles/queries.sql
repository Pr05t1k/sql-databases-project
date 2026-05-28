

-- =====================================================
-- База данных 1: Транспортные средства
-- =====================================================

-- -----------------------------------------------------
-- Задача 1
-- Мотоциклы: мощность > 150, цена < 20000, тип Sport
-- -----------------------------------------------------
SELECT 
    v.maker,
    m.model
FROM Motorcycle m
JOIN Vehicle v ON m.model = v.model
WHERE m.horsepower > 150
  AND m.price < 20000
  AND m.type = 'Sport'
ORDER BY m.horsepower DESC;

-- Ожидаемый результат:
-- maker  | model
-- Yamaha | YZF-R1


-- -----------------------------------------------------
-- Задача 2
-- Объединение автомобилей, мотоциклов и велосипедов
-- -----------------------------------------------------
-- Автомобили
SELECT 
    v.maker,
    c.model,
    c.horsepower,
    c.engine_capacity,
    'Car' AS vehicle_type
FROM Car c
JOIN Vehicle v ON c.model = v.model
WHERE c.horsepower > 150
  AND c.engine_capacity < 3
  AND c.price < 35000

UNION ALL

-- Мотоциклы
SELECT 
    v.maker,
    m.model,
    m.horsepower,
    m.engine_capacity,
    'Motorcycle' AS vehicle_type
FROM Motorcycle m
JOIN Vehicle v ON m.model = v.model
WHERE m.horsepower > 150
  AND m.engine_capacity < 1.5
  AND m.price < 20000

UNION ALL

-- Велосипеды
SELECT 
    v.maker,
    b.model,
    NULL AS horsepower,
    NULL AS engine_capacity,
    'Bicycle' AS vehicle_type
FROM Bicycle b
JOIN Vehicle v ON b.model = v.model
WHERE b.gear_count > 18
  AND b.price < 4000

ORDER BY horsepower DESC;
-- Ожидаемый результат:
-- maker    | model     | horsepower | engine_capacity | vehicle_type
-- Toyota   | Camry     | 203        | 2.50           | Car
-- Yamaha   | YZF-R1    | 200        | 1.00           | Motorcycle
-- Honda    | Civic     | 158        | 2.00           | Car
-- Trek     | Domane    | NULL       | NULL           | Bicycle
-- Giant    | Defy      | NULL       | NULL           | Bicycle