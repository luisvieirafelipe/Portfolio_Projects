--Sobre os Dados: Dados mundiais compilados de casos, mortes e vacina��o contra a Covid-19.
-- Dados dispon�veis no link: https://ourworldindata.org/covid-deaths

Select location, date, total_cases, new_cases, total_deaths, population
From SQL_Projects..CovidDeaths$

-- Total de Casos vs Total de Mortes no Brasil
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
from SQL_Projects..CovidDeaths$
Where location like '%Brazil%'
order by 1,2

-- Total de Casos vs Popula��o no Brasil
select location, date, total_cases, population, (cast(total_cases as float)/population)*100 as CasesPercentage
from SQL_Projects..CovidDeaths$
Where location like '%Brazil%'
order by 1,2

-- Total de Casos vs Popula��o no Pa�s
select location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from SQL_Projects..CovidDeaths$
where continent is not null
order by 1,2

-- Pa�ses com a Maior taxa de Infec��o
select location, max(cast(total_cases as int)) as HighestInfectionCount, population, Max((cast(total_cases as int)/population))*100 as PercentInfected
from SQL_Projects..CovidDeaths$
where continent is not null
Group by population, location
order by PercentInfected desc

-- Pa�ses com a Maior n�mero de Mortes
select location, max(cast(total_deaths as int)) as DeathCount
from SQL_Projects..CovidDeaths$
where continent is not null
Group by location
order by DeathCount desc

--Pa�ses com a Maior Taxa de Mortes em rela��o � popula��o
select location, max(cast(total_deaths as int)) as HighestDeathCount, population, Max((cast(total_deaths as int)/population))*100 as PercentDeaths
from SQL_Projects..CovidDeaths$
where continent is not null
Group by population, location
order by PercentDeaths desc

--Continentes com maior n�mero de mortes
select continent, sum(cast(new_deaths as int)) as DeathCount
from SQL_Projects..CovidDeaths$
where continent is not null
Group by continent
order by DeathCount desc


-- Porcentagem de Mortes vs Casos de Covid no Mundo
select sum(cast(new_cases as int)) as Cases, sum(cast(new_deaths as int)) as Deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DeathPercentage
from SQL_Projects..CovidDeaths$
Where continent is not null 
--Group by date
order by 1,2

--Linha do Tempo da Vacina��o no Brasil
select Death.location, Death.continent, Death.date, cast(Death.population as bigint) as population, Vac.new_vaccinations
,sum(convert(real, Vac.new_vaccinations)) over (Partition by Death.location order by Death.location, Death.date)
as RollingPeopleVaccnated
from SQL_Projects..CovidDeaths$ Death
Join SQL_Projects..CovidVaccinations$ Vac
	on Death.location = Vac.location	
	and Death.date=Vac.date
where Death.continent is not null and Death.location like '%Brazil%'
order by 1,2,3


--CTE

With PopvsVac (Continent, Location, date, population, RollingPeopleVaccinated, new_vaccinations)
as 
(
select Death.continent, Death.location, Death.date, cast(Death.population as float), Vac.new_vaccinations
,sum(convert(real, Vac.new_vaccinations)) over (Partition by Death.location order by Death.location, Death.date)
as RollingPeopleVaccinated
from SQL_Projects..CovidDeaths$ Death
Join SQL_Projects..CovidVaccinations$ Vac
	on Death.location = Vac.location	
	and Death.date = Vac.date
where Death.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100 as VaccionationPercentage
From PopvsVac

-- Tabela Tempor�ria

Drop Table if exists  PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(250) ,
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into PercentPopulationVaccinated
select Death.continent, Death.location, Death.date, cast(Death.population as numeric), Vac.new_vaccinations
,sum(convert(real, Vac.new_vaccinations)) over (Partition by Death.location order by Death.location, Death.date)
as RollingPeopleVaccinated
from SQL_Projects..CovidDeaths$ Death
Join SQL_Projects..CovidVaccinations$ Vac
	on Death.location = Vac.location	
	and Death.date = Vac.date
where Death.continent is not null


select*, (RollingPeopleVaccinated/population)*100 as VaccionationPercentage
From PercentPopulationVaccinated


-- Armazenar dados para posterior utiliza��o
create view  PercentPopulationVaccinatedView1 as
select Death.continent, Death.location, Death.date, cast(Death.population as numeric) as Population, Vac.new_vaccinations
,sum(convert(real, Vac.new_vaccinations)) over (Partition by Death.location order by Death.location, Death.date)
as RollingPeopleVaccinated
from SQL_Projects..CovidDeaths$ Death
Join SQL_Projects..CovidVaccinations$ Vac
	on Death.location = Vac.location	
	and Death.date = Vac.date
where Death.continent is not null