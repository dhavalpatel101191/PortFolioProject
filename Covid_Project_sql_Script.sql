select * from dbo.Covid_Death
order by 3,4;

select * from dbo.Covid_Vaccination
order by 3,4;

--Selection of particular columns
select Location,Record_date,total_cases,new_cases,total_deaths 
from dbo.Covid_Death
order by 1,2;

--Looking for Total Case vs Total Deaths
select Location,Record_date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentages 
from dbo.Covid_Death
order by 1,2;

-- Looking Death % with condition
--Looking for Total Case vs Total Deaths
select Location,Record_date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentages 
from dbo.Covid_Death
where location = 'India'
order by 1,2;

--Get total case for particular country
select Location,sum(total_cases) as Total_Cases
from dbo.Covid_Death
group by location
having location = 'India';

select Location,sum(total_cases) as Total_Cases
from dbo.Covid_Death
group by location
order by Total_Cases desc;

--Total Case vs Population
--show percentage of poplulation infected
select Location,Record_date,total_cases,(total_cases/Population)*100 as PopulationInfected,Population
from dbo.Covid_Death
where location = 'India'
order by 1,2;

--Highest case in Countries compared to pupulation
select Location,Population,max(total_cases) as Highest_Infection_Count,Max(total_cases/Population)*100 as PercentageInfected
from dbo.Covid_Death
group by location, population
order by PercentageInfected desc;

--How Many people Died in Country..Highest Death Rate
select Location,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.Covid_Death
where continent is not null
group by location
order by TotalDeathCount desc;

--Break by continent
select location,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.Covid_Death
where continent is null
group by location
order by TotalDeathCount desc;

--Date on which has highest cases,deaths
select Record_Date,sum(new_cases) as TotalNewCase,sum(cast(total_deaths as int)) as TotalDeath
from dbo.Covid_Death
where Location = 'India'
group by Record_Date;

--Join two table
select top 5 * from
dbo.Covid_Death as de
join dbo.Covid_Vaccination as vc
on de.Record_Date = vc.Record_Date
and de.location = vc.location;

--Looking for Total Population vs Vaccination
select de.continent,de.location,de.Record_Date,de.population,vc.new_vaccinations
from dbo.Covid_Death de
join dbo.Covid_Vaccination as vc
on de.Record_Date = vc.Record_Date
and de.location = vc.location
where de.continent is not null
order by 1,2;

-- Total Population vs Total Vaccination
select de.continent, de.location, de.Record_Date, de.population,
vc.new_vaccinations,SUM(convert(bigint,vc.new_vaccinations)) over (partition by de.location order by de.location,de.record_date) as NoOfPeopleVaccinated
from dbo.Covid_Death de
join dbo.Covid_Vaccination as vc
   on de.location = vc.location
   and de.Record_Date = vc.Record_Date
where de.continent is not Null
order by 2,3;

--with CTE
with PopvsVac (continent,location,Record_Date,population,new_vaccinations,NoOfPeopleVaccinated) as
(
select de.continent, de.location, de.Record_Date, de.population,
vc.new_vaccinations,SUM(convert(bigint,vc.new_vaccinations)) over (partition by de.location order by de.location,de.record_date) as NoOfPeopleVaccinated
from dbo.Covid_Death de
join dbo.Covid_Vaccination as vc
   on de.location = vc.location
   and de.Record_Date = vc.Record_Date
where de.continent is not Null

)
select *,(NoOfPeopleVaccinated/population)*100 as PercentagePeopleVaccinated from PopvsVac
;

--Creating View for store data for Later
create view PercentagePopluationVaccinated as
select de.continent, de.location, de.Record_Date, de.population,
vc.new_vaccinations,SUM(convert(bigint,vc.new_vaccinations)) over (partition by de.location order by de.location,de.record_date) as NoOfPeopleVaccinated
from dbo.Covid_Death de
join dbo.Covid_Vaccination as vc
   on de.location = vc.location
   and de.Record_Date = vc.Record_Date
where de.continent is not Null;


-- Data Query for TableAu
--1

Select Sum(new_cases) as Total_Cases, Sum(convert(int,new_deaths)) as Total_Deaths, (sum(convert(int,new_deaths))/Sum(new_cases))*100 as Death_Percentages
from dbo.Covid_Death
where continent is not null
order by 1,2;


--2
Select location,sum(convert(int,new_deaths)) as Total_Death_Count
from dbo.Covid_Death
where continent is null
AND location not in ('World','European Union','International')
group by location
 order by Total_Death_Count desc;

 --3
 select Location,Population,Max(total_cases) as Highest_Infected_Count,Max((total_cases/population))*100 as Percent_Population_Infected
 from dbo.Covid_Death
 group by location,population
 order by Percent_Population_Infected desc;

 --4
 select location,population,Record_Date,Max(total_cases) as Highest_Infected_Count, Max((total_cases/population))*100 as Percent_Poplulation_Infected
 from dbo.Covid_Death
 group by location,population,Record_Date
 order by Percent_Poplulation_Infected;