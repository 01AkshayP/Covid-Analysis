SELECT *
FROM ..CovidDeaths
ORDER BY 2,3
 
SELECT *
FROM ..CovidVaccinations
ORDER BY 2,3

 
Select cd.[location], cd.[date], cd.total_cases, cd.new_cases, cd.total_deaths, cd.population
FROM ..CovidDeaths cd
ORDER BY 1,2

-- Total Cases vs. Total Deaths
Select cd.[location], cd.[date], cd.total_cases, cd.total_deaths, (cd.total_deaths * 100.0)/cd.total_cases AS DeathPercentage
FROM ..CovidDeaths cd
ORDER BY 1,2

-- Looking at Death Percentage of U.S. Specifically
Select cd.[location], cd.[date], cd.total_cases, cd.total_deaths, (cd.total_deaths * 100.0)/cd.total_cases AS DeathPercentage
FROM ..CovidDeaths cd
WHERE location like '%States'
ORDER BY 1,2
-- The Death Percentage in the United States started off high due to the limited number of total cases reported. Around April of 2020, the Percentage of deaths from individuals with Covid was at its highest with around a 6.28 and began to slowly decline around the start of May in 2020.
-- As of August of 2022, the Death Percentage of individuals with Covid is about a 1.11 Percent. An individual that contracted COVID 19 today has about a 1.11 percent chance that they could die from it.


-- Total Cases vs. Population
Select cd.[location], cd.[date], cd.population,  cd.total_cases, (cd.total_cases * 100.0)/cd.population AS InfectedPopulation
FROM ..CovidDeaths cd
WHERE location like '%States'
ORDER BY 1,2
-- As of August of 2022, about 27.79 percent of the population has reported having Covid



--Countries with highest Infection Rate compared to Population
Select cd.[location], cd.population, date,  MAX(cd.total_cases) AS HighestInfectionCount, MAX((cd.total_cases * 100.0)/cd.population) AS InfectedPopulation
FROM ..CovidDeaths cd
GROUP BY cd.[location], cd.population, [date]
ORDER BY InfectedPopulation DESC
-- Many small countries such as Faeroe Islands and Cuprus have the highest Infection Population at more than 60 Percent, but there are larger countries such as Portugal and France, which is populated by tens of millions, and the countries have an Infection Percent at around 50 percent.
-- The United States has about a 27 percent of the population reported to have been Infected, and is the 56th Country with the highest percentage of population infected by the Virus.


-- Countries With Highest Death Count per Population
Select cd.[location],  MAX(cd.total_deaths) AS TotalDeathCount
FROM ..CovidDeaths cd
WHERE continent is not null
GROUP BY cd.[location]
ORDER BY TotalDeathCount DESC
-- The United States has the highest death count in the world. Could show how United States did not take proper precuations during the start of the pandemic, or how there was a larger spread of the virus in the country, 
-- as it has a large population and also had a high percent of Population Infected.


-- Continent With Highest Death Count
Select cd.[location],  MAX(cd.total_deaths) AS TotalDeathCount
FROM ..CovidDeaths cd
WHERE continent is null and iso_code NOT IN ('OWID_LIC', 'OWID_HIC','OWID_LMC','OWID_UMC' ) and [location] not in ('World', 'European Union', 'International')
GROUP BY cd.[location]
ORDER BY TotalDeathCount DESC


---- Total Cases vs. Total Deaths GLOBALLY for every day
Select cd.[date], SUM(cd.new_cases) as total_cases, SUM(cd.new_deaths) as total_deaths, (SUM(cd.new_deaths) * 100.0)/SUM(cd.new_cases) AS DeathPercentage
FROM ..CovidDeaths cd
WHERE continent is not null
GROUP BY [date]
ORDER BY 1,2

Select  SUM(cd.new_cases) as total_cases, SUM(cd.new_deaths) as total_deaths, (SUM(cd.new_deaths) * 100.0)/SUM(cd.new_cases) AS DeathPercentage
FROM ..CovidDeaths cd
WHERE continent is not null
ORDER BY 1,2
--Overall, accross the world, roughly 1.08 percent of the population that had covid resulted in deaths. This is about 6.4 million people that lost their lives after reporting they had Covid.


-- Joining the Covid Deaths and Covid Vaccination Tables
SELECT *
FROM ..CovidDeaths cd
JOIN ..CovidVaccinations cv
    ON cd.[date] = cv.[date]
    and cd.[location] = cv.[location]


-- Total Population vs. Vaccinations
SELECT cd.[continent], cd.[location], cd.[date], cd.population, cv.new_vaccinations
FROM ..CovidDeaths cd
JOIN ..CovidVaccinations cv
    ON cd.[date] = cv.[date]
    and cd.[location] = cv.[location]
WHERE cd.continent is not NULL --and cd.[location] like '%States'
ORDER BY 2,3


SELECT cd.[continent], cd.[location], cd.[date], cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.LOCATION ORDER BY cd.location, cd.date) AS rolling_vaccinations
FROM ..CovidDeaths cd
JOIN ..CovidVaccinations cv
    ON cd.[location] = cv.[location]
    and cd.[date] = cv.[date]
WHERE cd.continent is not NULL
ORDER BY 2,3


-- Rolling Count of Percent of Population that is vaccinated
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccinations)
as
(
SELECT cd.[continent], cd.[location], cd.[date], cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.LOCATION ORDER BY cd.location, cd.date) AS rolling_vaccinations
FROM ..CovidDeaths cd
JOIN ..CovidVaccinations cv
    ON cd.[location] = cv.[location]
    and cd.[date] = cv.[date]
WHERE cd.continent is not NULL

)
SELECT *, (rolling_vaccinations * 100.0/Population) As VaccinationPercentage
FROM PopvsVac

-- Percentage of population Hospitalized
Select cd.[location], cd.[date], cd.total_cases, cd.hosp_patients, (cd.hosp_patients * 100.0)/cd.total_cases AS HospitalizedPercentage
FROM ..CovidDeaths cd
Where hosp_patients is not null
ORDER BY 1,2
-- The COVID Pandemic showed how unexpected situations can cause panic and need of medical assistance. The data gathered from COVID can be used to help establish how much/many recourses and medical expertise may be needed in future Pandemics


-- Countries with highest Death Count vs. Number of Patients Hospitalized
Select cd.[location], MAX(cd.total_deaths) AS TotalDeathCount, MAX(cd.hosp_patients) AS TotalHospitalized
FROM ..CovidDeaths cd
WHERE continent is not null
GROUP BY cd.[location]
ORDER BY TotalDeathCount DESC
-- United States had the highest Death Count, but also had the highest Hospitalized Count. Could help show how the country was able to quickly adjust and help as many individuals as they could.


-- Creating Views to Store Data for Visualizations

-- -- Total Cases vs. Total Deaths
-- Create VIEW TotalCasesVsTotalDeaths as
-- Select cd.[location], cd.[date], cd.total_cases, cd.total_deaths, (cd.total_deaths * 100.0)/cd.total_cases AS DeathPercentage
-- FROM ..CovidDeaths cd

-- -- Looking at Death Percentage of U.S. Specifically
-- Create View USDeathPercentage as
-- Select cd.[location], cd.[date], cd.total_cases, cd.total_deaths, (cd.total_deaths * 100.0)/cd.total_cases AS DeathPercentage
-- FROM ..CovidDeaths cd
-- WHERE location like '%States'


-- -- Total Cases vs. Population
-- Create View TotalCasesVsPopulation as
-- Select cd.[location], cd.[date], cd.population,  cd.total_cases, (cd.total_cases * 100.0)/cd.population AS InfectedPopulation
-- FROM ..CovidDeaths cd

-- -- Total Cases vs. Population for US Specifically
-- Create View USTotalCasesVsPopulation as
-- Select cd.[location], cd.[date], cd.population,  cd.total_cases, (cd.total_cases * 100.0)/cd.population AS InfectedPopulation
-- FROM ..CovidDeaths cd
-- WHERE location like '%States'

