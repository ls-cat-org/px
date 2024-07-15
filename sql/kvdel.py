#!SQL!# CREATE OR REPLACE FUNCTION px.kvdel( stn int, k text) returns void as $$

if not "redis" in SD:
    import redis
    SD["redis"] = redis

redis = SD["redis"]
if not "w" in SD:
    SD["w"]    = [ None, None, None, None, None]
    SD["w"][1] = redis.StrictRedis(host="ioc-d.ls-cat.net", port=6379,db=0)
    SD["w"][2] = redis.StrictRedis(host="ioc-e.ls-cat.net", port=6379,db=0)
    SD["w"][3] = redis.StrictRedis(host="ioc-f.ls-cat.net", port=6379,db=0)
    SD["w"][4] = redis.StrictRedis(host="ioc-g.ls-cat.net", port=6379,db=0)

lk   = k
lstn = stn
if k.find('stns.') != 0:
    if stn < 1 or stn > 4:
        return
    lk = 'stns.%d.%s' % (stn, k)
else:
    lstn = int(k[5])
    if lstn < 1 or lstn > 4:
        return

w = SD["w"]
w[lstn].delete(lk)
return

#!SQL!# $$ language plpython3u SECURITY DEFINER;
#!SQL!# ALTER FUNCTION px.kvdel( int, text) OWNER TO administrators;
