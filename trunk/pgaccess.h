#ifndef LSCAT_DBTOOLS_H
#define LSCAT_DBTOOLS_H

#include <semaphore.h>
#include <stdio.h>
#include <epicsStdlib.h>
#include <string.h>

#include <cadef.h>
#include <epicsGetopt.h>

#include "tool_lib.h"

/**
* Used to control access to process variables.
* Before chaning a process variable this simaphore MUST be locked.
*/
sem_t pvArrayLock;

/**
* Update the state of the data base.
* Only updates if the new value is diference enough from the old value.
*
* @param mpv Process variable to update.
*/
void ls_updatepv(pv* mpv);

/**
* Initializes pvs.
*/
void initialize_pgdb();

/** Continusly update the database. */
void ls_run();

/** Implemented in camonitor.c. */
void connection_handler ( struct connection_handler_args args );

#endif
