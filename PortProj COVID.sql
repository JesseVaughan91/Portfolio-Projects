#Looking at total cases vs total deaths -> Death Percentage
#Shows the percent of people that got covid that passed away

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as 'Death Percentage'
FROM coviddeaths
WHERE Location LIKE 'United States'
ORDER BY total_cases;

#Looking at Total Cases vs population
#Shows what percentage of population got covid

SELECT Location, date, total_cases, population, (total_cases / population) * 100 as 'Cases per population'
FROM coviddeaths
WHERE Location LIKE 'United States'
ORDER BY total_cases;

#Showing countries with highest death count per population
#can create view here

SELECT Location, Population, MAX(total_cases) as 'Highest Infection Count', MAX(total_cases/population) *100 as 'Percent Population Infected'
FROM coviddeaths
GROUP BY Location, population
ORDER BY 'Percent Population Infected' DESC;

#Showing countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS UNSIGNED)) as 'Total Death Count'
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY MAX(CAST(total_deaths AS UNSIGNED)) DESC;

#Lets break things down by continent

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) as 'Total Death Count'
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX(CAST(total_deaths AS UNSIGNED)) DESC;

#Global Numbers of total deaths and death percentages

SELECT date, SUM(new_cases) as 'Total Cases', SUM(CAST(new_deaths AS UNSIGNED)) as 'Total Deaths',
SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases)*100 as 'Death Percentage'
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY SUM(new_cases);

#Shows a rolling count of vaccines by country and date
#also shows the percent of the population that is vaccinated

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as 'Rolling Vacc. Count'
FROM coviddeaths as d JOIN covidvaccinations as v
ON d.location = v.location
and d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location;

#Common Table Expression (CTE) This format allows us to make additional calculations to the query
#Shows a rolling count of vaccines by country and date
#also shows the percent of the population that is vaccinated

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccCount)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as 'Rolling Vacc. Count'
FROM coviddeaths as d JOIN covidvaccinations as v
ON d.location = v.location
and d.date = v.date
WHERE d.continent IS NOT NULL
#ORDER BY d.location;
)
SELECT *, (RollingVaccCount / Population) * 100
FROM PopvsVac
WHERE location LIKE "%States%";


#Creating view to store data for later visualizations
#Shows the vaccines compared to the population as a rolling count, adding up number
#of vaccines each day

CREATE VIEW PercentPopVacc as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as 'Rolling Vacc. Count'
FROM coviddeaths as d JOIN covidvaccinations as v
ON d.location = v.location
and d.date = v.date
WHERE d.continent IS NOT NULL;
#ORDER BY d.location;

#Creating a view to use for later visualizations
#The output shows the percent of a countries population that was infected

CREATE VIEW PopulationInfection as
SELECT Location, Population, MAX(total_cases) as 'Highest Infection Count', MAX(total_cases/population) *100 as 'Percent Population Infected'
FROM coviddeaths
GROUP BY Location, population
ORDER BY 'Percent Population Infected' DESC;






