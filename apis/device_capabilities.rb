module AttApi::DeviceCapabilities
  private
    def api_device_capabilities
      test_api({
        group: "Device Capabilities",
        name: "Get Device Capabilities",
        url: "https://api.att.com/rest/2/Devices/Info",
  	    verb: "GET",
        authorization: true,
        accept: "json"
      })
    end
end