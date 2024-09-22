--схема БД: https://docs.google.com/document/d/1NVORWgdwlKepKq_b8SPRaSpraltxoMg2SIusTEN6mEQ/edit?usp=sharing
--colab/jupyter: https://colab.research.google.com/drive/1j4XdGIU__NYPVpv74vQa9HUOAkxsgUez?usp=sharing

--task13 (lesson3)
--Компьютерная фирма: Вывести список всех продуктов и производителя с указанием типа продукта (pc, printer, laptop). Вывести: model, maker, type
select product.model, maker, product.type
from product
join
(select model from pc p 
union all
select model from printer p2 
union all 
select model from laptop l 
) model_all
on product.model = model_all.model

--task14 (lesson3)
--Компьютерная фирма: При выводе всех значений из таблицы printer дополнительно вывести для тех, у кого цена вышей средней PC - "1", у остальных - "0"
with avg_price_pc as (select avg(price) from pc)
select *,
case 
	when price > (select avg from avg_price_pc)
	then 1
else 0
end flag
from printer 

--task15 (lesson3)
--Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL)
select name
from (
select name, class
from ships
union all
select ship, battle
from outcomes o) all_ships
where class is null

--task16 (lesson3)
--Корабли: Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.
SELECT DISTINCT name 
FROM battles 
WHERE YEAR([date]) NOT IN (SELECT launched FROM ships WHERE launched IS NOT NULL)

--task17 (lesson3)
--Корабли: Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.
select battle, ship
from outcomes o 
join (
select name, class 
from ships) s
on o.ship = s.name 
where class = 'Kongo'

--task1  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_300) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше > 300. Во view три колонки: model, price, flag
create view all_products_flag_300
as select p.model, price,
case
when price > 300
then 1
else 0
end flag
from product p 
join
(select model, price
 from pc 
 union all
 select model, price 
 from laptop 
 union all
 select model, price 
 from printer) as all_product
 on p.model = all_product.model ;;

--task2  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_avg_price) для всех товаров (pc, printer, laptop) с флагом, если стоимость больше cредней . Во view три колонки: model, price, flag
create view all_products_avg_price
as select p.model, price,
case
when price > avg(price) 
then 1
else 0
end flag
from product p 
join
(select model, price
 from pc 
 union all
 select model, price 
 from laptop 
 union all
 select model, price 
 from printer) as all_products
 on p.model = all_products.model 
group by p.model

--task3  (lesson4)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model
select p.model, maker
from product p 
join
(select model, price
from printer) p2
on p.model = p2.model
where maker = 'A' and price > (select avg(price) from printer where maker = 'D') 
  and price > (select avg(price) from printer where maker = 'C')

--task4 (lesson4)
-- Компьютерная фирма: Вывести все товары производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. Вывести model
select p.model, maker
from product p 
join
(select model, price
from printer) p2
on p.model = p2.model
where maker = 'A' and price > (
  select avg(price) from printer  where maker = 'D') 
   and price > (select avg(price) from printer where maker = 'C')

--task5 (lesson4)
-- Компьютерная фирма: Какая средняя цена среди уникальных продуктов производителя = 'A' (printer & laptop & pc)
 select distinct model, avg(price)
from
(
SELECT price, maker, p.model
FROM laptop l
join product p on l.model = p.model
union all

SELECT price, maker, p.model
FROM pc l
join product p on l.model = p.model
union all

SELECT price, maker, p.model
FROM printer l
join product p on l.model = p.model
) a
where maker = 'A'
group by model
order by avg

--task6 (lesson4)
-- Компьютерная фирма: Сделать view с количеством товаров (название count_products_by_makers) по каждому производителю. Во view: maker, count
create view count_products_by_makers
as 
select count(model), maker
from product p 
group by maker
order by maker

--task7 (lesson4)
-- По предыдущему view (count_products_by_makers) сделать график в colab (X: maker, y: count)
https://colab.research.google.com/drive/1Xe7n3unj2yII6V5x_tmZMF17j-NQnEKW?usp=sharing

--task8 (lesson4)
-- Компьютерная фирма: Сделать копию таблицы printer (название printer_updated) и удалить из нее все принтеры производителя 'D'
create table printer_updated
as select *
from printer
join product 
on printer.model = product.model ;;
delete from printer_updated
where maker = 'D'

--task9 (lesson4)
-- Компьютерная фирма: Сделать на базе таблицы (printer_updated) view с дополнительной колонкой производителя (название printer_updated_with_makers)
create view printer_updated_with_makers
as
select maker
from printer_updated

--task10 (lesson4)
-- Корабли: Сделать view c количеством потопленных кораблей и классом корабля (название sunk_ships_by_classes). Во view: count, class (если значения класса нет/IS NULL, то заменить на 0)
create view sunk_ships_by_classes
as 
select count(result), class,
case
	when class is null
	then '0'
	else class
end class
from outcomes 
join ships
on outcomes.battle = ships.class
where result ='sunk'
group by class

--task11 (lesson4)
-- Корабли: По предыдущему view (sunk_ships_by_classes) сделать график в colab (X: class, Y: count)
https://colab.research.google.com/drive/1Xe7n3unj2yII6V5x_tmZMF17j-NQnEKW?usp=sharing

--task12 (lesson4)
-- Корабли: Сделать копию таблицы classes (название classes_with_flag) и добавить в нее flag: если количество орудий больше или равно 9 - то 1, иначе 0
create table classes_with_flag
as select class, numguns,
case
	when numguns >= 9
	then 1
	else 0
end flag
from classes c

--task13 (lesson4)
-- Корабли: Сделать график в colab по таблице classes с количеством классов по странам (X: country, Y: count)
select count(class), country 
from classes c 
group by country 
https://colab.research.google.com/drive/1Xe7n3unj2yII6V5x_tmZMF17j-NQnEKW?usp=sharing


--task14 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название начинается с буквы "O" или "M".
select count(name) 
from ships
where name like 'M_%' or 'O_%'

--task15 (lesson4)
-- Корабли: Вернуть количество кораблей, у которых название состоит из двух слов.
select count(name)
from ships
where name like '% %'

--task16 (lesson4)
-- Корабли: Построить график с количеством запущенных на воду кораблей и годом запуска (X: year, Y: count)
select count(name), launched as year
from ships
group by year 
https://colab.research.google.com/drive/1Xe7n3unj2yII6V5x_tmZMF17j-NQnEKW?usp=sharing