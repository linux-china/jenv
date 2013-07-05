jenv: the Java enVironment Manager
=======================================
jenv is a tool for managing parallel Versions of Java Development Kits on any Unix based system.
It provides a convenient command line interface for installing, switching, removing and listing Candidates.

## Why jenv
   * Easy to manage Java version, such as 1.6, 1.7 and 1.8
   * Easy to install java related tools, such as ant, maven, tomcat etc.
   * Easy to manager candidate version. Install new version, reinstall or uninstall the old one.
   * Directory is standard, and friendly to IDE
   * Easy to extend. You can setup your own jenv on your company to manage development environment.
   * Easy to backup your env.
   * Bash completion support. Use TAB to complete command name, candidate name and version
   * Multi OS support, such as Mac, Linux and Windows(Cygwin)

## Installat jenv

Open your favourite terminal and enter the following:

    $ curl -L -s get.jenv.io | bash

If the environment needs tweaking for jenv to be installed, the installer will prompt you accordingly and ask you to restart.

## Install Java
Because I can not redistribute Java SDK, so you should download it from http://www.oracle.com/technetwork/java/javase/downloads/index.html
and install. After install please execute following command:

    $ mkdir -p $HOME/.jenv/candidates/java
    $ ln -s /Library/Java/JavaVirtualMachines/jdk1.7.0_17.jdk/Contents/home $HOME/.jenv/candidates/java/1.7.0_17
    $ jenv default java 1.7.0_17

You can also install Java by http url:

   $ jenv install java 1.7.0_17  http://xxxx.com/java/java-1.7.0_17.zip

## Install canidates

First view all available candidates:

    $ jenv all

Second list available version for the candidate, such as maven candidate:

    $ jenv ls maven

Final install the candidate with the version:

    $ jenv install maven 3.0.5
In your terminal, input mvn --version to check the installation.

If you want to list all installed candidates, please use following command.

    $ jenv ls

### Update repository
All canidate versions are maintained on central repository. To keep updated with central repository, please use:

    $ jenv repo update

## Other Commands

  * uninstall: Uninstall the candidate with the version, such as jenv uninstall maven 3.0.4
  * reinstall: Reinstall the candidate with the version, such as jenv reinstall maven 3.0.5
  * use: Use the candidate with the version, such as jenv use maven 3.0.4
  * which: Which version for candidate
  * pause: Pause candidate usage
  * exe: Execute script under candidate, such as "jenv execute tomcat startup.sh" or "jenv execute tomee startup.sh"
  * default: Make the version as default, such as jenv default maven 3.0.4
  * cd: Change directory to candidate install directory, such as jenv cd groovy
  * show: Display candidate's detail information
  * requirements: Display jenv requirements

## jenvrc support
jenvrc is jenv setup file which contains candidate and the version as following:

       java=1.6.0_45
       maven=3.0.5
After you enter this directory, jenv will setup environment automatically.
Now You can use jenvrc to setup Java environment for each of your individual projects.

## autorun.sh
autorun.sh is a script under candidate home, and jenv will execute the script automatically. In the autorun.sh, you can update LD_LIBRARY_PATH or create alias.

## Install local candidates
If you want to add custom candidate into jenv, please create candidates_local under $HOME/.jenv/db/ directory and input candidate name.

    $jenv add spike 0.0.1
    $jenv install spike 0.0.1 git@github.com:linux-china/groovy_scripts.git
Then you can install candidate from git repository, and you can update candidate by following command:

    $jenv update spike
If the candidate is absent, jenv will update all git or svn based candidates.

    $jenv update
Update all git or svn based candidates.

## How to update jenv
Please use selfupdate command to get last version and candidate repository.

   $ jenv selfupdate

## jenv IntelliJ IDEA plugin
With jenv IDEA plugin, you don't need to setup Java SDK, Maven, and so on, and jenv IDEA plugin can scan jenv directory
and setup the settings in IDEA automatically. Please visit http://plugins.jetbrains.com/plugin/?idea&pluginId=7229
