jenv: the Java enVironment Manager
=======================================
jenv is a tool for managing parallel Versions of Java Development Kits on any Unix based system.
It provides a convenient command line interface for installing, switching, removing and listing Candidates.

Please report any bugs and feature request on the [GitHub Issue Tracker](https://github.com/linux-china/jenv/issues).

## Installat jenv

Open your favourite terminal and enter the following:

    $ curl -s get.jvmtool.mvnsearch.org | bash

If the environment needs tweaking for jenv to be installed, the installer will prompt you accordingly and ask you to restart.

## Install tools

First view all available candidates:

    $ jenv candidates

Second list available version for the candidate, such as maven candidate:

    $ jenv list maven

Final install the candidate with the version:

    $ jenv install maven 3.0.4
In your terminal, input mvn --version to check the installation.

