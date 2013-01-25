###
# Device Location
##

module AttApi::DeviceLocation
  private

  def api_device_location_json
    log "Device location for #{@config['tel']} (json)"
    url = "#{@config['api_host']}/1/devices/tel:#{@config['tel']}/location?requestedAccuracy=1000&access_token=#{@oauth_token}"
    log_response url
    response = simple_get_json(url)
    if(!response) 
      return "FAILED"
    end
    log "Got device location"
    return "OK"
 end

  def api_device_location_json_error
    puts "Device location for #{@config['tel']} (json)"
    response = simple_get_json("#{@config['api_host']}/1/devices/tel:123/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end
  

  def api_device_location_jsonp
    puts "Device location for #{@config['tel']} (jsonp)"
    response = simple_get_jsonp("#{@config['api_host']}/1/devices/tel:#{@config['tel']}/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(!response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end

  def api_device_location_jsonp_error
    puts "Device location for #{@config['tel']} (jsonp)"
    response = simple_get_jsonp("#{@config['api_host']}/1/devices/tel:123/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end
  

  def api_device_location_xml
    puts "Device location for #{@config['tel']} (xml)"
    response = simple_get_xml("#{@config['api_host']}/1/devices/tel:#{@config['tel']}/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(!response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end

  def api_device_location_xml_error
    puts "Device location for #{@config['tel']} (xml)"
    response = simple_get_xml("#{@config['api_host']}/1/devices/tel:123/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end

 end