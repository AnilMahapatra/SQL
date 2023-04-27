
Select *
FROM CovidDeaths
where continent is NULL
order by 3, 4


--Select Location, Date, total_cases, total_deaths, population
--FROM CovidDeaths
--order by 1,2

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as TDeaths
FROM CovidDeaths
where location like 'India'
order by 1,2


Select Location, population, max(total_cases) as MaxCases, 
max((total_cases/population)*100) as Infected
FROM CovidDeaths
--where location like 'India'
Group by location, population
order by Infected DESC

-- People died

Select continent, max(cast(total_deaths as int)) as MaxDeath 
FROM CovidDeaths
--where location like 'India'
where continent is  not NULL
Group by continent
order by MaxDeath DESC

--showing the continent with highest death count

Select continent, max(cast(total_deaths as int)) as MaxDeath 
FROM CovidDeaths
--where location like 'India'
where continent is  not NULL
Group by continent
order by MaxDeath DESC

--Global Numbers

Select SUM(new_cases), SUM(cast(new_deaths as int)),
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPerCase --, total_deaths, (total_deaths/total_cases)*100 as TDeaths
FROM CovidDeaths
--where location like 'India'
Where continent is not null
--Group by date
order by 1,2


--Looking at population Vs vacanataion

Select D.continent, D.location, D.date, D.population, 
V.new_vaccinations, SUM(CONVERT(int,V.new_vaccinations))
OVER (Partition by D.Location ORDER by D.Location, D.date) as RollingVac

FROM CovidDeaths D JOIN CovidVac V
	ON D.location= V.location 
	AND D.date= V.date
	Where D.continent is not NULL
	--AND V.new_vaccinations is not NULL
	Order by 2,3

--CTE

With PopvsVac (continent,location, date, population, new_vaccinations, RollingVac)
as
(
Select D.continent, D.location, D.date, D.population, 
V.new_vaccinations, SUM(CONVERT(int,V.new_vaccinations))
OVER (Partition by D.Location ORDER by D.Location, D.date) as RollingVac
FROM CovidDeaths D JOIN CovidVac V
	ON D.location = V.location 
	AND D.date = V.date
	Where D.continent is not NULL
	AND V.new_vaccinations is not NULL
	--Order by 2,3
)
Select *, (RollingVac/population)*100 as RollingPer
From PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PvV
CREATE TABLE #PvV
(continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVac numeric
)
INSERT INTO #PvV
Select D.continent, D.location, D.date, D.population, 
V.new_vaccinations, SUM(CONVERT(int,V.new_vaccinations))
OVER (Partition by D.Location ORDER by D.Location, D.date) as RollingVac
FROM CovidDeaths D JOIN CovidVac V
	ON D.location = V.location 
	AND D.date = V.date
	Where D.continent is not NULL
	AND V.new_vaccinations is not NULL
	--Order by 2,3

Select *, (RollingVac/population)*100 as RollingPer
From #PvV


--Creating Views to store data for visuualtion 

CREATE view PvView as
Select D.continent, D.location, D.date, D.population, 
V.new_vaccinations, SUM(CONVERT(int,V.new_vaccinations))
OVER (Partition by D.Location ORDER by D.Location, D.date) as RollingVac
FROM CovidDeaths D JOIN CovidVac V
	ON D.location = V.location 
	AND D.date = V.date
	Where D.continent is not NULL
	AND V.new_vaccinations is not NULL
	--Order by 2,3
	
	Select *
	From PvView