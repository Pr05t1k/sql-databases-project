WITH RECURSIVE EmployeeHierarchy AS (
    -- Базовый уровень: сам Иван Иванов
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE EmployeeID = 1
    
    UNION ALL
    
    -- Рекурсивный уровень: подчинённые
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT 
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS TaskNames
FROM EmployeeHierarchy eh
LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON eh.RoleID = r.RoleID
LEFT JOIN Tasks t ON eh.EmployeeID = t.AssignedTo
LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
GROUP BY eh.EmployeeID, eh.Name, eh.ManagerID, d.DepartmentName, r.RoleName
ORDER BY eh.Name;

WITH RECURSIVE EmployeeHierarchy AS (
    -- Базовый уровень: сам Иван Иванов
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE EmployeeID = 1
    
    UNION ALL
    
    -- Рекурсивный уровень: подчинённые
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
),
SubordinateCount AS (
    SELECT 
        ManagerID,
        COUNT(*) AS TotalSubordinates
    FROM Employees
    GROUP BY ManagerID
)
SELECT 
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS TaskNames,
    COUNT(DISTINCT t.TaskID) AS TotalTasks,
    COALESCE(sc.TotalSubordinates, 0) AS TotalSubordinates
FROM EmployeeHierarchy eh
LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON eh.RoleID = r.RoleID
LEFT JOIN Tasks t ON eh.EmployeeID = t.AssignedTo
LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
LEFT JOIN SubordinateCount sc ON eh.EmployeeID = sc.ManagerID
GROUP BY eh.EmployeeID, eh.Name, eh.ManagerID, d.DepartmentName, r.RoleName, sc.TotalSubordinates
ORDER BY eh.Name;

WITH RECURSIVE EmployeeHierarchy AS (
    -- Базовый уровень: все сотрудники
    SELECT 
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    
    UNION ALL
    
    -- Рекурсивный уровень: подчинённые
    SELECT 
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
),
RecursiveSubordinateCount AS (
    SELECT 
        ManagerID,
        COUNT(DISTINCT EmployeeID) AS TotalSubordinates
    FROM EmployeeHierarchy
    WHERE ManagerID IS NOT NULL
    GROUP BY ManagerID
),
ManagerEmployees AS (
    SELECT DISTINCT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    JOIN Roles r ON e.RoleID = r.RoleID
    WHERE r.RoleName = 'Менеджер'
)
SELECT 
    me.EmployeeID,
    me.Name AS EmployeeName,
    me.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS TaskNames,
    COALESCE(rsc.TotalSubordinates, 0) AS TotalSubordinates
FROM ManagerEmployees me
LEFT JOIN Departments d ON me.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON me.RoleID = r.RoleID
LEFT JOIN Tasks t ON me.EmployeeID = t.AssignedTo
LEFT JOIN Projects p ON t.ProjectID = p.ProjectID
LEFT JOIN RecursiveSubordinateCount rsc ON me.EmployeeID = rsc.ManagerID
WHERE COALESCE(rsc.TotalSubordinates, 0) > 0
GROUP BY me.EmployeeID, me.Name, me.ManagerID, d.DepartmentName, r.RoleName, rsc.TotalSubordinates
ORDER BY me.EmployeeID;