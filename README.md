# jenv: the Java enVironment Manager

jenv is a tool for managing parallel Versions of multiple Software Development Kits on any Unix based system.
 It provides a convenient command line interface for installing, switching, removing and listing Candidates.

See documentation on the [jenv Project Page](http://jvmtool.mvnsearch.org).

Please report any bugs and feature request on the [GitHub Issue Tracker](https://github.com/linux-china/jenv/issues).

## Installation

Open your favourite terminal and enter the following:

    $ curl -s get.jvmtool.mvnsearch.org | bash

If the environment needs tweaking for jenv to be installed, the installer will prompt you accordingly and ask you to restart.

### Making the Local Installation the Default

To make your local jenv installation work with your local server, run the following commands:

	$ ./gradlew install
	$ source ~/.jenv/bin/jenv-init.sh


