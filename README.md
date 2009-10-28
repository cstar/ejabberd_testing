ejabberd_testing
================

Objective
----------

This code is more of a testing strategy than direct usable code. The point was to test the `etap`/`erl_mock` combination for testing ejabberd modules.
Also included as a small bonus a Rakefile used for building and installing ejabberd modules.


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

A few notes and caveats
------------------------
I guess the meat of this project is here, within those bullet points (but do give a look to the [test file](http://github.com/cstar/ejabberd_testing/blob/master/t/t01_echo.t))

* Most of the time, mocking `ejabberd_router` is the only thing you will need to do.

* `stringprep` must be started if you want to use jlib and manipulate jids, which you will.

* Don't forget to start mnesia/configure mnesia if necessary.

* `mock:calls()` empties the mock call lists.

* **Very important** : `timer:sleep(100)` in the test code after sending a message to the module. Or else the test will be ran before the call to the mock module is completed. Been bit by this one, and it stings.

* Wrote a lot of LOCs for just testing `mod_echo`. I was initially hoping for something more compact. But mod_echo was not written with automated testing in mind. So my testing is quite contrived — especially in the end. There is a single modification to the ejabberd `mod_echo`, the ability to set the version check in `ejabberd.cfg`

* I guess a couple of helper library could be extracted for building manipulation stanzas. But with exmpp around the corner, I wouldn't invest to much time on the existing jlib/xml ejabberd lib.


How to mock properly with erlang
--------------------------------

[Charpi](http://github.com/charpi/), `erl_mock`'s author, does not recommend the use of `erl_mock`.  
The good, sanctionned way is to swap the pid of the "mocked" objects by the mock itself using a reverse Jedi mind trick : "This is the processes you are looking for".
But that implies your library make this easy.

Final words
------------
Is this testing strategy valid ?
I think so. I have been able to test the capabilities of `mod_echo` which was not written with testing in mind.
I expect this strategy to fare better test-friendly code.

Help appreciated
----------------

If you spot a better (or more elegant) way to  test the code, do send it my way.

License
-------
GPL for mod_echo. 
BSD for my own code.

Author
------
mod_echo.erl by Alexey Shchepin  
test code and Rakefile by [Eric Cestari](http://www.cestari.info)
