module AttApi::MMSv2

  def run_mms_messaging_outbox(test_result)
    mime_content = MiniMime.new
    mime_content.add_content({
      :type => 'application/json', 
      :content => '{ "Address" : "tel:' + @config['tel'] + '", "Subject" : "image file", "Priority": "High" }'
    })
    mime_content.add_content({
      :type => 'image/jpeg',
      :content_id => '<mms.jpg>',
      :content => Base64.encode64(File.read(File.join(File.dirname(__FILE__), 'mms.jpg'))),
      :headers => {
         'Content-Transfer-Encoding' => 'base64',
         'Content-Disposition' => 'attachment; name="mms.jpeg"'
      }
    })
    
    test_result.url     = "https://api.att.com/rest/mms/2/messaging/outbox"
    test_result.verb    = "POST"
    test_result.data    = mime_content.content
    test_result.headers = {
      "Accept"            => "application/json",
      "Authorization"     => "{auth_token}",
      "Content-Type"      => mime_content.header
    }
    
    result = generic_api_test test_result
    data = JSON.parse(@agent.page.body)
    
    # save document for other tests
    @mms_id = data['Id']
    
    return result
  end
  
  def run_mms_get_status(test_result)
    
    if @mms_id.nil?
      raise 'Send MMS API must run before'
    end
    
    test_result.url     = "https://api.att.com/rest/mms/2/messaging/outbox/#{@mms_id}"
    test_result.verb    = "GET"
    test_result.headers = {
      "Accept"            => "application/json",
      "Authorization"     => "{auth_token}"
    }
    
    generic_api_test test_result
  end

end