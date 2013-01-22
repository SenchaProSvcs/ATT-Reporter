###
# For payment notifications, the sinatra app must be made available at a public endpoint.
# To set up an SSH tunnel from a public facing host to the local sinatra app (for testing), use this command:
#
#    ssh -NR 4567:localhost:4567 root@public.server.com
#
#  -N Do not execute a remote command
#  -R remotePort:localHost:localPort
#     Specifies that the given port on the remote (server) host is to be forwarded to the given host and port on the local side.
##
module AttApi::Payments


  def run_payment_new_transaction_consent
    timestamp = Time.now.to_i.to_s
    payload = {
      'Amount'                    => 0.99,
      'Category'                  => 1,
      'Channel'                   => 'MOBILE_WEB',
      'Description'               => 'D' + timestamp,
      'MerchantTransactionId'     => 'T' + timestamp,
      'MerchantProductId'         => 'P' + timestamp,
      'MerchantPaymentRedirectUrl'=> "#{@localServer}/payment/callback"
    }
    run_notary_signed_payload(payload)
    
    if @notary_signed_document.nil? or @notary_signature.nil?
      raise 'Error trying to sign payload'
    end
    
    return test_api(
      "url"       => "https://api.att.com/rest/3/Commerce/Payment/Transactions",
      "verb"      => "GET",
      "data"      => {
          "clientid"              => "{client_id}",
          "Signature"             => @notary_signature,
          "SignedPaymentDetail"   => @notary_signed_document
      })
  end
  
  def run_payment_new_subscription_consent
    timestamp = Time.now.to_i.to_s
    payload = {
      "Amount" => 0.99,
      "Category" => 1,
      "Channel" =>"MOBILE_WEB",
      'Description' => 'D' + timestamp,
      'MerchantTransactionId' => 'T' + timestamp,
      'MerchantProductId' => 'P' + timestamp,
      'MerchantPaymentRedirectUrl'=> "#{@localServer}/payment/callback",
      "MerchantSubscriptionIdList" => "U" + timestamp,
      "IsPurchaseOnNoActiveSubscription" => "false",
      "SubscriptionRecurrences" => 99999,
      "SubscriptionPeriod" => "MONTHLY",
      "SubscriptionPeriodAmount" => "1"
    }
    run_notary_signed_payload(payload)
    
    if @notary_signed_document.nil? or @notary_signature.nil?
      raise 'Error trying to sign payload'
    end
    
    return test_api(
      "url"       => "https://api.att.com/rest/3/Commerce/Payment/Subscriptions",
      "verb"      => "GET",
      "data"      => {
          "clientid"              => "{client_id}",
          "Signature"             => @notary_signature,
          "SignedPaymentDetail"   => @notary_signed_document
      })
  end

  def payment_notification(params)
    puts "RECEIVED PAYMENT NOTIFICATION"
    puts params
  end

  private

  def api_payment_new_json
    api_payment_new('json')
  end

  def api_payment_new_xml
    api_payment_new('xml')
  end

  def api_payment_refund_json
    api_payment_refund
  end

  def api_payment_refund_xml
    api_payment_refund
  end

  def api_payment_status_json
    api_payment_status
  end

  def api_payment_status_xml
    api_payment_status
  end


  def api_payment_new(format)

    begin

      newPaymentRequestData = {
        :amount => 0.99,
        :category => 1,
        :channel => 'MOBILE_WEB',
        :currency => 'USD' ,
        :description => 'Product Sold by Merchant',
        :externalMerchantTransactionID => "SenchaTransId#{(Time.now.to_f * 1000).to_i}",
        :merchantApplicationID => 'Payment876875',
        :merchantCancelRedirectUrl => "#{@localServer}/payments/cancel",
        :merchantFulfillmentRedirectUrl => "#{@localServer}/payments/deliver",
        :merchantProductID => 'Product60216',
        :purchaseOnNoActiveSubscription => false,
        :transactionStatusCallbackUrl => "#{@publicServer}/payments/notify",
        :autoCommit => false
      }

      url = "#{@baseURL}/1/payments/transactions?access_token=#{@oauth_token}"
      log "Requesting new payment"
      log_error "Request: #{url}"

      if format == 'xml'
        bodyReq = newPaymentRequestData.to_xml(:root => 'newTransactionRequest', :skip_types => true)
        contentType = 'application/xml'
        log_error bodyReq
      else
        bodyReq = newPaymentRequestData.to_json
        contentType = 'application/json'
        log_error JSON.pretty_generate(newPaymentRequestData)
      end

      page = @agent.post(url, bodyReq, 'Content-Type' => contentType, 'Accept' => contentType)

      log_error "Response:"
      if format == 'xml'
        log_error page.body
        response = Hash.from_xml(page.body)
      else
        response = JSON.parse(page.body)
        log_error JSON.pretty_generate(response)
      end

      # Note that the xml response isn't processed since we did not parse the xml
      if response["transactionStatus"] == "NEW"
        log_error "Requesting authorization page (redirectUrl)"
		    log_error response['redirectUrl']

        log_error "Authorization Page response:"
        authorisePage = @agent.get(response['redirectUrl'])
        log_error authorisePage.body

        log_error "Submitting authorization"

        # Assume first form on page is confirm form
        confirmForm = authorisePage.forms[0]
        confirmForm.action = @agent.current_page.uri
        authResult = @agent.submit(confirmForm)

        log_error "Looking for transaction ID from redirect link"
        begin
          confirmURL = authResult.search(".button_left")[0]['onclick']
          if confirmURL.match(/txid=([0-9]+)/)
            log_error "Got transaction ID #{$1}"
            @new_payment_txid = $1
          else
            puts "Couldn't find transaction ID from redirect link"
          end
        rescue Exception => e
          log_error e.backtrace
          log_error e.page.body
          return "FAILED"
        end

      end

    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
     return "FAILED"
    end
    return "OK"
  end

  def api_payment_new_subscription

    url = "#{@baseURL}/1/payments/transactions?access_token=#{@oauth_token}"
    @payment_subscription_id = "SEN#{(Time.now.to_f * 1000).to_i}"
    log "New subscription request #{@payment_subscription_id}"
    log_error "Request: : #{url}" if @debug >= AttApiReporter::DEBUG_INFO

    begin

      newPaymentSubscriptionRequestData = {
        :amount => 0.99,
        :category => 1,
        :channel => 'MOBILE_WEB',
        :currency => 'USD' ,
        :description => 'Product Sold by Merchant2',
        :externalMerchantTransactionID => "SenchaTransId#{(Time.now.to_f * 1000).to_i}",
        :merchantApplicationID => 'Payment123',
        :merchantCancelRedirectUrl => "#{@localServer}/payments/cancel",
        :merchantFulfillmentRedirectUrl => "#{@localServer}/payments/deliver",
        :merchantProductID => 'Product602234',
        :purchaseOnNoActiveSubscription => false,
        :transactionStatusCallbackUrl => "#{@publicServer}/payments/notify",
        :subscriptionRecurringNumber => 1,
        :subscriptionRecurringPeriod => 'MONTHLY',
        :subscriptionRecurringPeriodAmount => 1,
        :merchantSubscriptionIdList => @payment_subscription_id,
        :autoCommit => false
      }

      log_error JSON.pretty_generate(newPaymentSubscriptionRequestData)
      bodyReq = newPaymentSubscriptionRequestData.to_json
      page = @agent.post(url, bodyReq, 'Content-Type' => 'application/json', 'Accept' => ' application/json')

      response = JSON.parse(page.body)
      log_error JSON.pretty_generate(response) if @debug >= AttApiReporter::DEBUG_INFO

      if response["transactionStatus"] == "NEW"
        @payment_subscription_txid = response['trxID']

        log "Requesting authorization page"
        authorisePage = @agent.get(response['redirectUrl'])

        log "Submitting authorization"
        # Assume first form on page is confirm form
        confirmForm = authorisePage.forms[0]
        confirmForm.action = @agent.current_page.uri
        authResult = @agent.submit(confirmForm)

        log "Looking for redirect link"
        begin
          confirmURL = authResult.search(".button_left")[0]['onclick']
          if confirmURL.match(/txid=([0-9]+)/)
            puts "Got transaction ID #{$1}"
            @new_payment_txid = $1
          else
            puts "Couldn't find redirect link"
          end
        rescue Exception => e
          log_error e.backtrace
          log_error e.page.body
          return "FAILED"
        end

      end

    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
       return "FAILED"
    end
    return "OK"
  end

  ###
  # Payment status
  ##
  def api_payment_status

    raise "No new payment TXID" unless @new_payment_txid

    url = "#{@baseURL}/1/payments/transactions/#{@new_payment_txid}?access_token=#{@oauth_token}"

    log "Requesting payment status"
    log_error "Request:  #{url}" if @debug >= AttApiReporter::DEBUG_INFO

    page = @agent.get(url)

    begin
      paymentStatus = JSON.parse(page.body)
      log_error JSON.pretty_generate(paymentStatus) if @debug >= AttApiReporter::DEBUG_INFO

      if paymentStatus['transactionStatus'] == 'SUCCESSFUL'
        log "Payment successful"
      elsif paymentStatus['transactionStatus'] == 'AUTHORIZED'
        # Not yet implemented on the server side.
        begin
          log "Payment authorized. Committing payment"
          transaction_id = paymentStatus['trxID']

          # Must add 'action=commit' to parameters. Doesn't seem to be doc'ed
          #url = "#{$conf[:baseURL]}/1/payments/transactions/#{transaction_id}?action=commit&access_token=#{@oauth_token}"
          url = "#{@baseURL}/1/payments/transactions/#{transaction_id}?action=commit&access_token=#{@oauth_token}"

          log_error "Request:  #{url}" if @debug >= AttApiReporter::DEBUG_INFO

          page = @agent.post(url, { :transactionStatus => "COMMITTED" })

          commitStatus = JSON.parse(page.body)
          log "Payments complete!"
          log_error JSON.pretty_generate(commitStatus) if @debug >= AttApiReporter::DEBUG_INFO
        rescue Exception => e
          log_error e.backtrace
          log_error e.page.body
          return "FAILED"
        end
      end
    end
    return "OK"
  end

  ###
  # Payment refund
  ##
  def api_payment_refund

    raise "No new payment TXID" unless @new_payment_txid

    url = "#{@baseURL}/1/payments/transactions/#{@new_payment_txid}?access_token=#{@oauth_token}&action=refund"

    log "Refunding transaction"
    log_error "Request:  #{url}" if @debug >= AttApiReporter::DEBUG_INFO

    paymentRefundData = {
      :refundReasonText => "Customer was not happy",
      :refundReasonCode => 1
    }
    log_error JSON.pretty_generate(paymentRefundData)

    begin
      page = @agent.post(url, paymentRefundData.to_json, 'Content-Type' => 'application/json', 'Accept' => 'application/json')

      refundStatus = JSON.parse(page.body)
      log "OK. Refund complete!"
      log_error JSON.pretty_generate(refundStatus)
    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
      return "FAILED"
    end
    return "OK"
  end

  ###
  # Payment subscription status
  # ISSUE: No 'Status' field in return value
  # ISSUE: recurrencesLeft set to -2
  # DOC: success: true not documented
  ##
  def api_payment_subscription_status

    raise "No subscription Transaction ID" unless @payment_subscription_txid

    url = "#{@baseURL}/1/payments/transactions/#{@payment_subscription_txid}?access_token=#{@oauth_token}"

    log "Finding subscription info"
    log_error "Request:  #{url}" if @debug >= AttApiReporter::DEBUG_INFO

    begin
      page = @agent.get(url)
      subscriptionStatus = JSON.parse(page.body)
      log "Got subscription info"
      log_error JSON.pretty_generate(subscriptionStatus)
    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
      return "FAILED"
    end
    return "OK"
  end

  ###
  # Payment notifications
  # ISSUES: Cannot test as subscriptions don't seem to be working
  ##
  def api_payment_get_notification

    raise "No notification ID" unless @payment_notification_id

    url = "#{@baseURL}/1/payments/notifications/#{@payment_notification_id}?access_token=#{@oauth_token}"

    puts "Finding notification info..."
    log_error "Request:  #{url}" if @debug >= AttApiReporter::DEBUG_INFO

    begin
      page = @agent.get(url)
      notificationStatus = JSON.parse(page.body)
      log_error JSON.pretty_generate(notificationStatus)
    rescue Exception => e
      log_error e.backtrace
      log_error e.page.body
    end
  end

  ###
  # Payment acknowledge notification
  # ISSUES: Cannot test as subscriptions don't seem to be working
  ##
  def api_payment_ack_notification

    raise "No notification ID" unless @payment_notification_id

    url = "#{@baseURL}/1/payments/notifications/#{@payment_notification_id}?access_token=#{@oauth_token}"

    puts "Finding notification info..."
    log_error "Request:  #{url}" if @debug >= AttApiReporter::DEBUG_INFO

    begin
      page = @agent.put(url, { :notificationID => @payment_notification_id })
      notificationStatus = JSON.parse(page.body)
      puts JSON.pretty_generate(notificationStatus)
    rescue Exception => e
      puts "ERROR"
      puts e.page.body
    end
  end

end