*60 seconds: this all you need to get Emacs up and ready for your Python projects.*


Overview
========

A dream is now true: The first time you start Emacs, it *automagically* downloads and configures all plugins you need.  Emacs is then just ready to work and you can start typing code immediately.


For the impatient
=================

1. Save configuration files you eventually have!

::

    $ cd $HOME 
    $ tar cpf dot-emacs.ORIGINAL.tar.gz .emacs .emacs.d
    $ mv .emacs   dot-emacs.ORIGINAL
    $ mv .emacs.d dot-emacs.d.ORIGINAL

2. Remove any Emacs configuration files you eventually have.

::

    $ rm -r -f .emacs .emacs.d

3. Install Python libraries

This should be done preferably inside a virtual environment.

::

    $ workon py276  #-- py276 is a virtualenv I'm using
    $ pip install epc
    $ pip install jedi
    $ pip install elpy

4. Download my .emacs file onto your home folder.

::

    $ cd $HOME 
    $ wget https://raw.github.com/frgomes/dot-emacs/master/dot-emacs.el
    $ ln -s dot-emacs.el .emacs

4. Start emacs. It will configure itself when it first runs!

::

   $ emacs


Features in a nutshell
======================

* ``python-mode``, ``cython-mode`` and ``nxml-mode``: ditto

* ``jedi``: provides auto completion

* ``flymake``: highlight syntax errors as you type


Contribute
==========

* Please let me know if you find issues. In particular, I don't have Windoze boxes, so the automagic configuration thing was never tested on it.

* This script was designed to run on Emacs 23 onwards but only tested on Emacs 24. Please let me know if you find issues.

* Please point out typos and bad English.

* You can also suggest plugins or tools I missed. This is very much appreciated and may benefit my workflow as well :)


Known Issues
============

If you are behind firewall, you may (or may not) face download problems which involves HTTPS protocol. As far as I know, this is a bug on a third party library which Emacs depends on.

If Emacs opens the message window and vomits hundreds of errors coming from file cython-mode.el ... that's because your proxy server refused the https request and returned an error message in HTML. It's easy to fix this issue:

::

    $ cd $HOME/.emacs.d/plugins
    $ rm cython-mode.el
    $ wget https://raw.github.com/cython/cython/master/Tools/cython-mode.el

Chances are that now ``cython-mode.el`` is OK, since wget performs the request the way it needs to be in order to work properly.
