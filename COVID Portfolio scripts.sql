select * 
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

--select data that we are going to be using ordered by tje
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total_cases vs Total_deaths
--Shows likelihood of death by infection in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--total cases vs population shown as percentage
select Location, date, population, total_cases,  (total_cases/population) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



--looking at countries with highest infection rate compared to pop
select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by Location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per pop (Continent and location data crossed)
select Location, MAX(cast(total_deaths as int) ) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not NULL
group by Location
order by TotalDeaths desc


--BROKEN BY CONTINENT
select continent, MAX(cast(total_deaths as int) ) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by TotalDeaths desc


--showing the continents with highest deathcount per pop
select continent, MAX(cast(total_deaths as int) ) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by TotalDeaths desc


--global numbers- remove date formats to see total global %
select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) total_deaths, 
    sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


--Looking at total pop vs vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vacc
    on dea.location = vacc.location
    and dea.date = vacc.date
where dea.continent is not null
order by 2, 3


--setting up a script tp show data bases on location entroes and sorted by location
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
    sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea

join PortfolioProject..CovidVaccinations vacc
    on dea.location = vacc.location
    and dea.date = vacc.date

where dea.continent is not null
order by 2, 3


-- adding AND order by date, adding column to rollingcount, adding column name for readability
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
    sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location
    order by dea.location,dea.date) as DailyTotalVacc



from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vacc
    on dea.location = vacc.location
    and dea.date = vacc.date

where dea.continent is not null
order by 2, 3


--use CTE
--creating a view to use values created in last script
with PopvsVac (Continent, Location, Date, population, new_vaccinations, DailyTotalVacc)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
    sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location
    order by dea.location,dea.date) as DailyTotalVacc


from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vacc
    on dea.location = vacc.location
    and dea.date = vacc.date

where dea.continent is not null
--order by 2, 3
)
SELECT *, (DailyTotalVacc/population)*100
from PopvsVac



--temp table 
drop TABLE if EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date DATETIME,
    population numeric,
    new_vaccinations NUMERIC,
    dailytotalvacc NUMERIC
)


insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
    sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location
    order by dea.location,dea.date) as DailyTotalVacc



from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vacc
    on dea.location = vacc.location
    and dea.date = vacc.date

where dea.continent is not null
order by 2, 3

SELECT *, (dailytotalvacc/population) *100
    from #PercentPopulationVaccinated


--creating view to store data for visualization
    --showing as error due to create view must be ran
    --as a batch on its own(commented out because the error)

-- create VIEW PercentPopulationVaccinated as
-- SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
--     sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location
--     order by dea.location,dea.date) as DailyTotalVacc


-- from PortfolioProject..CovidDeaths dea
-- join PortfolioProject..CovidVaccinations vacc
--     on dea.location = vacc.location
--     and dea.date = vacc.date

-- where dea.continent is not null
-- --order by 2, 3

-- select *
--     from PercentPopulationVaccinated