#!SQL!# CREATE OR REPLACE FUNCTION px.kvgetpy( stn int, k text) returns text as $$

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

lk   = k
lstn = stn
if k.find('stns.') != 0:
    if stn < 1 or stn > 4:
        return None
    lk = 'stns.%d.%s' % (stn, k)
else:
    lstn = int( k[5])
    if lstn < 1 or lstn > 4:
        return None

r = SD["r"]
tmp = r[lstn].hget( lk, "VALUE")
if tmp != None:
    rtn = tmp.decode("utf-8")
else:
    rtn = None

return rtn

#!SQL!# $$ LANGUAGE plpython3u SECURITY DEFINER;
#!SQL!# ALTER FUNCTION px.kvgetpy( int, text) OWNER TO administrators;
