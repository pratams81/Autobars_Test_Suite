# encoding: UTF-8

##########################
## General Dialog Steps ##
##########################

Then /^dialog is displayed with the following information for "(.*?)":$/ do |device_type, dialog_details|
  # TODO: Get rid of sleep, but dialog code will need to stop
  # storing references to elements and locate them on demand
  sleep 2
  @dialog = Dialog.new(driver,  APP_TYPE)
  wait.until { @dialog.is_displayed }


  if device_type == APP_TYPE || device_type == 'All'
    dialog_details = dialog_details.hashes
    fail 'There is a duplicate value in the expected results' unless dialog_details.length == dialog_details.uniq.length
    actual_dialog_list = @dialog.get_dialog_list
    actual_dialog_text = @dialog.get_dialog_text

    actual_dialog_buttons = @dialog.get_dialog_buttons

    begin
      actual_dialog_header = @dialog.get_dialog_title
    rescue Selenium::WebDriver::Error::NoSuchElementError
      actual_dialog_header = ''
    end
    actual_dialog_textfield = @dialog.get_dialog_textfields
    # Check if header is in the list - if so remove it from the details count
    if dialog_details.find { |h| h['field_type'] == 'header' }
      details_count = dialog_details.count - 1
    else
      details_count = dialog_details.count
    end
    unless details_count == (actual_dialog_text.count + actual_dialog_buttons.count + actual_dialog_list.count + actual_dialog_textfield.count)
      failure_string = "Number of expected (#{details_count}) elements in the dialog did not match the actual" \
                        "(#{actual_dialog_text.count + actual_dialog_buttons.count + actual_dialog_list.count + actual_dialog_textfield.count})"
      fail failure_string
    end

    dialog_details.each do |row|
      if row['field_type'] == 'header'
        fail "error dialog title is not displayed as expected. Expected: #{row['field_value'] }, Actual: #{actual_dialog_header}" unless actual_dialog_header.downcase == row['field_value'].downcase
      elsif row['field_type'] == 'text'
        fail "#{row['field_value']} is not displayed in dialog when expected, actual text: #{actual_dialog_text}" unless actual_dialog_text.include? row['field_value']
      elsif row['field_type'] == 'textfield'
        textfield_names = []
        actual_dialog_textfield.each do |textfield|
          textfield_names.push(textfield.attribute('name'))
        end
        fail "#{row['field_value']} is not displayed in dialog when expected, actual text: #{textfield_names}" unless textfield_names.include? row['field_value']
      elsif row['field_type'] == 'button'
        #To loop through each available button
        actual_dialog_buttons_text = []
        print actual_dialog_buttons_text, "\n"

        actual_dialog_buttons.each do |item|
          actual_dialog_buttons_text.push(item.text)
        end

        fail "#{row['field_value']} is not displayed in dialog when expected, actual buttons: #{actual_dialog_buttons}" unless actual_dialog_buttons_text.include? row['field_value']
      elsif row['field_type'] == 'list-text'
        actual_dialog_list_text = []

        actual_dialog_list.each do |item|
          actual_dialog_list_text.push(item.text)
        end

        fail "#{row['field_value']} is not displayed in dialog when expected, actual list-text: #{actual_dialog_list_text}" unless actual_dialog_list_text.include? row['field_value']
      else
        fail "Field type not recognized: #{dialog_details['field_type']}"
      end
    end
  else
    puts 'Device type does not match - so continue without testing'
  end
end

########################################
## Change Audio Dialog Specific Steps ##
########################################

Then /^change audio dialog is displayed$/ do
  dialog = driver.find_element(:class, 'dialog')
  fail 'Change audio dialog is not being displayed when expected' unless dialog.displayed?
end

When /^OK is clicked in the changeAudioLanguage dialog$/ do
  @dialog.get_dialog_buttons[0].click
end

When /^audio language German is selected$/ do
  @dialog.click_audio_language_setting(2)
end

##################################################
## Delete Recommendations Dialog Specific Steps ##
##################################################

When /^OK is clicked in the deleteRecommendations dialog$/ do
  @dialog.get_dialog_buttons[0].click
end

Then /^delete recommendations result dialog is displayed$/ do
  dialog = driver.find_element(:class, 'dialog')
  fail 'Delete recommendations dialog is not being displayed when expected' unless dialog.displayed?
end

Then /^delete recommendations result dialog is not displayed$/ do
  sleep(10)
  begin
    dialog = driver.find_element(:class, 'dialog')
    fail 'Delete recommendations dialog is displayed when not expected' if dialog.displayed?
  rescue Selenium::WebDriver::Error::NoSuchElementError
    puts 'Dialog not displayed'
  end
end

####################################
## Purchase Dialog Specific Steps ##
####################################

Then /^buy dialog is displayed$/ do
  wait.until { driver.find_element(:class, 'dialog').displayed? }
  @dialog = Dialog.new(driver,  ENV['APP_TYPE'])
end


Then /^buy dialog is not displayed$/ do
  begin
    dialog = driver.find_element(:class, 'dialog')
    fail 'Buy dialog is not being displayed when expected' if dialog.displayed?
  rescue Selenium::WebDriver::Error::NoSuchElementError
    puts 'Dialog not displayed'
  end
end

When /^okay is clicked in the dialog$/ do
  @dialog.get_dialog_buttons[0].click
end

Then /^the dialog is not displayed$/ do
  wait.until { not @dialog.is_displayed }
end

When /^back is clicked in the version dialog$/ do
  @dialog.get_dialog_buttons[0].click
end

When /^cancel is clicked in the purchase dialog$/ do
  @dialog.get_dialog_buttons[1].click
end

# Added for better understanding.
When /^submit is clicked in the purchase dialog$/ do
  @dialog.get_dialog_buttons[0].click
  @dialog = wait_for_dialog("dialog-text", "To purchase")
end

When /^submit is clicked in the purchase confirmation dialog$/ do
  submit = @dialog.get_dialog_buttons[0]
  submit.click
end

######################################
## Parental Control Specific Steps  ##
######################################

When /^"(.*?)" is entered into dialog password field$/ do |password_entered|
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  @dialog.enter_password_parental_controls(password_entered)
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
end

When /^return is entered to submit dialog password$/ do
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  @dialog.enter_password_parental_controls(:return)
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^submit is clicked in the password dialog$/ do
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  @dialog.click_submit
  begin
    @dialog = Dialog.new(driver, APP_TYPE)
  rescue
    @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
  end
end

When /^cancel is clicked in the password dialog$/ do
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  @dialog.get_dialog_buttons[1].click
end

Then /^parental control screen is displayed with (ALL|PG|U|12|15) selected$/ do |content_level|
  content_level_location = { 'U' => 0, 'PG' => 1, '12' => 2, '15' => 3, 'ALL' => 4 }
  # Validate list - U, PG, 12, 15, None
  content_level_details = @dialog.get_parental_dialog_list_details
  fail "The number of content level options is not as expected, expected 5 but #{content_level_details.length} are displayed" unless content_level_details.length == 5
  unless content_level_details[0][:content_level] == '(U) Suitable for all'
    fail "Expected (U) Suitable for all to be the 1st content level in the parental control dialog but #{content_level_details[0][:content_level]} is"
  end
  unless content_level_details[1][:content_level] == '(PG) Parental Guidance'
    fail "Expected (PG) Parental Guidance to be the 2nd content level in the parental control dialog but #{content_level_details[1][:content_level]} is"
  end
  unless content_level_details[2][:content_level] == '(12) Suitable for 12 years and above'
    fail "Expected (12) Suitable for 12 years and above and above to be the 3rd content level in the parental control dialog but #{content_level_details[2][:content_level]} is"
  end
  unless content_level_details[3][:content_level] == '(15) Suitable for 15 years and above'
    fail "Expected (15) Suitable for 15 years and above to be the 4th content level in the parental control dialog but #{content_level_details[3][:content_level]} is"
  end
  unless content_level_details[4][:content_level] == 'Show all content'
    fail "Expected Show all content to be the 5th content level in the parental control dialog but #{content_level_details[4][:content_level]} is"
  end
  # Validate control_level is selected in the list
  fail "The expected content level is not selected. expected #{content_level}" if content_level_details[content_level_location[content_level]][:is_selected] != true
end

When /^dialog is closed using:$/ do |close_actions_map|
  close_actions = {}
  close_actions_map.hashes.map do |hash|
    close_actions[hash['Device']] = { action: hash['Action'], screen: hash['Expected Screen After Closing'] }
  end

  @dialog.close_dialog(close_actions[APP_TYPE][:action])
  # Reinitialise the expected screen to be returned to?
  validate_expected_screen(close_actions[APP_TYPE][:screen])
end

When /^dialog is closed:$/ do |close_actions_map|
  close_actions = {}
  close_actions_map.hashes.map do |hash|
    close_actions[hash['Device']] = { action: hash['Action'], screen: hash['Expected Screen After Closing'] }
  end

  @dialog.close_dialog(close_actions[APP_TYPE][:action])
  # Reinitialise the expected screen to be returned to?
  #validate_expected_screen1(close_actions[:screen])
end
When /^rating (ALL|U|PG|12|15) is selected$/ do |content_level|
  content_level_location = { 'U' => 0, 'PG' => 1, '12' => 2, '15' => 3, 'ALL' => 4 }
  @dialog.click_parental_setting(content_level_location[content_level])
  begin
    @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  rescue
    puts 'Dialog is not displayed'
  end
end

####################################
##      Phone Mobile Menu         ##
####################################
When /^(CATEGORIES|BROWSE|CHANNELS|PARENTAL CONTROLS|SETTINGS) is clicked in the mobile menu$/ do |menu_item|
  sleep(2)
  @dialog.click_dialog_item(menu_item)
  if menu_item == 'PARENTAL CONTROLS'
    @dialog = ParentalControlDialog.new(driver, APP_TYPE)
  elsif menu_item == 'SETTINGS'
    @dialog = Dialog.new(driver, APP_TYPE)
  elsif menu_item == 'BROWSE' || menu_item == 'CATEGORIES'
    @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
  elsif menu_item == 'CHANNELS'
    @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
  end
end

When /^mobile menu button is clicked$/ do
  @dialog.click_mobile_menu
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

####################################
##    Sign in Error dialog        ##
####################################

Then /^error dialog is displayed with the following text: "(.*?)"$/ do |expected_error_text|
  # Validate the error dialog has correct title and back button
  dialog_title = @dialog.get_dialog_title
  fail "error dialog is not displayed as expected. Expected Title: Error, Actual Title: #{dialog_title}" unless dialog_title == 'ERROR'

  dialog_button = @dialog.get_dialog_buttons_text
  fail "error dialog is not displayed as expected. Expected Title: Error, Actual Title: #{dialog_title}" unless dialog_button.count == 1 && dialog_button[0] == 'Back'

  # Validate the error text is as expected
  actual_error_text = @dialog.get_dialog_text[0]
  fail "error dialog text is not as expected - Expected: #{expected_error_text} but Actual: #{actual_error_text}" unless actual_error_text == expected_error_text
end

Then /^the selected language is (.*?)$/ do |expected_language|
  selected_language = @dialog.get_selected_dialog_list_item
  fail "selected language is not as expected. Expected: #{expected_language}, Actual: #{selected_language.text}" unless expected_language == selected_language.text
end

When /^language (.*?) is selected$/ do |select_language|
  @dialog.click_dialog_item(select_language)
end

When /^settings item (.*?) is selected$/ do |dialog_item|
  sleep(5)
  @dialog.settings_option(dialog_item).click

  if dialog_item == 'changeDeviceName'
    @dialog = DeviceNameDialog.new(driver, APP_TYPE)
  else
    @dialog = Dialog.new(driver, APP_TYPE)
  end
end

When /^OK is clicked in the language dialog$/ do
  @dialog.click_button('changeLanguage')
  sleep(5)
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^OK is clicked in the refresh dialog$/ do
  @dialog.click_button('refreshApplication')
  sleep(5)
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^OK is clicked in the refresh parental dialog$/ do
  @dialog.click_button('submit')
  sleep(5)
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

#####################################
## change device name dialog       ##
#####################################

And /^device name is "(.*?)"$/ do |expected_device_name|
  @dialog = DeviceNameDialog.new(driver, APP_TYPE)
  actual_device_name = @dialog.get_device_name
  fail "Device name is not as expected. Expected: #{expected_device_name}, Actual: #{actual_device_name}" unless actual_device_name == expected_device_name
end

And /^device name is not "(.*?)"$/ do |not_expected_device_name|
  @dialog = DeviceNameDialog.new(driver, APP_TYPE)
  actual_device_name = @dialog.get_device_name
  fail "Device name is not as expected. Did not expect #{not_expected_device_name}, Actual: #{actual_device_name}" unless actual_device_name != not_expected_device_name
end

When /^device name is set to "(.*?)"$/ do |set_device_name|
  @dialog = DeviceNameDialog.new(driver, APP_TYPE)
  @dialog.set_device_name(set_device_name)
end

And /^OK is clicked in the change device dialog:$/ do |expected_screen_table|
  @dialog = DeviceNameDialog.new(driver, APP_TYPE)
  @dialog.click_ok_change_device

  # Reinitialise the expected screen to be returned to?
  expected_screen = {}
  expected_screen_table.hashes.map do |hash|
    expected_screen[hash['Device']] = { screen: hash['Expected Screen'] }
  end
  validate_expected_screen(expected_screen[APP_TYPE][:screen])
end

And /^Cancel is clicked in the change device dialog:$/ do |expected_screen_table|
  @dialog = DeviceNameDialog.new(driver, APP_TYPE)
  @dialog.click_button('close')

  # Reinitialise the expected screen to be returned to?
  expected_screen = {}

  expected_screen_table.hashes.map do |hash|
    expected_screen[hash['Device']] = { screen: hash['Expected Screen'] }
  end

  validate_expected_screen(expected_screen[APP_TYPE][:screen])

  # If phone then exit the mobile menu
  if APP_TYPE == 'Phone'
    @dialog.click_mobile_menu
    @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
  end
end

#####################################
##      Login error dialog         ##
#####################################

When /^OK is click in the login error dialog$/ do
  @dialog.click_button('close')
  sleep(5)
  @login_screen = LoginScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^OK is click in the error dialog on the browse screen$/ do
  @dialog.click_button('close')
  sleep(5)
  @dialog = Dialog.new(driver, APP_TYPE, TEST_ENV)
end

#################################
# Dialog error and highlighting #
#################################

When /^I type "(.*?)" in Username in login screen$/ do |key|
  input = @login_screen.username
  input.send_keys(key)
end

# Password field
Then /^Password in (login screen|dialog) (is|is not) highlighted$/ do |container, condition|
  @dialog = Dialog.new(driver, APP_TYPE, TEST_ENV)
  if container == "login screen"
    input = @login_screen.password
  elsif container == "dialog"
    input = @dialog.get_dialog_textfield('password')
  end
  highlighting_error_msg('Password', input, condition)
end

# Username field
Then /^Username in (login screen|dialog) (is|is not) highlighted$/ do |container, condition|
  @dialog = Dialog.new(driver, APP_TYPE, TEST_ENV)
  if container == "login screen"
    input = @login_screen.username
  elsif container == "dialog"
    input = @dialog.get_dialog_textfield('username')
  end
  highlighting_error_msg('Username', input, condition)
end

When /^I type "(.*?)" in Password in (login screen|dialog)$/ do |key, container|
  if container == "login screen"
    input = @login_screen.password
  elsif container == "dialog"
    input = @dialog.get_dialog_textfield('password')
  end
  input.click
  input.send_keys(key)
end

# Device field
Then /^Device in dialog box (is|is not) highlighted$/ do |condition|
  input = @dialog.get_dialog_textfield('deviceName')
  highlighting_error_msg('Device', input, condition)
end

When /^I type "(.*?)" in Device in dialog$/ do |key|
  input = @dialog.get_dialog_textfield('deviceName')
  input.send_keys(key)
end

# Error message
Then /^"(.*?)" error message is displayed in (purchase|parental control) dialog$/ do |error_message, container|
  if container == "purchase"
    error_msg = @dialog.get_dialog_text[2]
  elsif container == "parental control"
    error_msg = @dialog.get_dialog_text[1]
  end
  fail "Errot Text message: '#{error_message}' has not been displayed" unless error_msg == error_message
end

########################
# NPVR dialog specific #
########################

Then /^"(.*?)" dialog is shown$/ do |dialog_title|
  @dialog = Dialog.new(driver, APP_TYPE, TEST_ENV)
  sleep(1); #hack
  if APP_TYPE == 'Phone'
    dlg_title = @dialog.get_dialog_fullscreen_title
  else
    dlg_title = @dialog.get_dialog_title
  end
  fail "Dialog '#{dialog_title}' has not been displayed" unless dlg_title == dialog_title
end

When /^"(.*?)" button is clicked on dialog$/ do |dialog_button|
  if dialog_button == "Confirm"
    @dialog.click_submit
  else
    @dialog.click_button(dialog_button)
  end
end

And /^"(.*?)" checkbox in dialog is checked$/ do |checkbox_label|
  @dialog.click_checkbox_item(checkbox_label)
end



################
# DL2GO dialog #
################

When /^the dl2go dialog cancel button is clicked$/ do
  @dialog.get_dialog_buttons[0].click
end

When /^the dl2go dialog OK button is clicked$/ do
  @dialog.get_dialog_buttons[1].click
end

#############################################
# DL2G - Low Device Storage dialog specific #
#############################################

When /^OK is clicked in the Device Storage Low dialog$/ do
  @dialog.click_button('close')
  sleep(5)
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

###########################################################
# DL2G - Delete confirmation for download dialog specific #
###########################################################
When /^(Cancel|OK) option is selected for Delete Download confirmation dialog$/ do |confirmation_option|
  @dialog = Dialog.new(driver, APP_TYPE, TEST_ENV)
  if confirmation_option == "Cancel"
    @dialog.click_button('close')
  elsif confirmation_option == "OK"
    @dialog.click_button('ok')
  end
 end