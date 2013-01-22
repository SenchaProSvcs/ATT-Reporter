###
# WAP
##
module AttApi::Wap

  private

  def api_wap_push

    url = "#{@baseURL}/1/messages/outbox/wapPush?access_token=#{@oauth_token}"
    log "Sending WAP push"
    log_error "Request: : #{url}" if @debug >= AttApiReporter::DEBUG_INFO

    begin
      
      mimeContent = MiniMime.new
      
      mimeContent.add_content(
        :type => 'text/xml',
        :content => 
          '<wapPushRequest>' + "\n" +
          '  <addresses>' + "\n" +
          '     <address>tel:'+@tel+'</address>' + "\n" +
          '  </addresses>' + "\n" +
          '  <subject>WAP</subject>' + "\n" +
          '  <priority>High</priority>' + "\n" +
          '</wapPushRequest>'
      )
      
      mimeContent.add_content(
        :type => 'text/xml',
        :content =>
          'Content-Disposition: form-data; name="PushContent"' +  "\n" +
          'Content-Type: text/vnd.wap.si' +  "\n" +
          'Content-Length: 12' +  "\n" +
          'X-Wap-Application-Id: x-wap-application:wml.ua' +  "\n" +
          '' +  "\n" +
          '<?xml version ="1.0"?>' +  "\n" +
          '<!DOCTYPE si PUBLIC "-//WAPFORUM//DTD SI 1.0//EN" "">http://www.wapforum.org/DTD/si.dtd">' +  "\n" +
          '<si>' +  "\n" +
          '   <indication href="http://wap.uni-wise.com/hswap/zh_1/index.jsp?MF=N&Dir=23724" si-id="1">' +  "\n" +
          '     CDMA Push test!!' +  "\n" +
          '   </indication>' +  "\n" +
          '</si>'
      )

      page = @agent.post(url, mimeContent.content, {
        'Accept' => 'application/json',
        'Content-Type' => mimeContent.header
      })
      response = JSON.parse(page.body)
      log_error JSON.pretty_generate(response) #if @debug >= AttApiReporter::DEBUG_INFO
      log "Sent WAP"

    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
      return "FAILED"
    end
  return "OK"
  end

end






#       mime_split = "----=_Part_0_#{((rand*10000000) + 10000000).to_i}.#{((Time.new.to_f) * 1000).to_i}"
#       
#       content = []
#       content << 'Content-Type: text/xml
# Content-ID: <rootpart@soapui.org>
# 
# <wapPushRequest>
#   <addresses>
#      <address>tel:'+@tel+'</address>
#   </addresses>
#   <subject>WAP</subject>
#   <priority>High</priority>
# </wapPushRequest>
# '
#       content << 'Content-Type: text/plain
# Content-ID: <wapmessage.xml>
# 
# Content-Disposition: form-data; name="PushContent"
# Content-Type: text/vnd.wap.si
# Content-Length: 12
# X-Wap-Application-Id: x-wap-application:wml.ua
# 
# <?xml version ="1.0"?>
# <!DOCTYPE si PUBLIC "-//WAPFORUM//DTD SI 1.0//EN" "">http://www.wapforum.org/DTD/si.dtd">
# <si>
#    <indication href="http://wap.uni-wise.com/hswap/zh_1/index.jsp?MF=N&Dir=23724" si-id="1">
#      CDMA Push test!!
#    </indication>
# </si>
# '
#       page = @agent.post(url, "--#{mime_split}\n" + content.join("--#{mime_split}\n") + "--#{mime_split}--\n", {
#         'Accept' => 'application/json',
#         'Content-Type' => 'multipart/related; type="text/xml"; start="<rootpart@soapui.org>"; boundary="' + mime_split + '"'
#       })
