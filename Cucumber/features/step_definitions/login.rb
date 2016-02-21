# encoding: UTF-8

Then /^login screen is displayed with title "(.*?)"$/ do |title|
  @login_screen = LoginScreen.new(driver, APP_TYPE)
  fail "Expected title #{title} and actual title is #{@login_screen.login_title.text}" if @login_screen.login_title.text != title
end



Then /^username field contains "(.*?)"$/ do |username|
  fail "Expected username to read #{username}" if @login_screen.username.attribute('value') != username
end

Then /^password field contains "(.*?)"$/ do |password|
  fail "Expected password to read #{password}" if @login_screen.password.attribute('value') != password
end

# TODO: Change this back to a macro step which reuses login screen is displayed / browse screen is displayed
# and change all tests accordingly
Given /^"(.*?)" has logged into JoinIn with "([A-z]*)"$/ do |username, password|
  @login_screen.login(username, password)
end

Given /^"(.*?)" has logged into JoinIn with "([A-z]*)" and device name "(.*?)"$/ do |username, password, device_name|
  @login_screen.login_with_device_name(username, password, device_name)

  # TODO: Can we remove this? Trial it out when you've got a minute
  # Check if a error dialog is displayed - otherwise initialize browse screen
  @dialog = Dialog.new(driver, APP_TYPE)
end

When /^the language (.*?) is selected on login screen$/ do |language|
  @login_screen.click_language(language)
  sleep(5)

  # TODO: Fix issue with application start after reloading page
  # Is there a cleaner way to do this allowing automatic reconfiguration?
  start_app

  wait.until { driver.find_element(:class, 'dialog-fullscreen-title') }
  @login_screen = LoginScreen.new(driver, APP_TYPE)
end

Then /^text on login screen is in (.*?)$/ do |language|
  if (@language_mappings.include? language) && (@language_mappings[language].include? 'login')
    screen_strings = @language_mappings[language]['login']
    if @login_screen.welcome.text.downcase != screen_strings['welcome'].downcase
      fail "welcome text is not as expected - expected: #{screen_strings['welcome'].downcase} but actual: #{@login_screen.welcome.text.downcase}"
    end
    if @login_screen.instructions.text.downcase != screen_strings['instructions'].downcase
      fail "instruction text is not as expected - expected: #{screen_strings['instructions'].downcase} but actual: #{@login_screen.instructions.text.downcase}"
    end
    if @login_screen.signin_button.text.downcase != screen_strings['signin'].downcase
      fail "signin button text is not as expected - expected: #{screen_strings['signin'].downcase} but actual: #{@login_screen.signin_button.text.downcase}"
    end
  else
    fail "Strings have not been setup on test_data_mapping/env/languages.yml for the expected language #{language} or login screen"
  end
end

Given /^the default user has logged in$/ do
  step "login screen is displayed"
  step '"nmp@nagra.com" has logged into JoinIn with "nmp"'
  step "browse screen is displayed"
end

Then /^the login dialog is displayed$/ do
  @signin_dialog = SignInDialog.new(driver, APP_TYPE)
  wait.until { @signin_dialog.dialog.displayed? }
end

def enter_username(username)
  @signin_dialog.dialog_username.click
  @signin_dialog.dialog_username.send_keys(username)
end

def enter_password(pwd)
  @signin_dialog.dialog_password.click
  @signin_dialog.dialog_password.send_keys(pwd)
end

Given(/^the user "(.*?)" with password "(.*?)" has logged in using the login pop up$/) do |username, pwd|
    enter_username(username)
    enter_password(pwd)
    step "submit is clicked on the login dialog"
end

When(/^cancel is clicked on the login dialog$/) do
  @signin_dialog.dialog_cancel_button.click
end

Then (/^the sign-in dialog is not shown on the browse screen$/) do
  step "wait 5 seconds"
  @signin_dialog = SignInDialog.new(driver, APP_TYPE)
  wait.until {not(@signin_dialog.dialog.displayed?) rescue true}
end

When(/^submit is clicked on the login dialog$/) do
  @signin_dialog.dialog_submit_button.click
end



Then /^username field on login popup contains "(.*?)"$/ do |username|
  fail "Expected username to read #{username}" if @signin_dialog.dialog_username.attribute('value') != username
end

Then /^password field on login popup contains "(.*?)"$/ do |password|
  fail "Expected password to read #{password}" if @signin_dialog.dialog_password.attribute('value') != password
end

Then(/^user should get a warning for username and password$/) do
  step "the \"username\" warning is displayed"
  step "the \"password\" warning is displayed"
end

Then(/^the "(.*?)" warning is displayed$/) do |signinfield|
  @signin_dialog = SignInDialog.new(driver, APP_TYPE)
  case signinfield
    when "username"
      fail "Expected warning for username field" if  @signin_dialog.dialog_username.attribute('class') != "dialog-input required"
    when "password"
      fail "Expected warning for password field" if  @signin_dialog.dialog_password.attribute('class') != "dialog-input required"

  end
end

Then(/^the unable to sign in dialog is displayed$/) do
  step "wait 5 seconds"
  @unable_signin_dialog = SignInDialog.new(driver, APP_TYPE)
  fail "Expected unable to sign in warning dialog" if  @unable_signin_dialog.dialog_title.text != "Unable to Sign In"
end

When(/^the ok button is clicked$/) do
    @signin_dialog.dialog_ok_button.click
end


When(/^I login with "([^"]*)" and "([^"]*)"$/) do |username, password|
  @login_screen.login(username, password)
end

Then(/^"([^"]*)" error message is displayed on the login screen$/) do |error|
  fail "Expected message #{error} and actual message #{@login_screen.error_msg}" if @login_screen.error_msg != error
end

Then(/^login should be failed$/) do
  fail "Login didn't fail" if @login_screen.login_failed.text != "Login failed"
end

When(/^I enter "([^"]*)" in username$/) do |entered_username|
  @login_screen.username.click
  @login_screen.username.send_keys(entered_username)
end

When(/^I enter "([^"]*)" in password$/) do |entered_password|
  @login_screen.password.click
  @login_screen.password.send_keys(entered_password)
end

When(/^I click "([^"]*)" button on login screen$/) do |button|
  if button == "Sign In"
    @login_screen.signin_button.click
  elsif button == "Remember me"
    @login_screen.rememberme.click
  end
end