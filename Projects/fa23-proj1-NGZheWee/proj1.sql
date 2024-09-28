-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
 SELECT MAX(era)
 FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE nameFirst LIKE '% %'
  ORDER BY nameFirst ASC, nameLast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthYear, avg(height), count(*)
  FROM people
  GROUP BY birthYear
  ORDER BY birthYear 
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthYear, avg(height), count(*)
  FROM people
  GROUP BY birthYear
  HAVING avg(height) > 70
  ORDER BY birthYear 
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.nameFirst, p.nameLast, p.playerID, h.yearID
  FROM people AS p, HallofFame AS h
  WHERE p.playerID = h.playerID AND h.inducted = 'Y'
  ORDER BY h.yearID DESC, p.playerID ASC 
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.nameFirst, p.nameLast, p.playerID, c.schoolID, h.yearID
  FROM people AS p
  INNER JOIN HallofFame AS h ON p.playerID = h.playerID
  INNER JOIN CollegePlaying AS c ON p.playerID = c.playerID
  INNER JOIN schools AS s ON s.schoolID= c.schoolID
  WHERE h.inducted = 'Y' AND s.schoolState = 'CA'
  ORDER BY h.yearID DESC, c.schoolID ASC, p.playerID ASC;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, c.schoolID
  FROM HallofFame AS h
  INNER JOIN people AS p ON h.playerID = p.playerID
  LEFT JOIN CollegePlaying AS c ON c.playerID = p.playerID
  WHERE h.inducted = 'Y' 
  ORDER BY p.playerID DESC, c.schoolID ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, b.yearID, 
       CAST((b.H-b.H2B-b.H3B-b.HR+2*H2B+3*H3B+4*HR) AS FLOAT) / b.AB AS slg
  FROM batting as b
  INNER JOIN people as p ON b.playerID = p.playerID
  WHERE b.AB > 50 
  ORDER BY slg DESC, b.yearID ASC, p.playerid ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT playerID, nameFirst, nameLast, CAST(lb.lH+2*lb.lH2B+3*lb.lH3B+4*lb.lHR AS FLOAT) / lb.lAB  AS lslg
  FROM (
      SELECT p.playerID, p.nameFirst, p.nameLast, 
      SUM(b.H)-SUM(b.H2B)-SUM(b.H3B)-SUM(b.HR)AS lH,
      SUM(b.H2B) AS lH2B,
      SUM(b.H3B) AS lH3B,
      SUM(b.HR) AS lHR,
      SUM(b.AB) AS lAB
      FROM batting as b
      INNER JOIN people AS p ON p.playerID = b.playerID
      GROUP BY p.playerID
      HAVING SUM(b.AB) > 50
  ) as lb
  ORDER BY lslg DESC, playerID ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT nameFirst, nameLast, CAST(lb.lH+2*lb.lH2B+3*lb.lH3B+4*lb.lHR AS FLOAT) / lb.lAB  AS lslg
  FROM (
      SELECT p.playerID, p.nameFirst, p.nameLast, 
      SUM(b.H)-SUM(b.H2B)-SUM(b.H3B)-SUM(b.HR)AS lH,
      SUM(b.H2B) AS lH2B,
      SUM(b.H3B) AS lH3B,
      SUM(b.HR) AS lHR,
      SUM(b.AB) AS lAB
      FROM batting as b
      INNER JOIN people AS p ON p.playerID = b.playerID
      GROUP BY p.playerID
      HAVING SUM(b.AB) > 50
  ) as lb
  WHERE lslg > 
  (
    SELECT CAST(SUM(b.H) - SUM(b.H2B) - SUM(b.H3B) - SUM(b.HR) + 2 * SUM(b.H2B) + 3 * SUM(b.H3B) + 4 * SUM(b.HR) AS FLOAT) / SUM(b.AB)
    FROM batting as b
    WHERE b.playerID = 'mayswi01'
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearID, min(salary), max(salary), avg(salary)
  FROM salaries
  GROUP BY yearID
  ORDER BY yearID ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH intervals AS (
    SELECT
    bi.binid as ID,
    (bi.binid * (MAX(s.salary) - MIN(s.salary)) / 10 + MIN(s.salary)) AS lowerBound,
    ((bi.binid + 1) * (MAX(s.salary) - MIN(s.salary)) / 10 + MIN(s.salary)) AS upperBound
    FROM binids AS bi,salaries AS s 
    WHERE s.yearID = 2016
    GROUP BY bi.binid
  )

  SELECT intervals.ID, intervals.lowerBound, intervals.upperBound, COUNT(s.salary) as numOfPeople
  FROM intervals, salaries AS s 
  WHERE s.yearID = 2016 AND intervals.lowerBound <= s.salary AND s.salary <= intervals.upperBound
  GROUP BY intervals.ID
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH SalaryChanges AS (
    SELECT
        yearID,
        MIN(salary) AS minSalary,
        MAX(salary) AS maxSalary,
        AVG(salary) AS avgSalary,
        LAG(MIN(salary)) OVER (ORDER BY yearID) AS prevMinSalary,
        LAG(MAX(salary)) OVER (ORDER BY yearID) AS prevMaxSalary,
        LAG(AVG(salary)) OVER (ORDER BY yearID) AS prevAvgSalary
    FROM
        salaries
    GROUP BY
        yearID
    HAVING
        COUNT(salary) > 0
)

SELECT
    yearID,
    minSalary - prevMinSalary AS mindiff,
    maxSalary - prevMaxSalary AS maxdiff,
    avgSalary - prevAvgSalary AS avgdiff
FROM
    SalaryChanges
WHERE
    prevMinSalary IS NOT NULL
ORDER BY
    yearID ASC;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerID, nameFirst, nameLast, salary, s.yearID
  FROM people as p
  INNER JOIN salaries as s ON p.playerID = s.playerID
  WHERE (s.yearID = 2000 AND s.salary >= (SELECT max(salary) FROM salaries WHERE salaries.yearID = 2000)) 
    OR (s.yearID = 2001 AND s.salary >= (SELECT max(salary) FROM salaries WHERE salaries.yearID = 2001))
;


-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT a.teamID, 
       MAX(s.salary) - MIN(s.salary) AS diffAvg
FROM allstarfull AS a
INNER JOIN salaries AS s ON a.playerID = s.playerID
WHERE a.yearID = 2016 AND s.yearID = 2016
GROUP BY a.teamID;
;

