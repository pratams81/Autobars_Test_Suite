Then(/^"([^"]*)" screen is displayed$/) do |screen_name|
  @welcome_screen = Welcome_Screen.new(driver, APP_TYPE)
  fail "Expected title #{screen_name} and actual title is #{@welcome_screen.login_title.text}" if @welcome_screen.login_title.text != screen_name
end

When(/^I click "([^"]*)" on welcome page$/) do |button|
  if button =="logout"
    @welcome_screen.logout.click
  end
end