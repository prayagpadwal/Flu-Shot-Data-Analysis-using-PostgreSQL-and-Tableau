-- 1. Patient Demographics Analysis: 
-- How many patients are in each age group (e.g., 0-18, 19-35, 36-60, 60+)?
SELECT
CASE
	WHEN EXTRACT(YEAR FROM AGE('2024-01-01', p.birthdate)) <= 18 THEN '0-18'
	WHEN EXTRACT(YEAR FROM AGE('2024-01-01', p.birthdate)) BETWEEN 19 and 35 THEN '19-35'
	WHEN EXTRACT(YEAR FROM AGE('2024-01-01', p.birthdate)) BETWEEN 36 and 60 THEN '36-60'
	ELSE '60+'
END AS AgeGroup,
COUNT(*) AS GroupCount
FROM patients as p
GROUP BY AgeGroup

-- 2. Geographical Distribution:
-- What are the top 5 cities with the highest number of patients?
SELECT p.city, COUNT(p.id)
FROM patients as p
GROUP BY p.city
ORDER BY COUNT(p.id) DESC
LIMIT 5

-- 3. Healthcare Utilization Patterns:
-- How many encounters does each patient have on average?
-- According to my understanding, the above question has 2 meaning beacause it is incomplete.
-- 3.1
SELECT patient, COUNT(*) AS encounter_count
FROM conditions
GROUP BY patient;

-- 3.2
SELECT 
    AVG(encounter_count) AS AverageEncounters
FROM (
    SELECT 
        patient, 
        COUNT(*) AS encounter_count
    FROM 
        encounters
    GROUP BY 
        patient
);

-- 4. Condition Prevalence:
-- What are the top 10 most common conditions among patients?
SELECT description, COUNT(*) AS MostCommon
FROM conditions
GROUP BY description
ORDER BY MostCommon desc
LIMIT 10

-- 5. Healthcare Costs Analysis: 
-- What is the average healthcare expense per patient?
SELECT avg(healthcare_expenses)
FROM patients

-- 6. Encounter Analysis:
-- Which type of encounters (as per ENCOUNTERCLASS) is most common?
SELECT encounterclass, COUNT(encounterclass) AS Count_of_each
FROM encounters
GROUP BY encounterclass
ORDER BY Count_of_each desc

-- 7. Income vs. Healthcare Coverage:
-- Is there a correlation between patients' income levels and their healthcare coverage amounts?
SELECT 
    IncomeBracket,
    AVG(healthcare_coverage) AS AverageCoverage
FROM 
    (SELECT 
        healthcare_coverage,
        CASE
            WHEN income <= 1000 THEN '0-1K'
            WHEN income > 1000 AND income <= 10000 THEN '1K-10K'
            WHEN income > 10000 AND income <= 50000 THEN '10K-50K'
            WHEN income > 50000 AND income <= 100000 THEN '50K-100K'
            WHEN income > 100000 AND income <= 500000 THEN '100K-500K'
            WHEN income > 500000 THEN '500K+'
            ELSE 'Unknown'
        END AS IncomeBracket
    FROM 
        patients) AS IncomeBracketed
GROUP BY 
    IncomeBracket
ORDER BY 
    CASE IncomeBracket
        WHEN '0-1K' THEN 1
        WHEN '1K-10K' THEN 2
        WHEN '10K-50K' THEN 3
        WHEN '50K-100K' THEN 4
        WHEN '100K-500K' THEN 5
        WHEN '500K+' THEN 6
        ELSE 7
    END

-- 8. Immunization Records:
-- How many patients have received each type of immunization?
SELECT description, COUNT(patient) as Number_of_Patients
FROM immunizations
GROUP BY description
ORDER BY COUNT(patient) desc

-- 9. Patient Mortality: 
-- What is the average age at death for patients, and how does it vary by gender and race?
SELECT gender, race,
	AVG(EXTRACT(YEAR FROM AGE(patients.deathdate, patients.birthdate)))AS Age_of_patient
FROM patients
WHERE deathdate IS NOT NULL
	AND birthdate IS NOT NULL
GROUP BY race, gender

-- 10. Provider Workload:
-- Which healthcare provider has attended the most encounters?
SELECT provider, COUNT(provider) AS count_encounter
FROM encounters
GROUP BY provider
ORDER BY count_encounter desc
LIMIT 1

-- 11. Encounter Costs Analysis: 
-- What are the average total claim costs and payer coverage for each encounter class?
SELECT encounterclass, AVG(total_claim_cost) as average_claim, AVG(payer_coverage) as average_coverage
FROM encounters
GROUP BY encounterclass

-- 12. Marital Status and Health:
-- Is there a notable difference in the number of healthcare encounters between married and single patients?
SELECT p.marital, COUNT(e.id) AS NumberOfEncounters
FROM patients AS p
JOIN encounters AS e 
ON p.id = e.patient
WHERE p.marital IS NOT NULL
	AND (p.marital = 'S' OR p.marital = 'M')
GROUP BY p.marital

-- 13. Race and Ethnicity in Healthcare: 
-- How do healthcare expenses vary across different races and ethnicities?
SELECT p.race, AVG(p.healthcare_expenses) AS avg_healthcare_exp, p.ethnicity
FROM patients AS p
WHERE p.race IS NOT NULL
	AND p.healthcare_expenses IS NOT NULL
	AND p.ethnicity IS NOT NULL
GROUP BY p.race, p.ethnicity
ORDER BY avg_healthcare_exp desc

-- 14. Chronic Condition Management: 
-- Which patients with chronic conditions (conditions lasting more than 1 year) have the highest number of encounters?
SELECT
	EXTRACT(YEAR FROM AGE(c.stop, c.start)) AS Chronic_years, 
	c.patient, 
	c.encounter
FROM conditions AS c
WHERE c.start IS NOT NULL
	AND c.stop IS NOT NULL
	AND c.patient IS NOT NULL
	AND c.encounter IS NOT NULL
	AND EXTRACT(YEAR FROM AGE(c.stop, c.start)) <> 0
ORDER BY EXTRACT(YEAR FROM AGE(c.stop, c.start)) DESC;

-- 15. Patient Coverage Gaps: 
-- Identify patients with high healthcare expenses but low healthcare coverage.
SELECT id, 
    healthcare_expenses, 
    healthcare_coverage
FROM patients
WHERE 
    healthcare_expenses > (SELECT AVG(healthcare_expenses) FROM patients) -- Above average expenses
    AND healthcare_coverage < (SELECT AVG(healthcare_coverage) FROM patients) -- Below average coverage
