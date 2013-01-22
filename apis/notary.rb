module AttApi::Notary
  def run_notary_signed_payload(payload = nil)
    
    timestamp = Time.now.to_i.to_s
    
    if not payload.nil?
      payload = JSON.unparse(payload)
    else
      payload = JSON.unparse({
        "Test" => "this is a test"
      })
    end
    
    result = test_api({
      "url"       => "https://api.att.com/Security/Notary/Rest/1/SignedPayload",
      "verb"      => "POST",
      "headers"   => {
          "Accept"        => "application/json",
          "Content-Type"  => "application/json",
          "Client_id"     => "{client_id}",
          "Client_secret" => "{client_secret}"
      },
      "data" => payload
    })
    
    if @agent.page.code != "200"
      raise "Error trying to sign payload"
    end
    
    data = JSON.parse(@agent.page.body)
    
    # save document for other tests
    @notary_signed_document = data['SignedDocument']
    @notary_signature = data['Signature']
    
    return result
  end
end