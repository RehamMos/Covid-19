use [Covid Project]
-- select all columns/data from CovidVaccinations order by column location and date
select * from CovidVaccinations order by 3,4;

-- select all columns/data from CovidDeaths order by column location and date
select * from CovidDeaths order by 3,4;

-- select location, date, total cases, total death, new cases,population from CovidDeaths order by column location and date
select [location],[date],total_cases,new_cases,total_deaths,[population] 
from CovidDeaths 
order by 1,2;

/* select location, date, total cases, total death and calculate Death Percentage and replace null values with zero
from CovidDeaths order by column location and date*/
select [location],[date],total_cases,total_deaths, isnull((total_deaths/total_cases),0) *100 as 'Death Percentage'
from CovidDeaths 
order by 1,2;

/* select location, date, total cases, total death and calculate Death Percentage and replace null values with zero
from CovidDeaths with condition location contains states order by column location and date*/
select [location],[date],total_cases,total_deaths, isnull((total_deaths/total_cases),0) *100 as 'Death Percentage'
from CovidDeaths 
where location like '%states%'
order by 1,2; 

/* select location, date, total cases, population and calculate Infected Percentage and replace null values with zero
from CovidDeaths with condition location contains states order by column location and date*/
select [location],[date],total_cases,population, isnull((total_cases/population),0) *100 as 'Infected Percentage'
from CovidDeaths 
where location like '%states%'
order by 1,2;

/* select location, date, total cases, population and calculate Infected Percentage and replace null values with zero
from CovidDeaths order by column location and date*/
select [location],[date],total_cases,population, isnull((total_cases/population),0) *100 as 'Infected Percentage'
from CovidDeaths 
--where location like '%states%'
order by 1,2;

/* select location, population, max of total cases and calculate max Infected Percentage and replace null values with zero
from CovidDeaths group by location, population order by column location and date*/
select [location], population,max(total_cases)as 'Max total cases', max(isnull((total_cases/population),0) *100 )as 'Infected Percentage'
from CovidDeaths 
--where location like '%states%'
group by [location],population
order by 1,2;

/* select location, population, max of total cases and calculate max Infected Percentage and replace null values with zero
from CovidDeaths group by location, population order by column Infected Percentage descinding*/
select [location], population,max(total_cases)as 'Max cases', max(isnull((total_cases/population),0) *100 )as 'Infected Percentage'
from CovidDeaths 
--where location like '%states%'
group by [location],population
order by 'Infected Percentage' desc;

/* select location, population, max of total cases and calculate max Infected Percentage and replace null values with zero
from CovidDeaths group by location, population order by column Infected Percentage descinding*/
select [location], max(cast(total_deaths as int))as 'Max death'  -- cast to change data type of total death
from CovidDeaths 
--where location like '%states%'
where continent is not null
group by [location]
order by 'Max death' desc; 

-- select all data from CovidDeaths with condition continent is not null order by location and date
select * from CovidDeaths where continent is not null
order by 3,4;

/*select continent, max total death from CovidDeaths with condition continent is not null group by continent order by Max death*/
select continent, max(cast(total_deaths as int))as 'Max death'
from CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent
order by 'Max death' desc; 

/*select date, total cases, total death, death_percentage from CovidDeaths with condition continent is not null 
order by date, total cases*/
select date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from CovidDeaths 
--where location like '%states%'
where continent is not null
order by 1,2;

/*select date, total new cases, total new deaths, New Death Percentage from CovidDeaths with condition continent is not null 
group by date order by date, total new cases*/
select date, sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as 'New Deaths',
sum(cast(new_deaths as int))/sum(new_cases)*100 as 'New Death Percentage'--, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from CovidDeaths 
--where location like '%states%'
where continent is not null
group by date
order by 1,2;

/*select total new cases, total new deaths, Death Percentage from CovidDeaths with condition continent is not null 
order by total new cases, total new deaths*/
select sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as 'New Deaths',
sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Death Percentage'--, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from CovidDeaths 
--where location like '%states%'
where continent is not null
--group by date
order by 1,2;

/*select continent, location, date, population, new_vaccinations from CovidDeaths and CovidVaccinations 
with condition continent is not null  order by location, date*/
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,
CovidVaccinations.new_vaccinations,
sum(convert(int,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date )  as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/CovidDeaths.population)*100
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3; 

/*create temporary table PopvsVac*/

with PopvsVac(continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,
CovidVaccinations.new_vaccinations,
sum(convert(int,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date )  as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/CovidDeaths.population)*100
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3
) 
select *,(RollingPeopleVaccinated/population)*100 from PopvsVac;

--create new table peoplevaccinated
create table peoplevaccinated(continent nvarchar(255),location nvarchar(255),date datetime,population numeric, 
New_vaccinations numeric, rollingpeoplevaccinated numeric)

-- insert based on select
insert into peoplevaccinated
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,
CovidVaccinations.new_vaccinations,
sum(convert(int,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date )  as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/CovidDeaths.population)*100
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100 from peoplevaccinated;

-- drop table peoplevaccinated if existed, and create table peoplevaccinated
drop table if exists peoplevaccinated
create table peoplevaccinated(continent nvarchar(255),location nvarchar(255),date datetime,population numeric, 
New_vaccinations numeric, rollingpeoplevaccinated numeric)

-- insert based on select
insert into peoplevaccinated
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,
CovidVaccinations.new_vaccinations,
sum(convert(int,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date )  as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/CovidDeaths.population)*100
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
--where CovidDeaths.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100 from peoplevaccinated; */


-- create view people_vaccinated
create view people_vaccinated as
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,
CovidVaccinations.new_vaccinations,
sum(convert(int,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date )  as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/CovidDeaths.population)*100
from CovidDeaths join CovidVaccinations on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3;

-- select all data from people_vaccinated
select * from people_vaccinated;