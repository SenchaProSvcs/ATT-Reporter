# AT&T API Reporter
Polls AT&T API, gathers the results and displays on a dashboard.

## Installation

### requires ruby
[http://www.ruby-lang.org/en/downloads/](http://www.ruby-lang.org/en/downloads/)

### requires SQLite
See below various ways to install it.

    # Debian / Ubuntu
    sudo apt-get install libsqlite3-dev

    # RedHat / Fedora
    sudo yum install sqlite-devel

    # MacPorts
    sudo port install sqlite3

    # HomeBrew
    sudo brew install sqlite
    
On SQLite everything is saved in a small lightweight file. If you want to browse this file there's an utility software that works great: [http://sourceforge.net/projects/sqlitebrowser/](http://sourceforge.net/projects/sqlitebrowser/)

### requires gem bundler
 
    $ gem install bundler
    
### installing other gems
 
    $ bundle install

## Running

There's 2 main components: the webapp and the poller script. In a terminal window execute the command below to start the webapp.

    $ ruby config/runners/web_app.rb

You can hit the index on [http://127.0.0.1:5985](http://127.0.0.1:5985). 

In another terminal window, start the poller. It will execute and sleep for 1 hour before next execution.

    $ ruby config/runners/api_poller.rb
    
The poller will execute, gather the results, and save everything on a local SQLite database file.

### Running as daemon

You can also run the app as daemon. This is mainly used in our production server.

    $ ruby config/runners/web_app_daemon.rb start
    $ ruby config/runners/api_poller_daemon.rb start
    
As daemon you have easier options to start, stop or reload the processes.

## Deployment

Before start please be advised that the deployment process is pretty manual. You'll need ssh access to our Amazon instance, and also need to build the Ext app for production, making sure everything is on github.

    $ ssh ubuntu@svcdemo.sencha.com
    
After connection stop the processes


    sudo /etc/init.d/att_poller_runner stop
    sudo /etc/init.d/att_web_app_runner stop

Go to the project directory

    $ cd ATT-Poller
    
This directory is actually a git project. So get the new code

    $ git pull
    
And after that, replace the development javascript by production JavaScript:

    $ cp -rf public/build/Reporter/production *.* public/