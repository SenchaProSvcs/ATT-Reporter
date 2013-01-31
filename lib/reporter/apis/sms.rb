module AttApi::SMS
  
  def run_sms_messaging_outbox(test_result)
    test_result.url     = "https://api.att.com/rest/sms/2/messaging/outbox"
    test_result.verb    = "POST"
    test_result.data    = {
        "Address" => "tel:{telephone}",
        "Message" => "Test ATT API"
    }
    test_result.headers = {
      "Accept" =>         "application/json",
      "Authorization" =>  "{auth_token}",
      "Content-Type" =>   "application/json"
    }
    
    result = generic_api_test test_result
    data = JSON.parse(@agent.page.body)
    
    # save document for other tests
    @sms_id = data['Id']
    
    return result
  end
  
  def run_sms_get_status(test_result)
    
    if @sms_id.nil?
      raise 'Send SMS API must run before'
    end
    
    test_result.url     = "https://api.att.com/rest/sms/2/messaging/outbox/#{@sms_id}"
    test_result.verb    = "GET"
    test_result.headers = {
      "Accept"            => "application/json",
      "Authorization"     => "{auth_token}"
    }
    
    generic_api_test test_result
  end

end