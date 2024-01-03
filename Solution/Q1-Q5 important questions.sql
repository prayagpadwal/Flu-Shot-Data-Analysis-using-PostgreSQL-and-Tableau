-- Q1
SELECT  
	p.race, 
	p.county,
    CASE 
        WHEN EXTRACT(YEAR FROM AGE('2024-01-01', p.BIRTHDATE)) < 18 THEN '0-17'
        WHEN EXTRACT(YEAR FROM AGE('2024-01-01', p.BIRTHDATE)) BETWEEN 18 AND 35 THEN '18-35'
        WHEN EXTRACT(YEAR FROM AGE('2024-01-01', p.BIRTHDATE)) BETWEEN 36 AND 59 THEN '36-59'
        ELSE '60+'
     END AS AgeGroup
	 COUNT (*) AS GroupCount
FROM patients as p
JOIN immunizations as i
ON p.id = i.patient
WHERE EXTRACT(YEAR FROM i.date) = 2022
	AND i.description LIKE '%Flu'
GROUP BY p.race, p.county, AgeGroup, i.description

-----------------------------------------------------------------------------------------------------------------
-- Q2(a)
SELECT *
FROM patients as p

SELECT *
FROM immunizations as i
WHERE i.description LIKE '%Flu%'

------- Below is the answer of question 2 (a)
SELECT 
	p.race, 
	p.county,
	EXTRACT(YEAR FROM AGE('2024-01-01', p.birthdate)) AS Age
FROM 
	patients as p
JOIN 
	immunizations as i
ON 
	p.Id = i.patient
WHERE 
	i.description LIKE '%Flu%'
	AND EXTRACT(YEAR FROM i.date) = 2022
GROUP BY
	p.race,
	p.county,
	Age
-----------------------------------------------------------------------------------------------------------------
-- Q2(b)
-------What is the percentage?
SELECT COUNT(i.patient) --total
FROM immunizations as i

SELECT COUNT(i.patient) --specific
FROM immunizations as i
WHERE i.description LIKE '%Flu%'
	AND EXTRACT(YEAR FROM i.date) = 2022 

------- Below is the answer of question 2 (b)
SELECT
	(SELECT COUNT(i.patient) --specific
	FROM immunizations as i
	WHERE i.description LIKE '%Flu%'
		AND EXTRACT(YEAR FROM i.date) = 2022) * 100 /
	(SELECT COUNT(i.patient) --total
	FROM immunizations as i) AS percentage_of_vaccinated
-----------------------------------------------------------------------------------------------------------------
-- Q3
-- Now lets calculate flu shots per month
SELECT
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 1 THEN 1 ELSE 0 END) AS Jan,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 2 THEN 1 ELSE 0 END) AS Feb,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 3 THEN 1 ELSE 0 END) AS Mar,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 4 THEN 1 ELSE 0 END) AS Apr,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 5 THEN 1 ELSE 0 END) AS May,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 6 THEN 1 ELSE 0 END) AS Jun,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 7 THEN 1 ELSE 0 END) AS Jul,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 8 THEN 1 ELSE 0 END) AS Aug,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 9 THEN 1 ELSE 0 END) AS Sep,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 10 THEN 1 ELSE 0 END) AS Oct,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 11 THEN 1 ELSE 0 END) AS Nov,
	SUM(CASE WHEN EXTRACT(MONTH FROM i.date) = 12 THEN 1 ELSE 0 END) AS Dec
FROM 
	immunizations as i
WHERE 
	i.description LIKE '%Flu%'
	AND EXTRACT(YEAR FROM i.date) = 2022
-----------------------------------------------------------------------------------------------------------------	
-- Q4
SELECT COUNT(patient)
FROM immunizations as i
WHERE i.description LIKE '%Flu%'
	AND EXTRACT(YEAR FROM i.date) = 2022
-- 8437 flu shots were adminstered in the year 2020.

--Q5(a)
SELECT  i.patient, p.first, p.last, p.gender, p.county, i.description
FROM immunizations as i
JOIN patients as p
ON i.patient = p.Id
WHERE i.description LIKE '%Flu%'
	AND EXTRACT(YEAR FROM i.date) = 2022 
-- list of patients who received a flu shot in 2022
-----------------------------------------------------------------------------------------------------------------
----Q5(b)
SELECT  i.patient, p.first, p.last, p.gender, p.county, i.description
FROM immunizations as i
JOIN patients as p
ON i.patient = p.Id
WHERE i.description NOT LIKE '%Flu%'
	AND EXTRACT(YEAR FROM i.date) = 2022 
-- list of patients who did not receive a flu shot in 2022
-----------------------------------------------------------------------------------------------------------------


