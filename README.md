# StarscreamCrash

This project attempts to replicate a crashing queue-overcommit error which we 
encountered on a production project.  The problem is somewhat non-deterministic 
but does appear to happen most consistently when Starscream is used to make a 
connection attempt over ws and then later used to make a new connection attempt 
over wss.

As of this writing, master is Swift 2.3 (as is the project where the bug was
discovered) while a `swift3` branch exists to determine whether the bug still
exists in the newest version of Starscream (it does).

## Installation
1. Clone this repo
2. Run `pod install` in the project root directory


