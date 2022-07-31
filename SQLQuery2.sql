SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4
--SELECT * 
--FROM PortfolioProject..CovidVaccinations 
--ORDER BY 3,4 

SELECT location, date, population, total_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Shows probability of dying if you contract with Covid
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE location like 'India' AND continent is not null
ORDER BY 1,2


--Looking at the total cases vs population
--Shows percentage of population that was infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentage_of_infected_population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at countries with highest infection rate Compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count_per_location, MAX(total_cases/population)*100 AS highest_infected_population_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC


--Showing countries with highest Death count per Population

SELECT location, MAX(CAST(total_deaths as bigint)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC


--Till now we have been breaking things down by countries. Now let's do it with Continents

SELECT continent, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC


SELECT location, MAX(CAST(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC

--GLOBAL NuMBERS
SELECT date, SUM(new_cases) as total_cases1, SUM(CAST(new_deaths as bigint)) as total_deaths, SUM(CAST(new_deaths as bigint))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1



SELECT dea.location, dea.date, dea.population, dea.total_cases, dea.total_deaths, vac.location, vac.total_vaccinations, vac.date 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
ORDER BY 1,2


--SELECT SUM(new_cases) FROM PortfolioProject..CovidDeaths WHERE location like 'India' AND continent IS NOT NULL GROUP BY location

--Total Cases vs Total Vaccinations per country

SELECT dea.location, SUM(dea.new_cases) as total_cases, SUM(CONVERT(bigint, vac.new_vaccinations)) as total_vaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.location
ORDER BY 1


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE

WITH PopvsVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, RollingPeopleVaccinated/Population*100 FROM PopvsVac





--TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated --If you use TEMP Table a lot then its important to DROP TABLE. This is because if you try to update the table it will show error "table already exists".
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_Vaccinations numeric,
RollingPeopleVaccinated bigint
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT * FROM #PercentPopulationVaccinated ORDER BY 2,3


--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
