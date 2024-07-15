#!SQL!# CREATE OR REPLACE FUNCTION px.kvkeys( stn int, wc text) returns setof text as $$

if not "redis" in SD:
    import redis
    SD["redis"] = redis

redis = SD["redis"]
if not "r" in SD:
    SD["r"]    = [ None, None, None, None, None]
    SD["r"][1] = redis.StrictRedis(host="localhost",port=6381,db=0)
    SD["r"][2] = redis.StrictRedis(host="localhost",port=6382,db=0)
    SD["r"][3] = redis.StrictRedis(host="localhost",port=6383,db=0)
    SD["r"][4] = redis.StrictRedis(host="localhost",port=6384,db=0)

lwc   = wc
lstn = stn
if wc.find('stns.') != 0:
    if stn < 1 or stn > 4:
        return []
    lwc = 'stns.%d.%s' % (stn, wc)
else:
    lstn = int( wc[5])
    if lstn < 1 or lstn > 4:
        return []

r = SD["r"]
return [x.decode("utf-8") for x in r[lstn].keys(lwc)]

#!SQL!# $$ language plpython3u SECURITY DEFINER;
#!SQL!# ALTER FUNCTION px.kvkeys( int, text) OWNER TO administrators;
