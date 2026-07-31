QUERY

-- 1) Number of AI incidents by year (chronological order):
select year (date) as anno, count(date) as numero_incidenti, sum(deaths) as numero_morti
from INCIDENTI_IA_1, MORTI_IA
where INCIDENTI_IA_1.incident = MORTI_IA.incident
group by anno
order by anno;

-- 2) Number of deaths by incident category:
select classification, sum(deaths) as numero_morti
from CATEGORIE_IA c join INCIDENTI_IA_1 i on c.title = i.title join MORTI_IA m on i.incident= m.incident
group by classification
order by numero_morti desc;

-- 3) Number of deaths by country:
select country, sum(deaths) as numero_morti
from MORTI_IA m join GEOGRAFIA_IA g on m.incident = g.incident
group by country
order by numero_morti desc;

-- 4) Top 3 countries with the highest number of AI incidents:
select country, count(country) as frequenza_incidenti
from GEOGRAFIA_IA
group by country
order by frequenza_incidenti DESC
limit 3;





-- 5) Average number of deaths by country:
select country, media_morti
from (
select country, avg(deaths) as media_morti
from GEOGRAFIA_IA g join MORTI_IA m on g.incident = m.incident
group by country) as sottoquery
where media_morti > 0;

-- 6) Child victims and deployers          
select victims, deployer
from MORTI_IA m, GEOGRAFIA_IA g
where m.incident = g.incident and victims like '%child%' or '%children%’

-- 6.1) -- 6.1) Child Sexual Exploitation Victims: Deployer, Incident, and Description
select sottoquery3.incident, victims, deployer, description
from (
select sottoquery2.incident, victims, deployer
from (
select *
from (
select victims, MORTI_IA.incident
from MORTI_IA join (
select description, incident
from INCIDENTI_IA_1
where description like '%porn%') as sottoquery on MORTI_IA.incident = sottoquery.incident) as sottoquery1
where victims like '%child%' or '%children%') as sottoquery2 join GEOGRAFIA_IA  g on g.incident = sottoquery2.incident) as sottoquery3  join
INCIDENTI_IA_1 i on sottoquery3.incident = i.incident

-- 7) US vs China incident frequency by year:       
select sottoquery1.anno, US, China
from (select year(date) as anno, count(country) as US
from INCIDENTI_IA_1 i join GEOGRAFIA_IA g on i.incident=g.incident and country='US'
group by anno) as sottoquery1
left join
(select year(date) as anno, count(country) as China
from INCIDENTI_IA_1 i join GEOGRAFIA_IA g on i.incident=g.incident and country='China'
group by anno) as sottoquery2 on
sottoquery1.anno=sottoquery2.anno
order by anno

-- 8) Discrimination Category Analysis: Focus on Women, Black People, People with Disabilities, and Jewish People    
select tot_discrimination, against_women, against_black, against_disable, against_jewish
from (
select count(sottoquery1.incident) as tot_discrimination
from (
select incident
from CATEGORIE_IA c join INCIDENTI_IA_1 i on c.title=i.title and classification= 'discrimination') as sottoquery1) as sottoquery7,
(
select count(sottoquery2.incident) as against_women            
from (
select m.incident, m.victims    
from (
select incident     
from CATEGORIE_IA c join INCIDENTI_IA_1 i on c.title=i.title and classification= 'discrimination') as      nsottoquery1
join MORTI_IA m on m.incident=sottoquery1.incident) as sottoquery2
where victims like '%women%' or victims like '%female%' or victims like ‘%woman%’) as sottoquery8,
(
select count(sottoquery4.incident) as against_black
from (
select m.incident, m.victims
from (
select incident
from CATEGORIE_IA c join INCIDENTI_IA_1 i on c.title=i.title and classification= 'discrimination') as sottoquery3
join MORTI_IA m on m.incident=sottoquery3.incident) as sottoquery4
where victims like '%black%' or victims like '%dark%') as sottoquery9,
(
select count(sottoquery6.incident) as against_disable
from (
select m.incident, m.victims
from (
select incident
from CATEGORIE_IA c join INCIDENTI_IA_1 i on c.title=i.title and classification= 'discrimination') as sottoquery5
join MORTI_IA m on m.incident=sottoquery5.incident) as sottoquery6
where victims like '%disabil%') as sottoquery10,
(
select count(sottoquery6.incident) as against_jewish
from (
select m.incident, m.victims
from (
select incident
from CATEGORIE_IA c join INCIDENTI_IA_1 i on c.title=i.title and classification= 'discrimination') as sottoquery5
join MORTI_IA m on m.incident=sottoquery5.incident) as sottoquery6
where victims like '%jewish%') as sottoquery11

-- 9) Deepfake-related incidents: 
select incident, description
from INCIDENTI_IA_1
where description like '%deepfake%'

-- 9.1) -- 9.1) Deepfake Category Analysis: Percentage of Sexual, Fraudulent, and Political Manipulation Crimes:
select
totale_deepfake,
CONCAT(FORMAT((sexual_offence / totale_deepfake) * 100, 2), '%') AS sexual_offence_percentage,
CONCAT(FORMAT((fraud_use / totale_deepfake) * 100, 2), '%') AS fraud_use_percentage,
CONCAT(FORMAT((political_interference / totale_deepfake) * 100, 2), '%') AS political_interference_percentage
from (
select count(incident) as totale_deepfake
from INCIDENTI_IA_1          
where description like '%deepfake%') as sottoquery1,
(
select count(incident) as sexual_offence
from (select incident, description
from INCIDENTI_IA_1            
where description like '%deepfake%') as sottoquery2 where description like  '%sex%' or description like
'%porn%' or description like '%nude%') as sottoquery4,
 (
 select count(incident) as fraud_use
from (select incident, description
from INCIDENTI_IA_1
where description like '%deepfake%') as sottoquery5 where description like '%fraud%') as sottoquery6,
(
select count(incident) as political_interference      
from CATEGORIE_IA c join INCIDENTI_IA_1 i on c.title=i.title and description like '%deepfake%' and classification like '%political manipulation%') as sottoquery7

-- 10) Most frequent incident category by year:
select sottoquery3.anno, classification, CONCAT(FORMAT((maxfreq / tot_incidenti) * 100, 2), '%') AS classification_percentage, maxfreq, tot_incidenti
from
(
SELECT anno, classification, maxfreq
FROM (
    SELECT YEAR(date) AS anno, classification, COUNT(classification) AS maxfreq,
        ROW_NUMBER() OVER (PARTITION BY YEAR(date) ORDER BY COUNT(classification) DESC) as classifica
    FROM 
        INCIDENTI_IA_1 i join CATEGORIE_IA c on i.title=c.title
    GROUP BY 
        anno, classification
) AS sottoquery1
WHERE classifica = 1
) as sottoquery2
join 
(
select year (date) as anno, count(date) as tot_incidenti
from INCIDENTI_IA_1
group by anno
order by anno) as sottoquery3
on sottoquery2.anno= sottoquery3.anno
