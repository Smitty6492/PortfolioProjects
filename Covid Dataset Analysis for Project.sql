-- This is the SQL code I wrote for a project I put together using COVID data that I took from the Our World in Data
-- website    https://ourworldindata.org/privacy-policy
-- I include joins, CTEs, temporary tables, and subqueries
-- I plan on making a dashboard to visualize this data using Tableau


select * 
from covidvacc
order by 3,4
;

select *
from coviddeaths
where continent is not null
order by 3,4
;
-- Select Data that we are using
Select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2
;


-- Looking at the Total Cases versus Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (cast(total_deaths as float) / total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%States%' and continent is not null
order by 1,2
;

-- Looking at the Total Cases versus the Population
-- Shows what percentage of population contracted COVID
Select location, date, total_cases, population, (cast(total_cases as float) / population)*100 as PercentPopulationInfected
from coviddeaths
where location like '%States%' and continent is not null
order by 1,2
;


-- Looking at countries with highest infection rate compared to population
Select location,  population, max(total_cases) as HighestInfectionCount,
	((cast(max(total_cases) as float) / population)*100) as PercentPopulationInfected
from coviddeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc
;


-- Showing the countries with the Highest Death Count per Population
Select location,  max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc
;

-- LET'S BREAK THINGS DOWN BY CONTINENT


Select location,  max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is null
group by location
order by TotalDeathCount desc
;


-- This is showing the continents with the highest death count perpopulation
Select continent,  max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc
;


--GLOBAL NUMBERS
-- Death percentage on each day
Select date, sum(new_cases) total_new_cases, sum(new_deaths) as total_new_deaths, cast(sum(new_deaths) as float)/sum(new_cases)*100. as DeathPercentage
from coviddeaths
where continent is not null and new_cases <> 0
group by date
order by 1,2
;
-- Death percentage in the world
Select sum(new_cases) total_new_cases, sum(new_deaths) as total_new_deaths, cast(sum(new_deaths) as float)/sum(new_cases)*100. as DeathPercentage
from coviddeaths
where continent is not null and new_cases <> 0
order by 1,2
;



select * 
from coviddeaths d
join covidvacc v
on d.location = v.location and d.date = v.date

-- Looking at Total Population vs. Vaccinations

select d.continent, d.location, d.date, d.population, 
	sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as Rolling_People_Vaccinated	
from coviddeaths d
join covidvacc v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3
;

-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as Rolling_People_Vaccinated	
from coviddeaths d
join covidvacc v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
	)
select *, (Rolling_People_vaccinated / population)*100
from PopvsVac


-- USE TEMP TABLE
Drop Table if exists PercentPopulationVaccinated
Create TEMP Table  PercentPopulationVaccinated as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
	sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as Rolling_People_Vaccinated	
from coviddeaths d
join covidvacc v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
)
;

select *, (Rolling_People_vaccinated / population)*100 as Percent_Vaccinated
from PercentPopulationVaccinated
;


-- Create View to Save for Later Visualizations 

Create View PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population, 
	sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as Rolling_People_Vaccinated	
from coviddeaths d
join covidvacc v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
;

select * 
from PercentPopulationVaccinated