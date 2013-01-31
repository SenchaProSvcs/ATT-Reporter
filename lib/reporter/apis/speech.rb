###
# Using OSX to generate sound files:
#
# say -v Alex -o voicemail.aac "Thank you for calling the operations connect company. We are currently closed. If this is an emergency situation, please call our answering service. Thank you [[slnc 1500]]"
# say -v Alex -o business.aac "pizza atlanta georgia [[slnc 1500]]"
# say -v Alex -o question.aac "why do horses sleep standing up [[slnc 1500]]"
# say -v Alex -o websearch.aac "sencha touch documentation [[slnc 1500]]"
#
# Used http://www.miksoft.net/mobileMediaConverterDown.htm to convert from AAC to AMR / WAV
##
module AttApi::Speech
  
  def run_speech_to_text(test_result)
    file_contents = File.open(File.join(File.dirname(__FILE__), '..', 'speech', 'voicemail.amr')){ |f| f.read }

    test_result.url     = "https://api.att.com/rest/2/SpeechToText"
    test_result.verb    = "POST"
    test_result.data    = file_contents
    test_result.headers = {
      "Accept"            => "application/json",
      "Authorization"     => "{auth_token}",
      "Content-Type"      => "audio/amr"
    }
    
    return generic_api_test test_result
  end
  
  def api_websearch_speech_to_text

    mime_content = MiniMime.new

    mime_content.add_content(
      :type => 'audio/amr',
      :headers => {
         'Content-Transfer-Encoding' => 'base64',
         'Content-Disposition' => 'attachment; name="websearch.amr"'
      },
      :content_id => '<websearch.amr>',
      :content => Base64.encode64(File.read('lib/websearch.amr'))
    )

    puts "Sending Web search Text to Speech request"
    response = simple_json_post("#{@config['api_host']}/1/speechtranslation/websearch/speechtotext?access_token=#{@oauth_token}", mime_content.content, 'Content-Type' => mime_content.header)
    if(!response) 
      return "FAILED"
    end
    return "OK"
  end
  
  def api_localbusinesssearch_speech_to_text

    mime_content = MiniMime.new

    mime_content.add_content(
      :type => 'audio/amr',
      :headers => {
         'Content-Transfer-Encoding' => 'base64',
         'Content-Disposition' => 'attachment; name="business.amr"'
      },
      :content_id => '<business.amr>',
      :content => Base64.encode64(File.read('lib/business.amr'))
    )

    puts "Sending Local Business Search Text to Speech request"
    response = simple_json_post("#{@config['api_host']}/1/speechtranslation/localbusinesssearch/speechtotext?access_token=#{@oauth_token}", mime_content.content, 'Content-Type' => mime_content.header)
    if(!response) 
      return "FAILED"
    end
    
    return "OK"
  end
  
  def api_questionandanswer_speech_to_text

    mime_content = MiniMime.new

    mime_content.add_content(
      :type => 'audio/amr',
      :headers => {
         'Content-Transfer-Encoding' => 'base64',
         'Content-Disposition' => 'attachment; name="question.amr"'
      },
      :content_id => '<question.amr>',
      :content => Base64.encode64(File.read('lib/question.amr'))
    )

    puts "Sending Question and Answer Text to Speech request"
    response = simple_json_post("#{@config['api_host']}/1/speechtranslation/questionandanswer/speechtotext?access_token=#{@oauth_token}", mime_content.content, 'Content-Type' => mime_content.header)
    if(!response) 
      return "FAILED"
    end
    return "OK"
  end
  
end