-- =====================================================
-- База данных 3: Бронирование отелей
-- Решения задач
-- =====================================================

-- -----------------------------------------------------
-- Задача 1
-- Клиенты с более чем 2 бронированиями в разных отелях
-- -----------------------------------------------------
SELECT 
    c.name,
    c.email,
    c.phone,
    COUNT(DISTINCT b.ID_booking) AS total_bookings,
    GROUP_CONCAT(DISTINCT h.name ORDER BY h.name SEPARATOR ', ') AS hotels_list,
    AVG(DATEDIFF(b.check_out_date, b.check_in_date)) AS avg_stay_duration
FROM Customer c
JOIN Booking b ON c.ID_customer = b.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(DISTINCT b.ID_booking) > 2
   AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY total_bookings DESC;

-- Ожидаемый результат:
-- +-------------+------------------------+-------------+----------------+-------------------------------------+--------------------+
-- | name        | email                  | phone       | total_bookings | hotels_list                         | avg_stay_duration  |
-- +-------------+------------------------+-------------+----------------+-------------------------------------+--------------------+
-- | Bob Brown   | bob.brown@example.com  | +2233445566 | 3              | Grand Hotel, Ocean View Resort      | 3.0000             |
-- | Ethan Hunt  | ethan.hunt@example.com | +5566778899 | 3              | Mountain Retreat, Ocean View Resort | 3.0000             |
-- +-------------+------------------------+-------------+----------------+-------------------------------------+--------------------+

-- -----------------------------------------------------
-- Задача 2
-- Клиенты с >2 бронированиями в разных отелях
-- и потратившие более 500$
-- -----------------------------------------------------
SELECT 
    c.ID_customer,
    c.name,
    COUNT(DISTINCT b.ID_booking) AS total_bookings,
    SUM(r.price) AS total_spent,
    COUNT(DISTINCT h.ID_hotel) AS unique_hotels
FROM Customer c
JOIN Booking b ON c.ID_customer = b.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name
HAVING COUNT(DISTINCT b.ID_booking) > 2
   AND COUNT(DISTINCT h.ID_hotel) > 1
   AND SUM(r.price) > 500
ORDER BY total_spent ASC;

-- Ожидаемый результат:
-- +-------------+-------------+----------------+-------------+---------------+
-- | ID_customer | name        | total_bookings | total_spent | unique_hotels |
-- +-------------+-------------+----------------+-------------+---------------+
-- | 4           | Bob Brown   | 3              | 820.00      | 2             |
-- | 7           | Ethan Hunt  | 3              | 850.00      | 2             |
-- +-------------+-------------+----------------+-------------+---------------+

-- -----------------------------------------------------
-- Задача 3
-- Классификация клиентов по предпочтениям
-- (дорогие/средние/дешёвые отели)
-- -----------------------------------------------------
WITH HotelCategory AS (
    SELECT 
        h.ID_hotel,
        h.name AS hotel_name,
        AVG(r.price) AS avg_price,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS category
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel, h.name
),
CustomerHotels AS (
    SELECT 
        c.ID_customer,
        c.name,
        hc.hotel_name,
        hc.category
    FROM Customer c
    JOIN Booking b ON c.ID_customer = b.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN HotelCategory hc ON r.ID_hotel = hc.ID_hotel
    GROUP BY c.ID_customer, c.name, hc.hotel_name, hc.category
),
CustomerPreference AS (
    SELECT 
        ID_customer,
        name,
        GROUP_CONCAT(DISTINCT hotel_name ORDER BY hotel_name SEPARATOR ', ') AS visited_hotels,
        CASE
            WHEN SUM(category = 'Дорогой') > 0 THEN 'Дорогой'
            WHEN SUM(category = 'Средний') > 0 THEN 'Средний'
            ELSE 'Дешевый'
        END AS preferred_hotel_type
    FROM CustomerHotels
    GROUP BY ID_customer, name
)
SELECT 
    ID_customer,
    name,
    preferred_hotel_type,
    visited_hotels
FROM CustomerPreference
ORDER BY 
    CASE preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        ELSE 3
    END;

-- Ожидаемый результат:
-- +-------------+-------------------+----------------------+--------------------------------------------------+
-- | ID_customer | name              | preferred_hotel_type | visited_hotels                                   |
-- +-------------+-------------------+----------------------+--------------------------------------------------+
-- | 10          | Hannah Montana    | Дешевый              | City Center Inn                                  |
-- | 1           | John Doe          | Средний              | City Center Inn, Grand Hotel                     |
-- | 2           | Jane Smith        | Средний              | Grand Hotel                                      |
-- | 3           | Alice Johnson     | Средний              | Grand Hotel                                      |
-- | 4           | Bob Brown         | Средний              | Grand Hotel, Ocean View Resort                   |
-- | 5           | Charlie White     | Средний              | Ocean View Resort                                |
-- | 6           | Diana Prince      | Средний              | Ocean View Resort                                |
-- | 7           | Ethan Hunt        | Дорогой              | Mountain Retreat, Ocean View Resort              |
-- | 8           | Fiona Apple       | Дорогой              | Mountain Retreat                                 |
-- | 9           | George Washington | Дорогой              | City Center Inn, Mountain Retreat                |
-- +-------------+-------------------+----------------------+--------------------------------------------------+