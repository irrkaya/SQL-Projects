Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3, 4

Select location, date,total_cases,new_cases,total_deaths,population 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
(CAST(total_deaths AS decimal) / CAST(total_cases AS decimal)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location= 'australia' 
and continent is not null
ORDER BY 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, 
(CAST(total_cases AS decimal) / CAST(population AS decimal)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location= 'australia'
ORDER BY 2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(CAST(total_deaths as int)) AS HighestInfectionCount, 
MAX((CAST(total_cases AS decimal) / CAST(population AS decimal))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Contitents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, 
SUM(CAST(new_deaths AS int)) AS total_deaths, 
CASE
WHEN SUM(new_cases) = 0 THEN NULL
ELSE (SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases),0))*100
END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group By date
ORDER BY 1, 2


-- Looking at Totat Population vs Vaccinations


--USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinatoins, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated