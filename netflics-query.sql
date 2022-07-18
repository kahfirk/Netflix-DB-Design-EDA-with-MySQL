use netflics;
 
 -- ---------------------------------------------------------------------------------------------
 
select m.genre_name ,m.type, avg(imdb_score)+ avg(tmdb_score) as overall_score, avg(m.runtime)
from (select c.contentid,c.runtime, c.type, title, genre_name
	  from content as c
      inner join genres as g 
      ON c.contentid = g.contentid) as m
LEFT JOIN imdb as i on m.contentid =i.contentid
group by m.genre_name,m.type ORDER BY type,genre_name;

Select genre_name,count(*) from genres
group by genre_name
ORDER BY count(*) desc; 
 
create view fav_genres as
select genre_name, count(*) as total_content
from genres 
Group by genre_name
Having count(*) >= (select count(*) 
			        from genres
			        group by genre_name 
			        order by count(*) desc
			        limit 2,1) 
order by count(*) desc;

Select * from fav_genres;

select m.genre_name ,m.type, avg(imdb_score), avg(tmdb_score), avg(m.runtime)
from (select c.contentid,c.runtime, c.type, title, genre_name
	  from content as c
      inner join genres as g 
      ON c.contentid = g.contentid) as m
LEFT JOIN imdb as i on m.contentid =i.contentid
group by m.genre_name,m.type ORDER BY genre_name,type;

-- ---------------------------------------------------------------------------------------------

select contentid,actorid,count(*) from content_character
natural join starred
group by contentid,actorid
having count(*) > 1
order by count(*) desc;

create view duplicate_content_character as (
select * from content_character
natural join starred
where contentid in (select contentid from content_character
					natural join starred
					group by contentid,actorid
					having count(*)>1) and actorid in (select actorid from content_character
													   natural join starred
													   group by contentid,actorid
													   having count(*)>1));
create view char_duplicate as 
(select charid from duplicate_content_character as d1
where actorid in ( select actorid from duplicate_content_character as d1
				   where name is null) 
                   and contentid in ( select contentid from duplicate_content_character as d1
									  where name is null)
			       and name is null)
union
(select d1.charid from duplicate_content_character as d1,duplicate_content_character as d2
where d1.actorid=d2.actorid and d1.contentid=d2.contentid and d1.charid<> d2.charid and d1.name = d2.name);

Delete from starred where charid in (select * from char_duplicate);
Delete from content_character where charid in (select * from char_duplicate);		