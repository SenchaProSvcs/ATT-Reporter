module AttApi::MMSv2

  def run_mms_messaging_outbox(test_result)
    mimeContent = MiniMime.new
    mimeContent.add_content({
      :type => 'application/json', 
      :content => '{ "Address" : "tel:' + @config['tel'] + '", "Subject" : "image file", "Priority": "High" }'
    })
    mimeContent.add_content({
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
    test_result.data    = mimeContent.content
    test_result.headers = {
      "Accept"            => "application/json",
      "Authorization"     => "{auth_token}",
      "Content-Type"      => mimeContent.header
    }
    
    return generic_api_test test_result
  end

end