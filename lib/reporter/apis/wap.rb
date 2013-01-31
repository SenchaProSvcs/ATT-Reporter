###
# WAP
##
module AttApi::Wap

  def run_wap_send_push(test_result)
      mime_content = MiniMime.new
      mime_content.add_content(
        :type => 'text/xml',
        :content => 
          '<wapPushRequest>' + "\n" +
          '  <addresses>' + "\n" +
          '     <address>tel:'+@config['tel']+'</address>' + "\n" +
          '  </addresses>' + "\n" +
          '  <subject>WAP</subject>' + "\n" +
          '  <priority>High</priority>' + "\n" +
          '</wapPushRequest>'
      )
      mime_content.add_content(
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
      
      test_result         ||= TestResult.new
      test_result.url     = "https://api.att.com/1/messages/outbox/wapPush"
      test_result.verb    = "POST"
      test_result.data    = mime_content.content
      test_result.headers = {
        "Accept"        => "application/json",
        "Authorization" => "{auth_token}",
        "Content-Type"  => mime_content.header,
        "Address" => "tel:{telephone}",
      }
      
      generic_api_test test_result
  end

end