//
// gcc md2test.c -o md2test -lpq

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include <libpq-fe.h>


//
// The database connection pointers
// db is for normal communications
// dblock is only for synchronizing with the detector
//
static PGconn *db     = NULL;
static PGconn *dblock = NULL;


//
// run exposure
//  et = exposure time in seconds
//
void run( char *tkn) {
  static char qs[8192];	// used to build query string (welcome to C)
  PGresult *qr;		// query result
  PGresult *qrf;	// query result for frames
  unsigned int uet;	// unsigned int version of et
  int readyFlag;	// signals that the detector process is ready
  int i;		// loop counter
  struct timeval t1;		// time structures to measure exposure time
  struct timeval t2;
  char fn1[512];
  char fn[1024];
  char dir[512];
  char stn[32];
  char oscaxis[32];
  char initialPos[64];
  char finalPos[64];
  char owidth[64];
  char nwedge[64];
  char adelta[64];
  char exp[64];
  char expunit[64];
  char start[64];


  snprintf( qs, sizeof( qs)-1, "select * from px.datasets where dspid='%s'", tkn);
  qs[sizeof(qs)-1] = 0;
  qr = PQexec( db, qs);
  if( PQresultStatus( qr) != PGRES_TUPLES_OK) {
    fprintf( stderr, "Query Failed: %s\n", qs);
    fprintf( stderr, "%s\n", PQerrorMessage( db));
    PQclear( qr);
    return;
  }

  strncpy( dir, PQgetvalue( qr, 0, PQfnumber( qr, "dsdir")), sizeof( dir)-1);
  dir[sizeof(dir)-1] = 0;

  strncpy( owidth, PQgetvalue( qr, 0, PQfnumber( qr, "dsowidth")), sizeof( owidth)-1);
  owidth[sizeof(owidth)-1] = 0;

  strncpy( oscaxis, PQgetvalue( qr, 0, PQfnumber( qr, "dsoscaxis")), sizeof( oscaxis)-1);
  oscaxis[sizeof(oscaxis)-1] = 0;

  strncpy( exp, PQgetvalue( qr, 0, PQfnumber( qr, "dsexp")), sizeof( exp)-1);
  exp[sizeof(exp)-1] = 0;

  PQclear( qr);

  snprintf( qs, sizeof( qs)-1, "select * from px.shots where sstate='NotTaken' and sdspid='%s' order by sindex", tkn);
  qrf = PQexec( db, qs);
  if( PQresultStatus( qrf) != PGRES_TUPLES_OK) {
    fprintf( stderr, "Query Failed: %s\n", qs);
    fprintf( stderr, "%s\n", PQerrorMessage( db));
    PQclear( qrf);
    return;
  }


  for( i=0; i<PQntuples( qrf); i++) {
    strncpy( start, PQgetvalue( qrf, i, PQfnumber( qrf, "sstart")), sizeof( start)-1);
    start[sizeof(start)-1] = 0;

    strncpy( fn, dir, sizeof( fn)-2);
    fn[sizeof(fn)-2] = 0;
    strcat( fn, "/");
    fn[sizeof(fn)-1] = 0;

    strncpy( fn1, PQgetvalue( qrf, i, PQfnumber( qrf, "sfn")), sizeof( fn1)-1);
    fn1[sizeof(fn1)-1] = 0;

    strncat( fn, fn1, sizeof( fn) - 1 -strlen( fn));
    fn[sizeof(fn)-1] = 0;


    fprintf( stderr, "Position %s to %s for %s", oscaxis, start, fn1);
    fflush( stderr);

    //
    // wait for detector process to grab its lock so we know it is ready
    readyFlag = 0;

    while( !readyFlag) {
      //
      // Try to grab the detector lock
      // if we succeed the detector is not ready
      //      fprintf( stderr, "Testing mar lock\n");
      //      fflush( stderr);

      qr = PQexec( db, "lock table px._marlock in access exclusive mode nowait");
      //      fprintf( stderr, "    returned\n");
      //      fflush( stderr);

      if( PQresultStatus( qr) != PGRES_COMMAND_OK) {
	//	fprintf( stderr, "db returned %s\n", PQerrorMessage( db));
	//	fflush( stderr);
	//
	// Command error means the detector is ready
	readyFlag = 1;
      } else {
	//
	// No error means the detector is not ready
	// pause a moment to keep from running wild
	usleep( 500000);
      }
      PQclear( qr);
    }

    //
    // Start transation block for the lock
    // Nothing interesting happens if we get a lock outside the block
    //    fprintf( stderr, "starting transaction\n");
    //    fflush( stderr);

    qr = PQexec( dblock, "begin");
    if( PQresultStatus( qr) != PGRES_COMMAND_OK) {
	fprintf( stderr, "db returned %s\n", PQerrorMessage( db));
	fflush( stderr);
    }
    PQclear( qr);

    //
    // get the lock, blocking if needed (this allows the detector to force us to wait)
    //    fprintf( stderr, "Getting MD2 lock\n");
    //    fflush( stderr);

    qr = PQexec( dblock, "lock table px._md2lock in access exclusive mode");
    if( PQresultStatus( qr) != PGRES_COMMAND_OK) {
	fprintf( stderr, "db returned %s\n", PQerrorMessage( db));
	fflush( stderr);
    }
    PQclear( qr);

    //
    // tell detector to start integrating
    //    fprintf( stderr, "queueing start command\n");
    //    fflush( stderr);

    snprintf( qs, sizeof(qs)-1, "select px.pushqueue('collect,%s')", fn);
    qr = PQexec( db, qs);
    PQclear( qr);

    // wait for detector to release its lock
    // use the normal connection so we do not have to give up the lock we already have
    // Do not use a transation block: we don't intend to keep this lock
    // This blocks until the detector is integrating
    //    fprintf( stderr, "testing mar lock\n");
    //    fflush( stderr);

    qr = PQexec( db, "lock table px._marlock in access exclusive mode");
    if( PQresultStatus( qr) != PGRES_COMMAND_OK) {
	fprintf( stderr, "db returned %s\n", PQerrorMessage( db));
	fflush( stderr);
    }
    PQclear( qr);

    //
    // whatever code needs to be run to do the exposure goes here
    fprintf( stderr, "Scaning %s: shutter open starting at %s degrees for %s degrees in %s seconds\n", oscaxis, start, owidth, exp);
    fflush( stderr);

    uet = atof( exp) * 1000000.0;
    //    fprintf( stderr, "Sleeping...");
    //    fflush( stderr);

    gettimeofday( &t1, NULL);
    usleep( uet);
    gettimeofday( &t2, NULL);
    fprintf( stderr, "  Actual shutter open time: %6.3f secs\n", t2.tv_sec+t2.tv_usec/1000000. - t1.tv_sec-t1.tv_usec/1000000.);
    fflush( stderr);

    // fprintf( stderr, "...Done\n");
    //    fflush( stderr);

    //
    // release lock to let detector know we are done
    //    fprintf( stderr, "realeasing md2 lock\n");
    //    fflush( stderr);

    qr = PQexec( dblock, "commit");
    if( PQresultStatus( qr) != PGRES_COMMAND_OK) {
	fprintf( stderr, "db returned %s\n", PQerrorMessage( db));
	fflush( stderr);
    }
    PQclear( qr);
  }
  PQclear( qrf);
}

int main( int argc, char **argv) {
  int i;
  PGresult *qr;
  char token[512];

  //
  // 
  fprintf( stderr, "getting db connection\n");
  db = PQconnectdb( "dbname=ls user=lsuser host=postgres.ls-cat.net");
  if( PQstatus( db) != CONNECTION_OK) {
    fprintf( stderr, "Connection 1 failed\n");
    exit( 1);
  }

  fprintf( stderr, "getting dblock connection\n");
  dblock = PQconnectdb( "dbname=ls user=lsuser host=postgres.ls-cat.net");
  if( PQstatus( dblock) != CONNECTION_OK) {
    fprintf( stderr, "Connection 1 failed\n");
    exit( 1);
  }


  qr = PQexec( db, "select px.mkshots( 'kbtest', '/data/kb070720', '21-ID-F', 'phi', 0, 180, 1, 0, 1, 10.0, 'Seconds')");
  if( PQresultStatus( qr) != PGRES_TUPLES_OK) {
    fprintf( stderr, "mkshots failed: %s\n", PQerrorMessage( db));
    exit( 1);
  }
  strncpy( token, PQgetvalue( qr, 0, 0), sizeof( token)-1);
  token[sizeof(token)-1] = 0;
  PQclear( qr);

  fprintf( stderr, "Got token %s\n", token);

  run( token);

 
  PQfinish( db);
  PQfinish( dblock);

  return( 0);
}
