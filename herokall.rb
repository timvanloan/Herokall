# require 'rubygems'
require 'sinatra'
require 'twilio-ruby'

# set up a client to talk to the Twilio REST API
# you need to make sure you set your Twilio SID and Token in your Heroku Config/environmental variables
CLIENT = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']

# This renders the initial form page to accept the users phone number
get '/' do
  html = '<p>Please enter your phone number and a registered nurse will call you immediately.</p>'
  html += '<form method="post" action="/submit">'
  html += '<input type="text" name="phone" /><input value="Call Me Now" type="submit" /></form>'
  return html
end

# This is the method that Twilio calls after the initial call is made

post '/aftercall' do
  content_type 'text/xml'
    "<Response>
         <Say>We are now connecting you with a registered nurse</Say>
          <Dial>ENTER_THE_NURSE_PHONE_NUMBER_HERE</Dial>
    </Response>"
end

# The code that is called once a user submits their phone number
post '/submit' do
  html = '<p>Thank you, please stay calm as we assign a nurse to call you.</p>'
  html += '<p>Please prepare for a phone call.</P>'
  
  # added for debugging
  logger.error "params: " + params.inspect
  
  # sends the user a SMS message for followup info
  CLIENT.account.sms.messages.create(
    :from => 'YOUR_TWILIO_CALLER_ID',
    :to => params[:phone],
    :body => 'We hope our nurse was able to help. Please find addtional tips for staying healthy at http://www.cdc.gov/family/tips/'
  )

# calls the user at the phone number they specificed
  call = CLIENT.account.calls.create(
   :from => 'YOUR_TWILIO_CALLER_ID',
    :to => params[:phone],
    :url => 'ENTER_YOUR_APPHOST_HERE/aftercall'
  )  
  return html
end
