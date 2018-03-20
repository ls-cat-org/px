#! /usr/bin/python3
# Copyright 2016 by Northwestern University
# Author:  Keith Brister
# License: All Rights Reserved
#

import pg
import redis
import time
import sys

stn_config = [
    {'stn': 1, 'host': 'mung-2.ls-cat.org'},
    {'stn': 2, 'host': 'orange-2.ls-cat.org'},
    {'stn': 3, 'host': 'kiwi-2.ls-cat.org'},
    {'stn': 4, 'host': 'mango-2.ls-cat.org'}
]
    
stn_status = {}


class ESAF_Watcher:

    def handler(self, msg):
        if msg['type'] != 'message':
            return;

        dm = msg['data'].decode('utf-8')

        if dm != self.k:
            return
        
        last_v = self.v
        
        self.v = self.r.hget(self.k, 'VALUE').decode('utf-8')
        if self.v == 'false':
            self.v = False

        if not self.v and last_v:
            self.arm_trigger = True

        stn_status[self.k] = str(self.v)

        print("*********************************************")
        for k in sorted(stn_status):
            print("%s: %s" % (k, stn_status[k]))
        print("*********************************************")


    def __init__(self, stn, host):
        self.arm_trigger = False
        self.stn = stn
        self.r   = redis.Redis(host=host)
        self.p   = self.r.pubsub()
        self.k   = 'stns.%d.esaf' % (self.stn)
        self.v   = self.r.hget(self.k, 'VALUE').decode('utf-8')
        if self.v == 'false':
            self.v = False
            self.arm_trigger = True

        stn_status[self.k] = self.v
        print(self.k, self.v)

    def run(self):
        self.p.subscribe(**{'REDIS_PG_CONNECTOR': self.handler})
        self.thread = self.p.run_in_thread(sleep_time=0.1)


    def close(self):
        self.thread.stop()
        self.p.close()

    def esaf(self):
        return self.v

    def service_me(self):
        rtn = self.arm_trigger
        self.arm_trigger = False
        return rtn


if __name__ == '__main__':


    db = pg.connect(dbname='ls',user='lsuser', host='contrabass.ls-cat.org')

    watchers = []
    for z in stn_config:
        watchers.append(ESAF_Watcher(z['stn'], z['host']))

    try:
        for w in watchers:
            w.run()
            
        while True:
            time.sleep(1)
            for w in watchers:
                if w.service_me():
                    print ('Cleaning up station %d' % (w.stn))
                    qr = db.query('select px.delete_inactive_frames(%d::int) as n_deleted' % (w.stn))
                    r  = qr.dictresult()[0]
                    print ('Deleted %d frames from station %d' % (r['n_deleted'], w.stn))
                
    except KeyboardInterrupt:
        for w in watchers:
            w.close()
        print('We are done.')
        sys.exit()
