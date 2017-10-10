  select
    sum(case when content like "% 403 %" then 1 else 0 end) as status_403,
    count(*) as total
  from autonavi_aos_dw.s_tt_nginx_amap_aos_tt4
  where ds=20170702 and hh=05
  and (content like "%02/Jul/2017:05:11:%"
  or content like "%02/Jul/2017:05:12:%"
  or content like "%02/Jul/2017:05:13:%"
  or content like "%02/Jul/2017:05:14:%"
  or content like "%02/Jul/2017:05:15:%"
  or content like "%02/Jul/2017:05:16:%"
  or content like "%02/Jul/2017:05:17:%"
  or content like "%02/Jul/2017:05:18:%"
  or content like "%02/Jul/2017:05:19:%"
  or content like "%02/Jul/2017:05:20:%"
  or content like "%02/Jul/2017:05:21:%"
  or content like "%02/Jul/2017:05:22:%"
  or content like "%02/Jul/2017:05:23:%"
  or content like "%02/Jul/2017:05:24:%"
  or content like "%02/Jul/2017:05:25:%");


  
