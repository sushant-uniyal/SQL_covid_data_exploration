Select *
from PortfolioProject1..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject1..CovidVaccinations
--order by 3,4

--Select the Data

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by 1,2

--looking at Total Cases vs Total Deaths 
--likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where Location='India'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population,  (total_cases/population)*100 as CasesPercentage
from PortfolioProject1..CovidDeaths
--where Location='India'
order by 1,2

--Looking at Countries with highest infection rates compared to population

Select Location,  population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as CasesPercentage
from PortfolioProject1..CovidDeaths
--where Location='India'
group by location, Population
order by CasesPercentage desc

--Showing countries with highest deathcount 

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null and total_deaths is not null
group by location
order by TotalDeathCount desc

--Showing total death count by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--Showing the death pecentage by date around the world

Select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death,
Sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is not null
Group by date
Order by DeathPercentage desc

--Total number of cases deaths and deathpercentage

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death,
Sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is not null
--Group by date
Order by DeathPercentage desc

--- Joininng table CovidDeaths and CovidVaccination
Select*
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidDeaths vac
	on dea.location=vac.location
	and dea.date=vac.date

-- Looking at total Population vs Vaccinations
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum (convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

 --Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum (convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercetangeRollingPeopleVacccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location  nvarchar(250),
Date datetime,
Populaton numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric

)



Insert into #PercentPopulationVaccinated
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum (convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select*, ((convert(bigint, RollingPeopleVaccinated))/Populaton)*100 as RollingPeopleVacc_per_population 
From #PercentPopulationVaccinated

--Creating views for the later visualizations

Create View  PercentPopulationVaccinated as
(Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum (convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null)
--order by 2,3





