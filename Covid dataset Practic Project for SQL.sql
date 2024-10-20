--Choose Database
use PortfolioProject;

select *
From CovidDeaths
Where continent is null
ORDER BY 3,4;

--select *
--From CovidVaccinations
--ORDER BY 3,4;

--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
ORDER BY total_cases desc, DeathPercentage desc;

-- Looking at Total Cases vs Populatoin
-- Show what percentage of population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From CovidDeaths
Where location like '%thai%'
ORDER BY total_cases desc, InfectionPercentage desc;

-- Looking at Countries with highest Infection Rate Compared to Population
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as InfectionPercentage
From CovidDeaths
-- Where location like '%thai%'
Group by location, population
ORDER BY InfectionPercentage desc;

-- There are continent mixed in the location which I do not want it
-- I will only keep the country. So, I changed the queries as below

-- Looking at Countries with highest Infection Rate Compared to Population (Deleted Continent)
select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as InfectionPercentage
From CovidDeaths
Where continent is not null
Group by location, population
ORDER BY InfectionPercentage desc;

-- Showing Countries with Highest Death Count per Population (Deleted Continent)
select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by location
ORDER BY TotalDeathCount desc;

-- Showing continents with the highest death count
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
ORDER BY TotalDeathCount desc;

-- Golbal Numbers
select date, Sum(new_cases) as NewTotal_Cases, Sum(cast(new_deaths as int)) as NewTotal_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
From CovidDeaths
Where continent is not null
Group by date
ORDER BY 1,2;

-- Looking at Total Population vs Vaccinations

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, AccumulatedPeopleVaccinated)
as
(
-- Use CTE
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccumulatedPeopleVaccinated
	-- AccumulatedPeopleVaccinated/population)*100 >> Must use CTE in order to run this query
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (AccumulatedPeopleVaccinated/population)*100 -- AccumulatedPeopleVaccinated/population)*100 >> Must use CTE in order to run this query
From PopvsVac
-- order by 2,3





-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AccumulatedPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccumulatedPeopleVaccinated
	-- AccumulatedPeopleVaccinated/population)*100 >> Must use CTE in order to run this query
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (AccumulatedPeopleVaccinated/population)*100 -- AccumulatedPeopleVaccinated/population)*100 >> Must use CTE in order to run this query
From #PercentPopulationVaccinated

-- Creating View to Store data for later visualizations
Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccumulatedPeopleVaccinated
	-- AccumulatedPeopleVaccinated/population)*100 >> Must use CTE in order to run this query
FROM CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- SELECT from View that I just created
SELECT *
FROM PercentagePopulationVaccinated



