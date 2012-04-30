#include "pgaccess.h"
#include <libpq-fe.h>
#include <math.h>
#include <time.h>
//#include <windows.h>

static PGconn* connection = NULL;				/**< Access using getconn.															*/
static char* pid = NULL;								/**< Process id for accessing data base.								*/
static int quit = 0;										/**< Set to true when we need to start another cycle.		*/
static int appQuit = 0;									/**< Set to true when we need to exit the program.			*/
static pv* pvArray = NULL;							/**< Pvs that are being handled.												*/
static int pvArraySize = 0;							/**< Size of pvArray.																		*/
sem_t pvArrayLock;
const double LS_INIT_TIMEOUT = 60;
void quitConnection();

/**
* Get the shared connection.
*
* @return Shared pgsql connection.
*/
PGconn* getconn()
{
	PGresult* res;

	if( connection == NULL)
	{
		/* open up the connection. */
		connection = PQconnectdb("dbname=ls user=lsuser host=10.1.0.3");

		if(PQstatus(connection) != CONNECTION_OK)
		{
			printf("Failed to connection to contrabass.\n");
			quitConnection();
			return NULL;
		}

		/** get the next pid. */
		res = PQexec(connection, "select epics.iniCAMonitor()");

		if(PQresultStatus(res) == PGRES_TUPLES_OK && PQntuples(res) > 0)
		{
			pid = malloc(strlen(PQgetvalue(res, 0, 0)) + 1);	/* alocate enough memory.				*/
			strcpy(pid, PQgetvalue(res, 0, 0));		/* copy into our string.				*/
			pid[strlen(PQgetvalue(res, 0, 0))] = '\0';		/* ensure null termination.			*/
			PQclear(res);	/* clean up result. */
			printf("The pid is: %s\n", pid);
		} else {
			printf("failed to get pid\n");
			/* set pid to an illegal value. */
			pid = malloc(sizeof(char) * 2);
			pid[0] = -1;
			pid[1] = 0;
		}
	}

	return connection;
}

/**
* If connected, disconnects from the database.
* The next call to getconn will now reinitialize the connection. Sets quit to true and connection to null.
* appQuit might also be set to true if the database says another process has been started.
*/
void quitConnection()
{
	PGresult* res;
	const char* params[1];

	if(connection)	//note that we dont call getconn becuse getconn will initialize it if its not already initiailzed
	{
		printf("Quiting\n\n\n\n");
		params[0] = pid;
		res = PQexecParams( connection, "select epics.checkpid($1::bigint)", 1, NULL, params, NULL, NULL, 1);
		if(PQresultStatus(res) == PGRES_TUPLES_OK)
		{
			if(PQgetisnull(res, 0, 0))
			{
				/* app should quit now, database has a new slave. */
				printf("Got app quit\n");
				appQuit = 1;
			}
		} else {
			printf("checkpid failed status: %s message: %s\n", PQresStatus(PQresultStatus(res)), PQresultErrorMessage(res));
		}
		PQclear(res);
	}

	connection = NULL;
	quit = 1;
}

/**
* Check the return value to make sure it is legal.
* If the result was bad, clears res and calls quitConnection().
*
* @param res Result to check.
* @return 0 if everying is ok, 1 if there was an error.
*/
char checkReturn(PGresult* res, const char* funcName) {
	int result;

	result = PQresultStatus(res);
	if(result == PGRES_NONFATAL_ERROR || result == PGRES_FATAL_ERROR)
	{
		printf("Return failed func: %s status: %s message: %s\n",
					 funcName, PQresStatus(PQresultStatus(res)), PQresultErrorMessage(res));
		PQclear(res);
		quitConnection();
		return 1;
	}

	return 0;
}

/**
* Updates the database.
*
* @param index Index of the process variable to update.
* @param value New value of the varaible.
*/
void ls_update(int index, const char* value) {
	static char buffer[512];
	const char* params[3];
	PGresult* res;

	if( quit)
	{
		return;
	}

	sprintf(buffer, "%i", index);

	params[0] = pid;
	params[1] = buffer;
	params[2] = value;

	if(strlen(value))
	{
		printf("aselect epics.pvupdatevalue(%s, %s, %s)\n", params[0], params[1], params[2]);
		res = PQexecParams(connection, "select epics.pvupdatevalue($1::bigint,$2::int,$3)", 3, NULL, params, NULL, NULL, 0);
	} else {
		printf("bselect epics.pvupdatevalue(%s, %s, null)\n", params[0], params[1]);
		res = PQexecParams(connection, "select epics.pvupdatevalue($1::bigint,$2::int,null)", 2, NULL, params, NULL, NULL, 0);
	}
				
	if(checkReturn(res, "epics.pvupdatevalue"))
	{
		return;
	}

	PQclear(res); /* not interested in the result. */
}

/**
* Convert a dbr value to a double.
*
* @param value Value array.
* @param type Type of value.
* @param index Index in the array.
* @return value[index] as a double or 0 if unable to convert.
*/
double val2d(const void* value, unsigned int type, int index) {
	unsigned int base_type;
	void* value_ptr;

	if(!dbr_type_is_valid(type))
		return 0;
				
	base_type = type % (LAST_TYPE+1);
	value_ptr = dbr_value_ptr(value, type);
	switch(base_type) {
	case DBR_FLOAT:
		return ((dbr_float_t*)value_ptr)[index];
	case DBR_DOUBLE:
		return ((dbr_double_t*)value_ptr)[index];
	case DBR_CHAR:
		return ((dbr_char_t*)value_ptr)[index];
	case DBR_INT:
		return ((dbr_int_t*)value_ptr)[index];
	case DBR_LONG:
		return ((dbr_long_t*)value_ptr)[index];
	default:
		/* don't know how to convert to a double, return 0 as default. */
		return 0.0;
	}
}

/**
* Updates the state of a pv.
* Should be called whenever the process variable is update. pvArrayLock must be locked before calling.
*/
void ls_updatepv(pv* mpv) {
	double curVal;
	double delta;

	if(quit)
	{
		return;
	}

	if(mpv->delta >= 0)	//if delta is less than 0, the database does not want the pv updated
	{
		/* check to see if we need to update. */
		curVal = val2d(mpv->value, mpv->dbrType, 0);

		if(mpv->lastValueInit)
		{
			delta = fabs(curVal - mpv->lastValue);

			if(delta < mpv->delta)	//probably just noise
			{
				return;
			}
		
			mpv->lastValue = curVal;	//we have a new current value
		} else {
			/* Initialize lastValue. */
			mpv->lastValue = curVal;
			mpv->lastValueInit = 1;
		}
	} else {
		//delta was illegal
		return;
	}

	/* update the value in the database. */
	//ls_update( getconn(), mpv->index, val2str(mpv->value, mpv->dbrType, 0));
	ls_update( mpv->index, val2str(mpv->value, mpv->dbrType, 0));
}

/**
* Initializes pvArray.
*/
void initialize_pgdb()
{
	PGresult* res;
	int i, value, returncode;
	const char* params[1];
	int sz;

	if(quit)
	{
		return;
	}

	getconn();
	params[0] = pid;
	printf("pid: %s\n", params[0]);
	res = PQexecParams( getconn(),
		"select index, name, delta, dtime from epics.getpvnames($1::bigint)",
		1, NULL, params, NULL, NULL, 0);

	if(checkReturn(res, "epics.getpvnames"))
	{
		return;
	}

	/* Create the pvArray. */
	pvArray = calloc(PQntuples(res), sizeof(pv));
	pvArraySize = PQntuples(res);

	//put the database response in the pvArray
	for(i = 0; i < pvArraySize; i++)
	{
		//the first result might not be index 0, so we need to get its index from the result
		value = atoi(PQgetvalue(res, i, 0));
		if(value < 0 || value >= pvArraySize)
		{
			printf("index %i is illegal", value);
			PQclear(res);
			quitConnection();
			return;
		}
		
		pvArray[value].index = value;
		sz = strlen( PQgetvalue( res, i, 1)) + 1;
		pvArray[value].name = malloc(sz);
		strcpy(pvArray[value].name, PQgetvalue(res, i, 1));
		pvArray[value].name[sz-1] = 0;
		pvArray[value].delta = atof(PQgetvalue(res, i, 2));
		pvArray[value].deltaTime = atof(PQgetvalue(res,i, 3)) * 1000;	//we get sent time in seconds, we need it in milliseconds
		pvArray[value].lastSent = 0;
		pvArray[value].lastValueInit = 0;
		pvArray[value].onceConnected = 0;
		
		printf("pv(%i): %s   delta: %f  dTime: %ld\n", value, pvArray[value].name, pvArray[value].delta, pvArray[value].deltaTime);
	}

	//we are done with the database result, clean it up
	PQclear(res);

	/* Initialize pvArray and wait for them to connect. */
	returncode = create_pvs(pvArray, pvArraySize, connection_handler);
	if(returncode)
	{
		printf("Failed to create pvs(%i)", returncode);
		quitConnection();
		return;
	}

	printf("Before pend_event\n");
	ca_pend_event(LS_INIT_TIMEOUT);
	printf("After pend_event\n");
				
	/* Make sure pvs have connected successfuly, if they have not log the error. */
	for(i = 0; i < pvArraySize; i++)
	{
		if(!pvArray[i].onceConnected)
		{
			printf("Failed to initialize pv(%i): %s\n", i, pvArray[i].name);
		}
	}
}

/**
* Check for runqueue updates.
*/
void ls_checkRunqueue()
{
	PGresult* res;
	const char* params[1];
	char* value;
	int i, index, ret;
				
	if(quit)
	{
		return;
	}

	//	printf( "in ls_checkRunqueue\n");

	params[0] = pid;
	res = PQexecParams( connection,
		"select index, value from epics.popputqueue($1::bigint)",
		1, NULL, params, NULL, NULL, 0);

	if(checkReturn(res, "epics.poprunqueue"))
	{
		return;
	}

	/* Send each command to the motors. */
	for(i = 0; i < PQntuples(res); i++)
	{
		index = atoi(PQgetvalue(res, i, 0));
		if(index >= pvArraySize)
		{
			/* Quit if the index is illeal the pvArray has been changed on the server side. */
			PQclear(res);
			quitConnection();
			return;
		}
		value = PQgetvalue(res, i, 1);
		printf("moving %s (index %i got %s) to %s\n", pvArray[index].name, index, PQgetvalue(res, i, 0), value);
		ret = ca_put(DBR_STRING, pvArray[index].chid, value);
		if( ret != ECA_NORMAL)
		{
				printf("caput failed on type %s because of %i\n", pvArray[i].name, ret);
		}
	}
	ca_flush_io();
	PQclear( res);
}

/**
* Converts a timespec to milliseconds.
*/
long ls_clocktomilli(struct timespec spec) {
  return (long)(spec.tv_sec * 1000L + spec.tv_nsec / 1000000L);
}

/**
* Updates pvs that need to because they have pased their delta time.
* pvArrayLock must be locked before calling.
*/
void ls_checkDeltaTime()
{
	struct timespec spec;
	long currentTime;
	int i;

	clock_gettime(CLOCK_REALTIME, &spec);
	currentTime = ls_clocktomilli(spec);
	for(i = 0; i < pvArraySize && !quit; i++)
	{
		//only update if deltaTime is enabled, the last value has been initialized, we have gone passed the delta time, and the value has changed
		if( pvArray[i].deltaTime >= 0 &&
        pvArray[i].lastValueInit &&
        pvArray[i].lastSent + pvArray[i].deltaTime <= currentTime &&
			  val2d(pvArray[i].value, pvArray[i].dbrType, 0) != pvArray[i].lastValue)
		{
			//updates the database
			ls_update( pvArray[i].index, val2str(pvArray[i].value, pvArray[i].dbrType, 0));
			pvArray[i].lastSent = currentTime;
		}
	}
}

/**
* Runs until quit is set to true.
* first calls initialize_pgdb, then listens for databse changes. Also calls ls_checkDeltaTime.
*/
void ls_run()
{
	PGnotify* notify;
	PGresult* res;
	fd_set readfds;
	struct timeval st;

	initialize_pgdb();		/* Initialize pvs. */

	while(!quit)
	{
		//set up the socket to listen for database commands on
		FD_ZERO(&readfds);
		FD_SET( PQsocket( connection), &readfds);
		st.tv_usec=100000;	//keep a timeout so we can call ls_checkDeltaTime every now and then
		st.tv_sec=0;
		select(PQsocket( connection)+1, &readfds, NULL, NULL, &st);

		sem_wait(&pvArrayLock);	//make sure data does not change while talking to the database
		ls_checkDeltaTime();

		//service runqueue events if we haven't quit yet and the socket actual has something new
		if(!quit && FD_ISSET(PQsocket(connection), &readfds))
		{
			PQconsumeInput(getconn());
			notify = PQnotifies(getconn()); 
			if(notify != NULL)
			{
				printf("In Notify\n");
				PQfreemem(notify);
				while(notify = PQnotifies( connection))
				{
					PQfreemem(notify);
				}

			}
		}
		ls_checkRunqueue();
		sem_post(&pvArrayLock);	//done talking to the database
	}
}

int main() {
	int result;

	printf("Started\n");
	//initalize the pvArrayLock semaphore
	//might want to change second param to 0 to indicate the semaphore is local to this process
	if(sem_init(&pvArrayLock, 1, 1) < 0)
	{
		printf("Fatal error, failed to create the pvArrayLock semaphore");
		return 1;
	}

	//forces enums to be returned as integers, not strings
	enumAsNr=1;

	//app loop
	while(!appQuit)
	{
		quit = appQuit;			/* Starting over again, clear quit. */
		result = ca_context_create(ca_enable_preemptive_callback);
		if (result == ECA_NORMAL)
		{
			printf("New run\n");
			ls_run();
			ca_context_destroy();			/* stop backround threads. */
			/* Closes and dealocates connection. */
			PQfinish(connection);

			/** free memory. */
			if(pid != NULL)
			{
				free(pid);
				pid = NULL;
			}
			if(pvArray)
			{
				free(pvArray);
				pvArray = NULL;
			}
		} else {
			fprintf(stderr, "CA error %s occurred while trying to start channel access.\n", ca_message(result));
		}
	}

	//done with the semaphore
	sem_destroy(&pvArrayLock);

	return 0;
}
