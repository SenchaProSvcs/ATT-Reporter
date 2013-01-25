module AttApi::SMS

  private

  ###
  # SMS Send
  # DOCS: Requires that Accept-Encoding is set, should be just Accept
  ##
  def api_v2sms_send_form
    log "Sending SMS to #{@config['tel']}"
    data =  { :Address => "tel:#{@config['tel']}", :Message => 'Works from SENCHA 2'};
    url = "#{@config['api_host']}/rest/sms/2/messaging/outbox?access_token=#{@oauth_token}"
    log_error "Sending SMS to #{data}"
    log_error url
    response = simple_form_post(url, data)
    log_error "response #{response}"
    log "Sent SMS"
    
    if(!response)
      return "FAILED"
    end
    
    @sms_status_url = response['ResourceReference']['resourceURL']
    @sms_id = response['Id']
    return "OK"
  end

  def api_v2sms_send_json
    
    data = "{'Address' => 'tel:#{@config['tel']}', 'Message' => 'Works from SENCHA api v2'}";
    url = "#{@config['api_host']}/rest/sms/2/messaging/outbox?access_token=#{@oauth_token}"
    log_error "Sending SMS to #{data}"
    log_error url
    response = simple_json_post(url, data)
    log "Sent SMS"
    pp response
    
    log_error "response #{response}"
    
    if(!response)
      return "FAILED"
    end
        
        
    @sms_status_url = response['ResourceReference']['resourceURL']
    @sms_id = response['Id']
    return "OK"
  end


  ###
  # SMS Status
  ##
  def api_v2sms_status
#


    url = "#{@config['api_host']}/rest/sms/2/messaging/outbox/#{@sms_id}?access_token=#{@oauth_token}"
     log_error "Request: #{url}"

    begin
      log "Getting SMS Status for #{@sms_id}"
      page = @agent.get(url)
      log "Sent status request"
      log_error JSON.pretty_generate(JSON.parse(page.body))
    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
       return "FAILED"
    end
    return "OK"
  end

  ###
  # SMS Receive
  ##
  def api_v2sms_receive

    url = "#{@config['api_host']}/2/messages/inbox/sms?access_token=#{@oauth_token}&registrationID=#{@config['short_code']}&format=json"

    log "Requesting SMS inbox..."
    log_error "Request:  #{url} ..." if @debug >= AttApiReporter::DEBUG_INFO
    begin
      page = @agent.get(url)
      log "Sent SMS"
      puts "OK"
      log_error JSON.pretty_generate(JSON.parse(page.body))
    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
       return "FAILED"
    end
    return "OK"
  end

end