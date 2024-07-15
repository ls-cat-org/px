#!SQL!# CREATE OR REPLACE FUNCTION px.kvpv_inp(pv text) RETURNS text as $$

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

r = SD["r"]
for stn in range(1, 5):
    for k in r[stn].keys('*'):
        ks = k.decode("utf-8")
        try:
            v = r[stn].hget(ks, 'INP')
        except redis.exceptions.ResponseError:
            continue
        
        if v == None:
            continue
        
        vs = v.decode("utf=8")
        if vs == pv:
            return ks

return None

#!SQL!# $$ language plpython3u SECURITY DEFINER;
#!SQL!# ALTER FUNCTION px.kvpv_inp( text) OWNER TO administrators;
