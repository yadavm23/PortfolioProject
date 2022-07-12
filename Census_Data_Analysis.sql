 

Select * From PortfolioProject..Sheet1

--Calculating the total number of rows in the dataset

Select count(*) from PortfolioProject..Data1

Select count(*) from PortfolioProject..Sheet1

--selecting dataset for specific data

Select * 
from PortfolioProject..Data1
where state in ('Jharkhand' , 'Bihar')

-- calculating  the total population from this dataset

Select sum(population) as Population From PortfolioProject..Sheet1

--Average growth for the entire country

Select avg(growth) as Average_Growth from PortfolioProject..Data1

--Average growth for certain states

Select state, avg(growth)*100 as Avg_StateGrowth from PortfolioProject..Data1 group by state

--Average sex ratio

Select state, ROUND(avg(sex_ratio),0) as Avg_SexRatio from PortfolioProject..Data1 
group by state
ORDER BY Avg_SexRatio desc

--Average Literacy Rate

Select state, ROUND(avg(Literacy),0) as Avg_Literacy from PortfolioProject..Data1 
group by state having round(avg(literacy),0)>90
ORDER BY Avg_Literacy desc

--Top 3 state with highest growth ratio

Select top 3 state, avg(growth)*100 as Avg_StateGrowth from PortfolioProject..Data1 group by state order by Avg_StateGrowth desc

--Bottom 3 state with lowest sex ratio

Select top 3 state, avg(growth)*100 as Avg_StateGrowth from PortfolioProject..Data1 group by state order by Avg_StateGrowth desc

Select top 3 state, ROUND(avg(sex_ratio),0) as Avg_SexRatio from PortfolioProject..Data1 
group by state
ORDER BY Avg_SexRatio asc

--top and bottom 3 states according to literacy rate

Drop table if exists #topstates;
create table #topstates
(state nvarchar(255),
topstate float
)
insert into #topstates
Select state, ROUND(avg(literacy),0) as Avg_Literacy from PortfolioProject..Data1 
group by state order by avg_literacy desc;

Select top 3 * From #topstates order by #topstates.topstate desc;


Drop table if exists #bottomstates;
create table #bottomstates
(state nvarchar(255),
bottomstate float
)
insert into #bottomstates
Select state, ROUND(avg(literacy),0) as Avg_Literacy from PortfolioProject..Data1 
group by state order by avg_literacy desc;


Select top 3 * From #bottomstates order by #bottomstates.bottomstate asc;

--Union operator
Select *From(
Select top 3 * From #topstates order by #topstates.topstate desc) a
union
Select * From(
Select top 3 * From #bottomstates order by #bottomstates.bottomstate asc) b


--Selecting states that start with a specific letter (Distinct Value)

Select distinct state from PortfolioProject..Data1 where lower(state) like 'a%' or lower(state) like 'b%'

--Selecting values that start adn end with a certain character

Select distinct state from PortfolioProject..Data1 where lower(state) like 'a%' and lower(state) like 'm%'

--Calculating the number of males and females by joining tables

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from PortfolioProject..data1 a inner join PortfolioProject..sheet1 b on a.district=b.district ) c) d
group by d.state;

--total literacy rate

select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from PortfolioProject..data1 a 
inner join PortfolioProject..sheet1 b on a.district=b.district) d) c
group by c.state

--Population in the previous sensus from current years data
Select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from(
select e.state, sum(e.previous_census_population) previous_census_population, sum(e.current_census_population) current_census_population from 
(select d.district, d.state, round(d.population/(1+d.growth),0) previous_census_population, d.population current_census_population from 
(select a.district, a.state, a.growth growth, b.population from PortfolioProject..data1 a inner join PortfolioProject..sheet1 b on a.district=b.district) d) e 
group by e.state) m

--population vs. area

Select g.total_area/g.previous_census_population previous_census_population_vs_area, g.total_area/g.current_census_population current_census_population_vs_area from
(Select q.*, r.total_area from (

Select '1' as keyy, n. * from 
(Select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from(
select e.state, sum(e.previous_census_population) previous_census_population, sum(e.current_census_population) current_census_population from 
(select d.district, d.state, round(d.population/(1+d.growth),0) previous_census_population, d.population current_census_population from 
(select a.district, a.state, a.growth growth, b.population from PortfolioProject..data1 a inner join PortfolioProject..sheet1 b on a.district=b.district) d) e 
group by e.state) m) n) q inner join(

Select '1' as keyy, z. * from(
Select sum(area_km2) total_area from PortfolioProject..sheet1) z) r on q.keyy=r.keyy) g

--window funtions
--output top 3 districts from each state with highest literacy rate

Select a.* from
(Select district, state, literacy, rank() over(partition by state order by literacy desc) rnk from PortfolioProject..data1) a

where a.rnk in (1,2,3) order by state
