--select * from PortfolioProject1..CovidDeaths
--order by 3, 4

--select * from PortfolioProject1..CovidVaccinations
--order by 3, 4

-----SELECTING DATA TO BE USED FOR THE PROJECT--------

select location,date,total_cases, new_cases, total_deaths, population from PortfolioProject1..CovidDeaths
order by 1,2 


-----LOOKING AT TOTAL CASES VS TOTAL DEATHS-------
select location, date, total_cases, total_deaths, 
case 
	when total_cases>0 then (total_deaths/total_cases)*100 
	else 0
end as DeathPercentage 
from PortfolioProject1..CovidDeaths
order by 1,2 


---- LOOKING AT THE TOTAL CASES VS POPULATION 

select location, date, total_cases, population,
case 
	when total_cases>0 then (total_cases/population)*100 
	else 0
end as CasesPercentage
from PortfolioProject1..CovidDeaths

---- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATES ---------
select location, population, MAX(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PecentPopualtionInfected

from PortfolioProject1..CovidDeaths
group by location, population 
order by 4 desc


----- LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT------
select location, population, MAX(total_deaths) as HighestdeathCount, max(total_deaths/population)*100 as PecentPopualtionDead

from PortfolioProject1..CovidDeaths
where continent is not null
group by location, population 
order by 4 desc

---- LOOKING AT THE DEATHS BY CONTINENT -----------
select location, MAX(total_deaths) as HighestDeathCount

from PortfolioProject1..CovidDeaths
where continent is null
group by location
ORDER BY 2 DESC


---- GLOBAL NUMBERS -------
SELECT date,   SUM(new_cases) AS TotalCases,  SUM(new_deaths) AS total_deaths,   
   
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0
        ELSE (SUM(new_deaths) / SUM(new_cases) * 100)
    END AS DeathPercent
FROM 
    PortfolioProject1..CovidDeaths
WHERE 
    continent IS NOT NULL
group by date
ORDER BY 1,2

-----LOOKING AT POPULATION WHO RECEIVED VACCINES-----


Select death.continent,death.location, death.date, death.population, vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated 
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
	where death.continent is not null
order by 2,3
		


----- CREATING A TEMP TABLE ------ 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar (250),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select death.continent,death.location, death.date, death.population, vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated 
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
	where death.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PerentPopulationVaccinated 
from #PercentPopulationVaccinated


------- CREATING VIEW-------

create view PercentPopulationVaccinated as

Select death.continent,death.location, death.date, death.population, vaccine.new_vaccinations, 
sum(cast(vaccine.new_vaccinations as bigint)) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated 
from PortfolioProject1..CovidDeaths death
join PortfolioProject1..CovidVaccinations vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
	where death.continent is not null
 --order by 2,3

 select * from PercentPopulationVaccinated


