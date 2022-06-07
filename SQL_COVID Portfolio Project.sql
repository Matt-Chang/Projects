
Select *
From PortfolioProject..coviddeath$ 
Where continent is not null 
order by 3,4


-- Select Data to start with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeath$ 
Where continent is not null 
order by 1,2

-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..coviddeath$ 
Where location like '%aiwa%'
and continent is not null 
order by 2

-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$ 
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$ 
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



---SHOWING Courtesies with Highest Death COunt per population 

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeath$
Where continent is not null 
Group by Location 
Order by TotalDeathCount desc

---Let's break things down by contnient 
-- Showing contintents with the highest death count per population

Select continent , Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeath$
Where continent is not null 
Group by continent 
Order by TotalDeathCount desc

--Global numbers

Select date, Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_deaths,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
   From PortfolioProject ..coviddeath$ 
   Where continent is not null 
   Group by date
   order by 1,2

   -- looking at total population vs vaccination 
   -- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
  Join PortfolioProject..covidvaccination$  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


   --Use ICT 

   with PopvsVac(continent, location, Date, population,New_Vaccinations, RollingPeopleVaccinated)
   as
   (

   Select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations 
   ,Sum (cast(vac.new_vaccinations as bigint)) over (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated

   From PortfolioProject..coviddeath$ dea 
   join PortfolioProject..covidvaccination$ vac
		on dea.location = vac.location 
		and dea.date = vac.date 
Where dea.continent is not null
		)

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated
From PopvsVac 

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

   From PortfolioProject..coviddeath$ dea 
   join PortfolioProject..covidvaccination$ vac
		on dea.location = vac.location 
		and dea.date = vac.date 
--Where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 


-- Creating View to store data for visualizations



Create View PercentPopulationVaccinated
as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeath$  dea
Join PortfolioProject..covidvaccination$  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * 
From PercentPopulationVaccinated


----------------------------------------------------------------


/*
Queries used for Tableau Project
*/


-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..coviddeath$ 
where continent is not null 
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeath$ 
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$ 
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$ 
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



