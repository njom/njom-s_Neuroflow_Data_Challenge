-- For the Neurofolw Data Challenge, this is an exploritory project with the goal of recommending a path forward for providing useful visualizations of GAD-7 results for caregiver consumption.


-- First, I confirm the assumption that all data are GAD-7 result data.
SELECT type, COUNT(*) AS count
FROM neuroflow_data_challenge.phq_all_final
GROUP BY type
;
-- All 53698 rows of data are from GAD-7 assessments


-- Next, I get an idea of how many patients the data represent.
SELECT COUNT(DISTINCT patient_id) AS num_of_patients
FROM phq_all_final
;
--  There are data from 15502 discreet patients in this dataset.

-- Assumption:
-- For expedience, I am assuming that there were no other GAD-7 data collected, for any given patient, during the period between that patient's earliest and latest recorded records in this dataset.

-- Counts how many times each patient completed the GAD-7
SELECT patient_id, COUNT(*) AS gad7_count
FROM phq_all_final
WHERE type = 'gad7'
GROUP BY patient_id;

-- I wanted to determine the mode, and the nth modes for the number of times each patient completed the GAD-7. This will help me determine what sort of visualizations might be helpful. (The needed subquery was a little bit advanced for for me, so I did enlist some help on this part)
SELECT gad7_count, COUNT(*) AS patient_count
FROM (
	SELECT patient_id, COUNT(*) AS gad7_count
	FROM phq_all_final
	WHERE type = 'gad7'
	GROUP BY patient_id
) AS subquery
GROUP BY gad7_count
ORDER BY gad7_count ASC
;
-- I found that the majority of patients completed the GAD-7 no more than 3 times.

-- I'm curious whether or not there is any correlation between the number of times a patient completes the GAD-7, and their average GAD-7 score. If there is, then we may want to focus our efforts more on patients who complete the assessment more times.(The needed subquery was a little bit advanced for for me, so I did enlist some help on this part)
SELECT gad7_count, COUNT(*) AS patient_count, AVG(avg_score) AS average_score
FROM (
	SELECT patient_id, COUNT(*) AS gad7_count, AVG(score) AS avg_score
	FROM phq_all_final
	WHERE type = 'gad7'
	GROUP BY patient_id
) AS subquery
GROUP BY gad7_count
HAVING COUNT(*) > 1 -- Filtering out patients who only took one test, since we are aiming to visualize progress.
ORDER BY gad7_count DESC;
-- Looking at the data, it appears as though there may be a positive correlation between the number of times a patient completed the GAD-7, and their average GAD-7 score.



-- Recommendations for caregiver visualizations:
-- If we assume that there is a higher likelihood that patients with a higher average scores are more likely to score in the Moderate (11-15) to Severe (16-21) range, then we might best serve the provider's needs by implementing visualization that best represent change over many GAD-7 results, rather than over a fewer number of results.
-- Given more time, I would have been interested to dig deeper into potential correlations having to do with time elapsed between GAD-7 assessments.
-- {LOOK HERE} Since caregivers may benefit from the ability monitor multiple patients at once, so to allocate their attention wherever it is most needed, and to provide a visualization that fits well on a small screen, I would recommend a clustered heatmap as one data visualization option.
-- The heatmap solution would allow caregivers to easily assess individual patiernts over time while also showing the bigger picture of how all of their patients are doing.
-- An added benefit of this solution would be that a color representing high risk would persist in a patient's bar until they tested again and scored lower.
-- A potential weakness of this solution would be that a color representing low risk might persist for too long in a high-risk patient's bar if significant time were to pass between GAD-7 assessments.

-- Recommendations for patient visualizations:
-- For patients, a shorter term visualization might be more beneficial (Last week's score and this week's score only) so to avoid compounding anxiety levels should scores fail to improve over time.
-- Integration with a health/excercise app might be a better way to involve the patient in self-monitoring, placing foucs on on metrics that are actually under their control rather than those that they may feel subject to.

-- Missing Data:
-- It may be helpful to include data concerning patient/caregiver interactions into the dataset. By marking such events on a visualization, patients and caregivers may be able to draw correlations between frequencey of interactions and positive progress.
-- It would have been helpful to have benchmark data representing a population not requiring medical intervaention. This might have helped to narrow down the dataset.
-- Information regarding pharmasutical intervention might be useful in drawing overlays on whatever sort of visualization is implemented.
