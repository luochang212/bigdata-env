SELECT 
    student_id,
    student_name,
    ROUND(AVG(score), 2) AS avg_score
FROM 
    student_db.student_scores
GROUP BY 
    student_id, student_name
ORDER BY 
    avg_score DESC
LIMIT 10;
