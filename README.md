# Storyboard_Go


Environment
===========

export PATH=$HOME/Flutter/flutter/bin:/usr/local/go/bin:$HOME/go/bin:$PATH
export CGO_ENABLED=1

UI TEST
=======

SINGLE TEST
-----------

flutter test [file]

COVERAGE
--------

flutter test --coverage
/usr/local/bin/genhtml coverage/lcov.info -o coverage/html