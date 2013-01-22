module AttApi::MMS

  private

  def api_mms_send_json

    mimeContent = MiniMime.new

    mimeContent.add_content(
      :type => 'application/json', 
      :content => '{ "address" : "tel:' + @tel + '", "subject" : "image file", "priority": "High" }'
    )
   

    mimeContent.add_content(
      :type => 'image/jpeg',
      :headers => {
         'Content-Transfer-Encoding' => 'base64',
         'Content-Disposition' => 'attachment; name="mms.jpeg"'
      },
      :content_id => '<mms.jpg>',
      :content => Base64.encode64(File.read('apis/mms.jpg'))
    )
    
    log "Sending MMS to #{@tel}"
    
    url = "#{@baseURL}/1/messages/outbox/mms?access_token=#{@oauth_token}"
    
    log_error "Sending MMS to #{@tel}"
    log_error url
    response = simple_json_post(url, mimeContent.content, 'Content-Type' => mimeContent.header)
    log "Sent MMS"

      if(!response) 
        return "FAILED"
      end

    @mms_status_url = response['resourceReference']['resourceURL']
    @mms_id = response['id']
    return "OK"
  end
  
  def api_mms_status

    url = "#{@baseURL}/1/messages/outbox/mms/#{@mms_id}?access_token=#{@oauth_token}"
    
    log_error "Request: : #{url}"
    
    begin
      page = @agent.get(url)
      log_error JSON.pretty_generate(JSON.parse(page.body))
      log "Got MMS Status"
    rescue Exception => e
      log_error e.backtrace
      return "FAILED"
    end
    return "OK"  
  end
  

end