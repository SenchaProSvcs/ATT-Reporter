module AttApi::MMSv2

  def run_mms_messaging_outbox
    mimeContent = MiniMime.new
    mimeContent.add_content({
      :type => 'application/json', 
      :content => '{ "Address" : "tel:' + @tel + '", "Subject" : "image file", "Priority": "High" }'
    })
    mimeContent.add_content({
      :type => 'image/jpeg',
      :content_id => '<mms.jpg>',
      :content => Base64.encode64(File.read('apis/mms.jpg')),
      :headers => {
         'Content-Transfer-Encoding' => 'base64',
         'Content-Disposition' => 'attachment; name="mms.jpeg"'
      }
    })
    
    return test_api({
      "url"           => "https://api.att.com/rest/mms/2/messaging/outbox",
      "verb"          => "POST",
      "data"          => mimeContent.content,
      "headers"       => {
          "Accept"            => "application/json",
          "Authorization"     => "{auth_token}",
          "Content-Type"      => mimeContent.header
      }
    })
  end
  
  def api_v2mms_status

    url = "#{@baseURL}/rest/mms/2/messaging/outbox/#{@mms_id}?access_token=#{@oauth_token}"
    
    log_error "Request: : #{url}"
    
    begin
      page = @agent.get(url)
      log_error JSON.pretty_generate(JSON.parse(page.body))
      log "Got MMS Status"
    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
      return "FAILED"
    end
    return "OK"  
  end
  

end