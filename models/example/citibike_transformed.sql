select a.ride_id,a.type,a.value1 as station_id,a.rideable_type as rideable_type,
b.value1 as station_name,
c.value1 as latitude,
d.value1 as longitude,
e.value1 as datetime,
a.start_station_name as start_station,
a.end_station_name as end_station,
concat(a.start_station_name,'->',a.end_station_name) as biking_path,
haversine(a.start_lat, a.start_lng, a.end_lat, a.end_lng) as distance
from
(
select ride_id, rideable_type, start_lat, start_lng, end_lat, end_lng, split_part(DataPoint,'_',0) as type, value1, start_station_name, end_station_name from pc_fivetran_db.citibike.citibike
    unpivot(value1 FOR DataPoint in (start_station_id, end_station_id))) a
inner join
(select ride_id, split_part(DataPoint,'_',0) as type, value1 from pc_fivetran_db.citibike.citibike
    unpivot(value1 FOR DataPoint in (start_station_name, end_station_name))) b 
inner join
(select ride_id, split_part(DataPoint,'_',0) as type, value1 from pc_fivetran_db.citibike.citibike
    unpivot(value1 FOR DataPoint in (start_lat, end_lat))) c 
inner join
(select ride_id, split_part(DataPoint,'_',0) as type, value1 from pc_fivetran_db.citibike.citibike
    unpivot(value1 FOR DataPoint in (start_lng, end_lng))) d 
inner join
(select ride_id, split_part(DataPoint,'_',0) as type, value1 from pc_fivetran_db.citibike.citibike
    unpivot(value1 FOR DataPoint in (started_at, ended_at))) e
on a.ride_id=b.ride_id and a.type=b.type and
a.ride_id=c.ride_id and a.type=c.type and
a.ride_id=d.ride_id and a.type=d.type and
a.ride_id=e.ride_id and concat(a.type,'ED')=e.type
order by a.ride_id