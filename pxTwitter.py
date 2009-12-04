#! /usr/bin/python

import twitter, pg, time

class PxTwitter:
    db = None
    api = None
    qs  = None

    def __init__( self):
        self.db = pg.connect(dbname='ls',user='lsuser', host='contrabass.ls-cat.org')
        self.api = twitter.Api( username='ls_cat', password='Bonang85')
        self.qs  = "select px.rt_get_twitter() as tweet"

    def run( self):
        while( 1):
            qr = self.db.query(self.qs)
            msg = qr.dictresult()[0]['tweet']
            if len(msg) > 16:
                self.api.PostUpdate( msg)

            time.sleep( 120)


if __name__ == '__main__':
    zz = PxTwitter()
    zz.run()
    
