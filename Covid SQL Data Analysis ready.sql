show databases;
use portfolio_project;
create table covid_deaths
show tables;

select * from covidvaccinations limit 10;
truncate covid_deaths
select count(*) from covidvaccinations where iso_code = 'USA';
rename table covid_vaccinations to CovidVaccinations;

show variables like 'secure_file_priv'

select count(*) from coviddeaths
select * from covidvaccinations limit 1000;

select * 
from coviddeaths
order by 3,4

select * 
from covidvaccinations
order by 3,4

#Select the data we will be using
select Location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths
order by 1,2

#The datatypes are messed up coming into the table. I changed date to be date format and made sure all the columns past 4 were numerical
select count(*) from coviddeaths 

# Looking at total_cases versus total_death
#Shows the likelihood of dying if you get covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%states%'
order by 1,2

#Looking at total_cases versus population
#Shows percentage of getting COVID
select Location, date, total_cases, Population, (total_cases/population)*100 as DiseasePercentage
from coviddeaths
where location like '%states%'
order by 1,2

#Looking at countries with highest infection rate compared to population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases)/population)*100 as PercentagePopulationInfected
from coviddeaths
#where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

# Showing Countries with the highest death count per population
select Location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
where continent != ''
Group by location
order by TotalDeathCount desc


select * 
from coviddeaths
where location = 'Europe'		#Turns out if location is continent then continent is '' ********************************
order by 3,4


# LET'S BREAK THINGS DOWN BY CONTINENT
select continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths
where continent != ''
Group by continent
order by TotalDeathCount desc

select location, MAX(total_deaths) as TotalDeathCount  ## *********** correct I think
from coviddeaths
where continent = ''   # filter on the continent breakdown
Group by location
order by TotalDeathCount desc

### Showing the Continents with the Highest Death Count
select continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths
where continent != ''
Group by continent
order by TotalDeathCount desc

## GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
where continent != ''
group by date			#Total new_cases in world, not filtering by location or continent
order by 1,2

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from coviddeaths
where continent != ''
#group by date			#Total death rate globally    ******
order by 1,2


## looking at total population versus vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent != ''
#and dea.location = 'United States'
order by 2, 3 
#limit 20000

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 				#Rolling People Vaccinated by Country
and dea.date = vac.date
where dea.continent != ''
and dea.location = 'United States'
order by 2, 3
limit 20000

#USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location 
and dea.date = vac.date				#Since PercentPopulationVaccinated exceeds population these are not unique people vaccinated, many more than once
where dea.continent != ''
	and dea.location = 'United States'
#order by 2, 3
)
Select *, (RollingPeopleVaccinated/population)*100. as PercentPopulationVaccinated
from PopvsVac


## TEMP TABLE
Drop Table if exists PercentPeopleVaccinated
Create TEMPORARY Table PercentPeopleVaccinated
(
	continent 	text,
    location 	text,
    date 		datetime,
    population 	bigint,
    new_vaccination	bigint,
    RollingPeopleVaccinated bigint
)

Insert into PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date				#Since PercentPopulationVaccinated exceeds population these are not unique people vaccinated, many more than once
where dea.continent != ''
#	and dea.location = 'United States'
#order by 2, 3
    
Select *, (RollingPeopleVaccinated/population)*100 as RollingPercentVaccinated
from PercentPeopleVaccinated 


## CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
Create View PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date				#Since PercentPopulationVaccinated exceeds population these are not unique people vaccinated, many more than once
where dea.continent != ''percentpeoplevaccinated

select *
FROM  PercentPeopleVaccinated 
LIMIT 50