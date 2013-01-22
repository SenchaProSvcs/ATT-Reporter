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

    ruby web_app.rb

You can hit the index on [http://127.0.0.1:5985/index.html](http://127.0.0.1:5985/index.html). 

In another terminal window, start the poller. It will execute and sleep for 1 hour before next execution.

    ruby test_runner.rb
    
The poller will execute, gather the results, and save everything on a local SQLite database file.    