

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Likelyhood of dying in your country if you get infected in your country

SELECT location, date, total_cases, total_deaths, ( total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Nepal'
AND continent IS NOT NULL
ORDER BY 1,2;

--Looking at total cases vs total population
--Shows what percentage of population got covid in specific country

SELECT location, date, total_cases, population, ( total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Nepal'
AND continent IS NOT NULL
ORDER BY 1,2;

--Loking at countries with highest infection rate

SELECT location, MAX(total_cases) AS HighestInfection, population, MAX( total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Nepal'
GROUP BY location, population
ORDER BY 4 DESC;

--Loking at countries with highest death count

SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeath
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

--United states, Brazil and Mexico are the top 3 countries with high death count

--Loking at continents with highest death count

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeath
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

--Death rate per day world wide

SELECT  date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Final Death rate world wide

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL;

-- Total of 150574977 cases were found
-- Total of 3180206 people died
-- 2.11 percentage of people around the world died  due to covid


--Looking at total  total vaccination around the world by countries


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS VacCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Rolling Percentage of people vaccinated in each countries every day

WITH VacPercentage ( continent, location, date, population, new_vaccinations, VacCount)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS VacCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL)
SELECT *, (VacCount/population)*100 AS VacRate
FROM VacPercentage


--Using Temp Table to find rolling percentage of people vaccinated

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
VacCount numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS VacCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (VacCount/population)*100 AS VacRate
FROM #PercentPopulationVaccinated


--Total Percentage of people vaccinated in each countries

WITH CTE (location, population, Total_vaccination) AS
(
SELECT  dea.location, dea.population, SUM(CAST(vac.new_vaccinations AS INT)) AS Total_vaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL
group by dea.location, dea.population
)
SELECT *, (Total_vaccination/population)*100 AS VaccPercentage
FROM CTE
ORDER BY 1


--creating view for visualization 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS VacCount
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination vac
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent IS NOT NULL
