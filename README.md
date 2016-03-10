jenv: the Java enVironment Manager
=======================================

[![Join the chat at https://gitter.im/linux-china/jenv](https://badges.gitter.im/linux-china/jenv.svg)](https://gitter.im/linux-china/jenv?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
jenv is a tool for managing parallel Versions of Java Development Kits on any system, such as Linux, Mac and Windows.
It provides a convenient command line interface for installing, switching, removing and listing candidates.
If you have any problem, please join gitter room: https://gitter.im/linux-china/jenv 

## Why jenv
   * Easy to manage Java versions, such as 1.6, 1.7 and 1.8
   * Easy to install Java related tools, such as ant, maven, tomcat etc.
   * Easy to manage candidate versions. It supports installing new version, reinstalling or uninstalling old ones
   * Directory is standard and friendly to IDE
   * Easy to be extended - you can setup your own jenv in your company to manage development environment
   * Easy to backup your env.
   * Bash completion support. Use TAB to complete command name, candidate name and version
   * Multi OS support, such as Mac, Linux and Windows(Cygwin)

## Installat jenv

Open your favourite terminal and enter the following:

    $ curl -L -s get.jenv.io | bash

If the environment needs tweaking for jenv to be installed, the installer will prompt you accordingly and ask you to restart.

## Install Java
Because I cannot redistribute Java SDK, so you should download it from http://www.oracle.com/technetwork/java/javase/downloads/index.html
and install by yourself. After installation, please execute the following command:

    $ mkdir -p $HOME/.jenv/candidates/java
    $ ln -s /Library/Java/JavaVirtualMachines/jdk1.7.0_45.jdk/Contents/home $HOME/.jenv/candidates/java/1.7.0_45
    $ jenv default java 1.7.0_45

for Mac user, after you install JDK from dmg file, please execute:

   $ jenv install java 1.7.0_45 system

and jenv will link the Java version automatically.

You can also install Java by http url:

   $ jenv install java 1.7.0_17  http://xxxx.com/java/java-1.7.0_17.zip

## Install candidates

Firstly, view all available candidates:

    $ jenv all

Secondly, list available versions for the candidate, such as maven candidate:

    $ jenv ls maven

Finally, install the candidate with the specified version:

    $ jenv install maven 3.3.9

In your terminal, type `mvn --version` to check the installation.

If you want to list all installed candidates, use the following command:

    $ jenv ls

For Docker user, your can use silent mode in your Dockerfile as following:

    $ JENV_AUTO=true; jenv install maven 3.3.9
### Update repository
The candidate's versions are maintained in the central repository. To keep updated with central repository, please use:

    $ jenv repo update

### Clonable development environments with jenv
You can clone your jenv between multiple hosts.

* clone your local jenv to remote host: `jenv clone user@remote-host`
* clone your local candidate to remote host:  `jenv clone candidate version user@remote-host`
* clone candidate from remote host: `jenv clone user@remote-host canidate version`

## Other Commands

  * `uninstall`: Uninstall the candidate with the version specified, such as `jenv uninstall maven 3.0.4`
  * `reinstall`: Reinstall the candidate with the version specified, such as `jenv reinstall maven 3.0.5`
  * `use`: Use the candidate with the version specified, such as `jenv use maven 3.0.4`
  * `which`: Check which version for candidate
  * `pause`: Pause candidate usage
  * `exe`: Execute script under candidate, such as `jenv execute tomcat startup.sh` or `jenv execute tomee startup.sh`
  * `default`: Make the version as default, such as `jenv default maven 3.0.4`
  * `cd`: Change directory to candidate install directory, such as `jenv cd groovy`
  * `show`: Display the candidate's detailed information
  * `requirements`: Display jenv requirements

## jenvrc support
jenvrc is jenv setup file which contains candidate and the version as following:

       java=1.6.0_45
       maven=3.0.5
After you enter this directory, jenv will setup environment automatically.
Now You can use jenvrc to setup Java environment for each of your individual projects.
You can use jenv init to generate jenvrc file.

      $jenv init
Note:  Line started with # means line comment.

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

## Reference

* Shell Code Style: http://google-styleguide.googlecode.com/svn/trunk/shell.xml

### TODO

* jenv outdated: display outdated candidates
* broadcast: broadcast message