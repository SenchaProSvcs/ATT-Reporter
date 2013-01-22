### Requirements

    gem install mechanize sinatra oauth2 curb logger haml json

### Run

    ruby test.rb [auth_token]

This will start a sinatra app to handle the authorization callbacks and 
initiate a mechanize script to automate logging in and authorization. If auth_token is
specified, the script use that instead of trying to obtain one.

The sinatra app is not yet used for interacting directly with the APIs - it's main purpose 
is to provide an endpoint for the openID authorization callback and to allow exercising
of other parts of the API that require an HTTP endpoint.

Once an access token has been obtained, API calls can be invoked.
APIs are called automatically inside a sinatra request. Once a response has 
been received, a redirect action passes control to the next action to be tested.

Sign up at http://devconnect-beta-api.att.com/
Ask Christopher Bartsch (CB1118@att.com) / Kham Bui (KB6014@att.com) to add your merchant’s account to the BF role.
