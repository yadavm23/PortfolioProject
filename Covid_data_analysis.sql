Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases,new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs. total deaths
-- Shows the likelyhood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at total cases vs. the population
-- Shows what percentage of the population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at countries with Highest infection rate vs. population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Let's break things down by continent
-- Showing the continents with the highest death counts
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers


Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date 
order by 1,2

--Looking at total population vs. vaccinations
--USE CTE
With PopvsVac(Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population) * 100
 From PortfolioProject..CovidDeaths dea
  Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --Order by 1,2,3
  )

  Select *, (RollingPeopleVaccinated/Population)*100
  From PopvsVac

  --Temp Table
  Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

  Insert into #PercentPopulationVaccinated
  Select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population) * 100
 From PortfolioProject..CovidDeaths dea
  Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  --where dea.continent is not null
  --Order by 1,2,3

  Select *, (RollingPeopleVaccinated/Population)*100
  From #PercentPopulationVaccinated

  --Creating view to store data for later visulaizations

  Create View PercentPopulationVaccinated as 
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , Sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population) * 100
 From PortfolioProject..CovidDeaths dea
  Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --Order by 2,3

  Select * 
  From PercentPopulationVaccinated
