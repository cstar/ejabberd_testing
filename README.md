ejabberd_testing
================

Objective
----------

I wrote this project to test how I can test automatically my ejabberd custom modules.
Also included as a small bonus a Rakefile used for building and installing ejabberd modules


Dependencies
------------

 * [etap](http://github.com/ngerakines/etap): erlang library implementing the TAP protocal

 * [erl_mock](http://github.com/charpi/erl_mock): simple mocking of erlang modules.
 	
 * [ejabberd](http://github.com/processone/ejabberd/): the erlang XMPP server

 * rake: Ruby rake, for building the project (most likely already installed on your system)


Running the tests
-----------------

Once you've installed all the libraries and have ejabberd deployed (but not necessarily running).

Set the following environnement variables : 

 * ERL_TOP: pointing to your erlang install (`/usr/local/lib/erlang`)
 * EJABBERD_INSTALL: pointing to your ejabberd install (`/opt/ejabberd`)

Also edit the line in the test file `t01_echo.t` the `-pz` parameter to point to the `ebin` directory for ejabberd
Once it's done :

	$ rake test

You can also deploy your modules to the ejabberd install by :

  $ rake install

A few notes
-----------

Most of the time, mocking `ejabberd_router` is the only thing you will need to do.

`stringprep` must be started if you want to use jlib and manipulate jids.

`mock:calls()` empties the mock call lists

**Very important** : `timer:sleep(100)` in the test code after sending a message to the module. Or else the test will be ran before the call to the mock module is completed. Been bit by this one, and it stings.

Wrote a lot of LOCs for just testing `mod_echo`. I was initially hoping for something more compact. But mod_echo was not written with automated testing in mind. So my testing is quite contrived — especially in the end. There is a single modification to the ejabberd `mod_echo`, the ability to set the version check in `ejabberd.cfg`

I guess a couple of helper library could be extracted.

Help appreciated
----------------

If you spot a better (or more elegant) way to  test the code, do send it my way.

License
-------
GPL for mod_echo.
BSD for my own code

Author
------
mod_echo.erl by Alexey Shchepin  
test code and Rakefile by [Eric Cestari](http://www.cestari.info)
