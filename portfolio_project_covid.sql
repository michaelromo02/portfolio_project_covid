/* COVID 19 Data Exploration

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, & Converting Data Types

*/

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1, DATE_FORMAT(date, '00/00/00')

-- Total cases vs Total Deaths 
-- Shows likelihood of dying if you contract COVID in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
ORDER BY 1, DATE_FORMAT(date, '00/00/00')

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM covid_deaths
ORDER BY 1, DATE_FORMAT(date, '00/00/00')

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location, population 
ORDER BY percent_population_infected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS total_death_count
FROM covid_deaths 
GROUP BY location 
ORDER BY total_death_count DESC

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS total_death_count
FROM covid_deaths 
GROUP BY continent
ORDER BY total_death_count DESC

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS new_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage 
FROM covid_deaths
GROUP BY date
ORDER by DATE_FORMAT(date, '00/00/00'),2 

SELECT SUM(new_cases) AS new_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS new_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage 
FROM covid_deaths
ORDER by 1,2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location, DATE_FORMAT(dea.date, '00/00/00')) as rolling_people_vaccinated
FROM covid_deaths dea 
JOIN covid_vaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
ORDER BY 2, DATE_FORMAT(dea.date, '00/00/00')

-- Using CTE to perform Calculation on Partition By in previous query

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location, DATE_FORMAT(dea.date, '00/00/00')) as rolling_people_vaccinated
FROM covid_deaths dea 
JOIN covid_vaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
/* ORDER BY 2, DATE_FORMAT(dea.date, '00/00/00') */
)
SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_people_vaccinated_percentage
FROM pop_vs_vac

-- Creating View to store data for later visualizations

CREATE VIEW percent_population_vaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER(PARTITION BY dea.location ORDER BY dea.location, DATE_FORMAT(dea.date, '00/00/00')) as rolling_people_vaccinated
FROM covid_deaths dea 
JOIN covid_vaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date