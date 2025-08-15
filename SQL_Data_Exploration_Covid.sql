SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3, 4;

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3, 4;

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--loking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--Looking at toatal cases vs population
--Looking what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%india%'
Group by Location, Population
order by PercentPopulationInfected DESC

--showing countreis with higest death count per population

Select location, Max (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
Group by Location
order by TotalDeathCount DESC

--lets break things down by continent

Select location, Max (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is null
Group by location
order by TotalDeathCount DESC

--showing contintents with the highest death count per population

Select continent, Max (cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by TotalDeathCount DESC

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group BY date
order by 1,2 

 
--Looking at total Population vs vaccinations

Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2, 3 

--Use CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations 

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3 
