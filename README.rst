PWND.SH
=======

pwnd.sh is a post-exploitation framework (and an interactive shell) developed in Bash shell scripting. It aims to be cross-platform (Linux, Mac OS X, Solaris etc.) and with little to no external dependencies.

Slides from SkyDogCon 2016 are `available here <http://www.ikotler.org/JustGotPWND.pdf>`_


Install:
--------

.. code::

  $ cd bin/
  $ ./compile_pwnd_sh.sh

This will generate a file called ``pwnd.sh``

.. code::

  $ ls -la pwnd.sh
  -rw-r--r--@ 1 ikotler  staff  7823 Oct 19 16:55 pwnd.sh

Now let's get pwnd!

.. code::

  $ source pwnd.sh
  Pwnd v1.0.0, Itzik Kotler (@itzikkotler)]
  Type `help' to display all the pwnd commands.
  Type `help name' to find out more about the pwnd command `name'.

  (pwnd)$

Tested:
-------

* Mac OS X El Captian (10.11.3) using GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin15)
* Ubuntu 14.04.3 LTS using GNU bash, version 4.3.11(1)-release (x86_64-pc-linux-gnu)
* Oracle Solaris 11.3 X86 using GNU bash, version 4.1.17(1)-release (i386-pc-solaris2.11)

Features/Bugs:
--------------

Found a bug? Have a good idea for improving PWND.SH? Head over to `PWND.SH's github <https://github.com/safebreach-labs/pwndsh>`_ page and create a new ticket or fork. If you want to contact us please email: labs (at) safebreach (dot) com.

License:
--------

BSD 3-Clause
