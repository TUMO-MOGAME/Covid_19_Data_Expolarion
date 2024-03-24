/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select count(1) from coviddeaths; /*85171*/
select count(1) from covidvaccination;

select * from coviddeaths;
select * from covidvaccination;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

## looking at Total cases vs Total deaths 

select location, date, total_cases, new_cases, total_deaths, concat(round((total_deaths/total_cases)*100,2),'%')  as DeathPercertage
from coviddeaths
where location = 'south africa'
order by 1,2;

## total cases by polulation
select location, date, population, total_cases, new_cases, concat(round((total_cases/population)*100,2),'%')  as Percertage_of_cases_Per_population
from coviddeaths
where location = 'south africa'
order by 1,2;

select location, population, max(total_cases) as highestInfectionCount,  concat(round(max((total_cases/population)*100),2),'%') Percertage_of_cases_Per_population
from coviddeaths
group by location, population
order by Percertage_of_cases_Per_population desc;

select location, population, max(total_cases) as highestInfectionCount,  concat(round(max((total_cases/population)*100),2),'%') Percertage_of_cases_Per_population
from coviddeaths
group by location, population
having location = 'south africa'
order by Percertage_of_cases_Per_population desc;

## showing countries with highest death count per population

select location, population, max(total_deaths) as Max_Death, concat(max((round(((total_deaths/population)*100),2))),'%') as percentage_of_max_deaths_per_population
from coviddeaths
group by location, population
order by Max_Death desc;

select location, population, max(total_deaths) as Max_Death, concat(max((round(((total_deaths/population)*100),2))),'%') as percentage_of_max_deaths_per_population
from coviddeaths
group by location, population
having location = 'south africa'
order by Max_Death desc;


-- BREAKING THINGS DOWN BY CONTINENT

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, 
	   dea.date, dea.population, 
       vac.new_vaccinations, 
	   SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac as(
					Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
					, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
					From CovidDeaths dea
					Join covidvaccination vac
						On dea.location = vac.location
						and dea.date = vac.date
					where dea.continent is not null 
					order by 2,3
					)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From CovidDeaths dea
Join covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;


select * from PercentPopulationVaccinated