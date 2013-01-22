###
# Device Location
##

module AttApi::DeviceLocation
  private

  def api_device_location_json
    log "Device location for #{@tel} (json)"
    url = "#{@baseURL}/1/devices/tel:#{@tel}/location?requestedAccuracy=1000&access_token=#{@oauth_token}"
    log_response url
    response = simple_get_json(url)
    if(!response) 
      return "FAILED"
    end
    log "Got device location"
    return "OK"
 end

  def api_device_location_json_error
    puts "Device location for #{@tel} (json)"
    response = simple_get_json("#{@baseURL}/1/devices/tel:123/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end
  

  def api_device_location_jsonp
    puts "Device location for #{@tel} (jsonp)"
    response = simple_get_jsonp("#{@baseURL}/1/devices/tel:#{@tel}/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(!response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end

  def api_device_location_jsonp_error
    puts "Device location for #{@tel} (jsonp)"
    response = simple_get_jsonp("#{@baseURL}/1/devices/tel:123/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end
  

  def api_device_location_xml
    puts "Device location for #{@tel} (xml)"
    response = simple_get_xml("#{@baseURL}/1/devices/tel:#{@tel}/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(!response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end

  def api_device_location_xml_error
    puts "Device location for #{@tel} (xml)"
    response = simple_get_xml("#{@baseURL}/1/devices/tel:123/location?requestedAccuracy=1000&access_token=#{@oauth_token}")
    if(response) 
      return "FAILED"
    end
    log "Got device location"
  	return "OK"
 end

 end