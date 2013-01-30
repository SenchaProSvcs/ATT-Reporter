require 'csv'

module AttApi::Oauth
  
  ###
  # This method executes the OAuth flow for getting End User Authorization
  # - Go to OAuth landing page
  # - Click on 'Sign In' to go to Sign In Page
  # - Fill username, password and submit
  # - On the resulting page, click on 'Close Window' to fire redirect URI
  ###
  def run_oauth_authorize(test_result)
    @oauthCsv = [Time.now.to_f] #start_time
    
    # connect to oauth
    page = @agent.get "#{@config['api_host']}/oauth/authorize?scope=TL,DC,WAP,SMS,MMS,PAYMENT&client_id=#{@config['api_key']}&redirect_uri=#{@config['local_server']}:#{@config['port']}/auth/callback"

    if page.code != "200"
      raise "Error connecting to authentication website"
    end
    
    # find link to sign in
    link = @agent.page.link_with :text => /Sign In/i
    
    if link.nil?
      raise "Unable to find Sign In link. The webpage could have changed."
    end
    
    # get sign in page
    page = @agent.click link
    
    if page.code != "200"
      raise "Error connecting to sign in website"
    end
    
    search_form = page.forms[0]
    username_field = search_form.field_with(:name => "login[username]") unless search_form.nil?
    password_field = search_form.field_with(:name => "login[password]") unless search_form.nil?
    link = @agent.page.link_with :text => /allow/i
    
    if search_form.nil? || username_field.nil? || password_field.nil? || link.nil?
      raise "Unable to find 'username' field, 'password' field or 'allow' link"
    end
    
    # fill user data
    username_field.value = @config['user_id']
    password_field.value = @config['password']
    
    # submit
    page = @agent.submit search_form
    
    if page.code != "200"
      raise "Error connecting to sign in website"
    end
    
    link = page.link_with :text => /close window/i
    
    if link.nil?
      raise "Unable to find 'Close Window' link"
    end

    # extract auth code for next test
    @auth_code = link.uri.to_s.gsub(/.*code=/,'').gsub(/&.*/,'')
    
    return TestResult::PASSED
  
  rescue Exception => e
    @authorize_failed = true
    raise e
  end
  
  ###
  # This method executes the OAuth flow for getting the Access Token
  # - Go to OAuth landing page
  # - Click on 'Sign In' to go to Sign In Page
  # - Fill username, password and submit
  # - On the resulting page, click on 'Close Window' to fire redirect URI
  ###
  def run_oauth_token(test_result)
    @oauthCsv << Time.now.to_f #oauth_authorize time
    
    # request access token
    url = "#{@config['api_host']}/oauth/token"
    data = {
      :grant_type =>     'authorization_code',
      :client_id =>      @config['api_key'],
      :client_secret =>  @config['secret_key'],
      :code =>           @auth_code
    }
    headers = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
    page = @agent.post(url, data, headers)
    
    if page.code != "200"
      raise "Error fetching access token"
    end
    
    response = JSON.parse(page.body)
    @oauth_token   = response['access_token']
    @oauth_refresh = response['refresh_token']
    
    puts "    OAuth Token #{@oauth_token}"
    
    return TestResult::PASSED

  rescue Exception => e
    @authorize_failed = true
    raise e
  end

end