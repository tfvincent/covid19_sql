SELECT * 
FROM ['COVID Deaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM ['COVID Vaccinations$']
--ORDER BY 3,4

--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_cases,population
FROM ['COVID Deaths$']
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at the total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases) AS DeathPercentage
FROM ['COVID Deaths$']
WHERE location like '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the total cases vs the population
--Shows what percentage of the population got Covid19
SELECT location, date, population, total_cases,(total_cases/population) AS CovidPercentage
FROM ['COVID Deaths$']
--WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) AS PercentPopulationInfected
FROM ['COVID Deaths$']
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Showing the countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM ['COVID Deaths$']
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--Lets break things down by continent

--Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM ['COVID Deaths$']
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 AS DeathPercentage
FROM ['COVID Deaths$']
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM ['COVID Deaths$'] AS d
JOIN ['COVID Vaccinations$'] AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp table
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM ['COVID Deaths$'] AS d
JOIN ['COVID Vaccinations$'] AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later viz
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM ['COVID Deaths$'] AS d
JOIN ['COVID Vaccinations$'] AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated