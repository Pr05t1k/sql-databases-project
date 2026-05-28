-- Создание таблицы Vehicle

CREATE TABLE Vehicle (
    maker VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    type ENUM('Car', 'Motorcycle', 'Bicycle') NOT NULL,
    PRIMARY KEY (model)
);
-- Создание таблицы Car

CREATE TABLE Car (
    vin VARCHAR(17) NOT NULL,
    model VARCHAR(100) NOT NULL,
    engine_capacity DECIMAL(4, 2) NOT NULL, -- объем двигателя в литрах
    horsepower INT NOT NULL,                 -- мощность в лошадиных силах
    price DECIMAL(10, 2) NOT NULL,           -- цена в долларах
    transmission ENUM('Automatic', 'Manual') NOT NULL, -- тип трансмиссии
    PRIMARY KEY (vin),
    FOREIGN KEY (model) REFERENCES Vehicle(model)
);
-- Создание таблицы Motorcycle

CREATE TABLE Motorcycle (
    vin VARCHAR(17) NOT NULL,
    model VARCHAR(100) NOT NULL,
    engine_capacity DECIMAL(4, 2) NOT NULL, -- объем двигателя в литрах
    horsepower INT NOT NULL,                 -- мощность в лошадиных силах
    price DECIMAL(10, 2) NOT NULL,           -- цена в долларах
    type ENUM('Sport', 'Cruiser', 'Touring') NOT NULL, -- тип мотоцикла
    PRIMARY KEY (vin),
    FOREIGN KEY (model) REFERENCES Vehicle(model)
);
-- Создание таблицы Bicycle

CREATE TABLE Bicycle (
    serial_number VARCHAR(20) NOT NULL,
    model VARCHAR(100) NOT NULL,
    gear_count INT NOT NULL,                 -- количество передач
    price DECIMAL(10, 2) NOT NULL,           -- цена в долларах
    type ENUM('Mountain', 'Road', 'Hybrid') NOT NULL, -- тип велосипеда
    PRIMARY KEY (serial_number),
    FOREIGN KEY (model) REFERENCES Vehicle(model)
);