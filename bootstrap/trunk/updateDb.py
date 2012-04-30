#! /usr/bin/python
import pg, time

db = pg.connect(dbname='ls',user='lsuser', host='contrabass.ls-cat.org')
qs = "UPDATE epics._pvmonitors SET pvmValue=epics.caget(pvmname)"
while( True):
    db.query( qs)
    time.sleep( 0.5)

