jenv: the Java enVironment Manager
=======================================
jenv is a tool for managing parallel Versions of Java Development Kits on any Unix based system.
It provides a convenient command line interface for installing, switching, removing and listing Candidates.

Please report any bugs and feature request on the [GitHub Issue Tracker](https://github.com/linux-china/jenv/issues).

## Why jenv
   * Easy to manage Java version, such as 1.6, 1.7 and 1.8
   * Easy to install java related tools, such as ant, maven, tomcat etc.
   * Easy to manager candidate version. Install new version and uninstall the old one.
   * Directory is standard, and friendly to IDE
   * Easy to extend. You can setup your own jenv on your company to manage development environment.

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

## Other Commands
  * use: Use the candidate with the version, such as jenv use maven 3.0.4
  * default: Make the version as default, such as jenv default maven 3.0.4
  * cd: change directory to candidate install directory, such as jenv cd groovy
