require 'uri'

###################################
# Open screens from browse screen #
###################################

When /^downloads screen is opened from browse screen$/ do
  @browse_screen.click_downloads
  @downloads_screen = DownloadsScreen.new(driver, APP_TYPE)
end

When /^downloads screen is opened from portal screen$/ do
  @portal_screen.click_downloads
  @downloads_screen = DownloadsScreen.new(driver, APP_TYPE)
end

Then /^the downloads button is not visible$/ do
  begin
    fail "Downloads button was visible when not expected"  if @browse_screen.downloads.visible?
  rescue
  end
end

Then /^the downloads button is visible$/ do
  fail "Downloads button was not visible when expected" if not @browse_screen.downloads.visible?
end

When /^search screen is opened from browse screen$/ do
  sleep(20)
  @browse_screen.search_for('noresults', true) if APP_TYPE == 'Desktop' || APP_TYPE == 'Phone'
  @browse_screen.click_search
  @search_screen = SearchScreenFullResults.new(driver, APP_TYPE)
end

When /^channels screen is opened from browse screen$/ do
  @browse_screen.click_channels
  loading_complete
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
end

When /^channels screen is opened from portal screen$/ do
  @portal_screen.click_channels
  loading_complete
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
end

When /^portal screen is opened from browse screen$/ do
  @browse_screen.click_portal
  loading_complete
  @portal_screen = PortalScreen.new(driver)
end

When /^portal screen is opened from channels screen$/ do
  @channels_screen.click_portal
  loading_complete
  @portal_screen = PortalScreen.new(driver)
end

When /^playlist screen is opened from browse screen$/ do
  @browse_screen.click_playlist
  loading_complete
  @playlist_screen = PlaylistScreen.new(driver, APP_TYPE)
end

When /^mediacard screen is opened from browse screen$/ do
  wait.until { @browse_screen.assets.length > 0 }

  @browse_screen.get_asset_by_index(1).click

  loading_complete
  @mediacard_screen = MediacardScreen.new(driver,  APP_TYPE)
end

When /^browse screen is opened from browse screen$/ do
  if  @browse_screen.back.displayed?
    @browse_screen.click_back
  else
    puts 'Already on browse screen - do nothing'
  end
end

When /^catchup screen is opened from browse screen$/ do
  @browse_screen.click_catchup
  loading_complete
  @catchup_screen = CatchupScreen.new(driver)
end

When /^channels screen is opened from catchup screen$/ do
  @catchup_screen.click_channels
  loading_complete
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
end

When /^browse screen is opened from catchup screen$/ do
  @catchup_screen.click_browse
  loading_complete
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^catchup screen is opened from channels screen$/ do
  @channels_screen.click_catchup
  loading_complete
  @catchup_screen = CatchupScreen.new(driver)
end

When /^mediacard screen is opened for a purchased asset from browse screen$/ do
  @browse_screen.get_asset_by_index(0).click

  loading_complete
  @mediacard_screen = MediacardScreen.new(driver,  APP_TYPE)

  # Check if asset has been purchased - if not then purchase it
  step "the asset is purchased if necessary"
end

When /^the sign-in dialog is opened from the browse screen$/ do
  @browse_screen.signin.click
end

###################################
# Open screens from search screen #
###################################

When /^search screen is opened from search screen$/ do
  puts 'Already on search screen - do nothing'
end

When /^channels screen is opened from search screen$/ do
  # The 1st click is required to clear the drop down if it being displayed
  @search_screen.click_clear_dropdown
  if (APP_TYPE == "Tablet")
    @search_screen = SearchScreenFullResults.new(driver,  APP_TYPE)
    @search_screen.close_search.click if @search_screen.close_search.displayed?
  end
  @search_screen.click_channels
  loading_complete
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
end

When /^mediacard screen is opened from search screen$/ do
  # TODO: Search string should not be here as could change when running against a different SDP/MDS
  @search_screen.search_for('The', true)
  @search_screen.search_for(:return, false)
  loading_complete
  @search_screen = SearchScreenFullResults.new(driver,  APP_TYPE)
  @search_screen.search_results[0].click
  loading_complete
  @mediacard_screen = MediacardScreen.new(driver,  APP_TYPE)
end

When /^browse screen is opened from search screen$/ do
  # The 1st click is required to clear the drop down if it being displayed
  @search_screen.click_clear_dropdown
  if (APP_TYPE == 'Tablet')
    @search_screen.close_search.click
  end
  @browse_screen.click_browse
  loading_complete
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^portal screen is opened from search screen$/ do
  # The 1st click is required to clear the drop down if it being displayed
  @search_screen.click_clear_dropdown
  if (APP_TYPE == 'Tablet')
    @search_screen.close_search.click
  end
  @portal_screen.click_browse
  loading_complete
  @portal_screen = PortalScreen.new(driver)
end

#####################################
# Open screens from channels screen #
#####################################

When /^search screen is opened from channels screen$/ do
  @channels_screen.search_for('noresults', true) if APP_TYPE == 'Desktop' || APP_TYPE == 'Phone'
  @channels_screen.click_search
  @search_screen = SearchScreenFullResults.new(driver,  APP_TYPE)
end

When /^channels screen is opened from channels screen$/ do
  puts 'Already on search screen - do nothing'
end

When /^mediacard screen is opened from channels screen$/ do
  event_clicked_successfully = false
  clickable_events = @channels_screen.clickable_epg_events('live')
  clickable_events.each do |event|
    if @channels_screen.click_program_event(event) == true
      event_clicked_successfully = true
      break
    end
  end
  fail 'event was not clicked successfully' if event_clicked_successfully == false
  @channels_screen.click_more_info if APP_TYPE == 'Tablet' || APP_TYPE == 'Desktop'
  loading_complete
  @mediacard_screen = MediacardScreen.new(driver,  APP_TYPE)
end

When /^mediacard screen is opened from channels screen for (live|future|past|unsubscribed|) event$/ do |event_type|
  event_clicked_successfully = false
  clickable_events = @channels_screen.clickable_epg_events(event_type)

  if event_type == "past" or event_type == "future"
    @channels_screen.scroll_to_epg_left_location(0)
    @channels_screen.click_program_event(clickable_events.first)
  else
    clickable_events.each do |event|
      if @channels_screen.click_program_event(event) == true
        event_clicked_successfully = true
        break
      end
    end
    fail "#{event_type} was not clicked successfully" if event_clicked_successfully == false
  end

  @channels_screen.click_more_info if APP_TYPE == 'Tablet' || APP_TYPE == 'Desktop'
  loading_complete
  @mediacard_screen = MediacardScreen.new(driver,  APP_TYPE)
end

When /^browse screen is opened from channels screen$/ do
  @channels_screen.click_browse
  loading_complete
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^browse screen is opened from portal screen$/ do
  @portal_screen.click_browse
  loading_complete
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^minimedia card is opened from channels screen for (all|live|future|past|unsubscribed) event$/ do |event_type|
  event_clicked_successfully = false
  clickable_events = @channels_screen.clickable_epg_events(event_type)
  clickable_events.each do |event|
    if @channels_screen.click_program_event(event) == true
      event_clicked_successfully = true
      break
    end
  end
  fail "#{event_type} was not clicked successfully" if event_clicked_successfully == false
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
end

When /^playlist screen is opened from channels screen$/ do
  @channels_screen.click_playlist
  loading_complete
  @playlist_screen = PlaylistScreen.new(driver, APP_TYPE)
end



######################################
# Open screens from mediacard screen #
######################################

When /^search screen is opened from mediacard screen$/ do
  @mediacard_screen.search_for('noresults', true) if APP_TYPE == 'Desktop' || APP_TYPE == 'Phone'
  @mediacard_screen.click_search
  loading_complete
  @search_screen = SearchScreenFullResults.new(driver,  APP_TYPE)
end

When /^channels screen is opened from mediacard screen$/ do
  @mediacard_screen.click_channels
  loading_complete
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
end

When /^channels screen is opened from mediacard screen by clicking back$/ do
  @mediacard_screen.click_back_from_mediacard
  loading_complete
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE)
end

When /^mediacard screen is opened from mediacard screen$/ do
  puts 'Already on search screen - do nothing'
end

When /^browse screen is opened from mediacard screen$/ do
  @mediacard_screen.click_browse
  loading_complete
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^browse screen is opened from mediacard screen by clicking back$/ do
  @mediacard_screen.click_back_from_mediacard
  loading_complete
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^playlist screen is opened from mediacard screen$/ do
  @mediacard_screen.click_playlist
  loading_complete
  @playlist_screen = PlaylistScreen.new(driver, APP_TYPE)
end


#####################################
# Open screens from playlist screen #
#####################################

When /^browse screen is opened from playlist screen$/ do
  @playlist_screen.click_browse
  loading_complete
  @browse_screen = BrowseScreen.new(driver, APP_TYPE, TEST_ENV)
end

When /^channels screen is opened from playlist screen$/ do
  @playlist_screen.click_channels
  loading_complete
  @channels_screen = ChannelsScreen.new(driver, APP_TYPE, TEST_ENV)
end


########################
# Open Settings Dialog #
########################
When /^settings dialog is opened from browse screen$/ do
  @browse_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^settings dialog is opened from search screen$/ do
  @search_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^settings dialog is opened from portal screen$/ do
  @portal_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^parental control dialog is opened from catchup screen$/ do
  @catchup_screen.parental_controls.click
  sleep(5)
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  wait.until { @driver.find_element(:class, 'dialog').displayed? }
end

When /^settings dialog is opened from channels screen$/ do
  @channels_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^settings dialog is opened from mediacard screen$/ do
  @mediacard_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^settings dialog is opened from downloads screen$/ do
  @downloads_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end


#####################
# Open About Dialog #
#####################

When /^about dialog is opened from browse screen$/ do
  @browse_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('about').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^about dialog is opened from portal screen$/ do
  @portal_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('about').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^about dialog is opened from search screen$/ do
  @search_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('about').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^about dialog is opened from channels screen$/ do
  @channels_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('about').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^about dialog is opened from mediacard screen$/ do
  @mediacard_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('about').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end


########################
# Open Language Dialog #
########################

When /^change language dialog is opened from browse screen$/ do
  @browse_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('changeLanguage').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end


When /^change language dialog is opened from portal screen$/ do
  @portal_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('changeLanguage').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^change language dialog is opened from search screen$/ do
  @search_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('changeLanguage').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^change language dialog is opened from channels screen$/ do
  @channels_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('changeLanguage').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^change language dialog is opened from mediacard screen$/ do
  @mediacard_screen.click_settings
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
  @dialog.settings_option('changeLanguage').click
  sleep(5)
  @dialog = Dialog.new(driver,  APP_TYPE)
end


################################
# Open Parental Control Dialog #
################################

When /^parental control dialog is opened from browse screen$/ do
  @browse_screen.parental_controls.click
  sleep(5)
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  wait.until { @driver.find_element(:class, 'dialog').displayed? }
end

When /^parental control dialog is opened from portal screen$/ do
  @portal_screen.parental_controls.click
  sleep(5)
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  wait.until { @driver.find_element(:class, 'dialog').displayed? }
end

When /^parental control dialog is opened from search screen$/ do
  @search_screen.click_clear_dropdown
  if (APP_TYPE == "Tablet")
    @search_screen = SearchScreenFullResults.new(driver,  APP_TYPE)
    @search_screen.close_search.click  if  @search_screen.close_search.displayed?
  end
  @search_screen.parental_controls.click
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  wait.until { @driver.find_element(:class, 'dialog').displayed? }
end

When /^parental control dialog is opened from channels screen$/ do
  @channels_screen.parental_controls.click
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  wait.until { @driver.find_element(:class, 'dialog').displayed? }
end

When /^parental control dialog is opened from mediacard screen$/ do
  @mediacard_screen.parental_controls.click
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  wait.until { @driver.find_element(:class, 'dialog').displayed? }
end

When /^parental control dialog is opened from downloads screen$/ do
  downloads_screen
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
end

When (/^the parental dialog is clicked from the browse screen$/) do
  @browse_screen.parental_controls.click
end

Then (/^the parental dialog is not shown from the browse screen$/) do
  step "wait 5 seconds"
  @dialog = ParentalControlDialog.new(driver,  APP_TYPE)
  wait.until { not (@driver.find_element(:class, 'dialog')) rescue true }
end

Then(/^the parental control button is disabled$/) do
  fail if not @browse_screen.parental_controls.attribute('disabled')
end

####################################
# Phone Only methods - menu button #
####################################

When /^menu button is clicked from browse screen$/ do
  @browse_screen.click_mobile_menu
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^menu button is clicked from search screen$/ do
  @search_screen.click_mobile_menu
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^menu button is clicked from channels screen$/ do
  @channels_screen.click_mobile_menu
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^menu button is clicked from mediacard screen$/ do
  @mediacard_screen.click_mobile_menu
  @dialog = Dialog.new(driver,  APP_TYPE)
end

When /^menu button is clicked from dialog screen after (browse|search|channels|mediacard) screen$/ do |screen_name|
  @dialog.click_mobile_menu
  validate_expected_screen(screen_name)
end

When /^menu button is clicked from categories screen$/ do
  @dialog.click_mobile_menu_from_categories
  @browse_screen = BrowseScreen.new(driver,  APP_TYPE, TEST_ENV)
end

When /^back is clicked in the header menu to return to (fullscreen-dialog|popup-dialog|browse|mediacard|search|channels|fullscreen-parental-control-dialog) screen$/ do |screen_name|
  @dialog.click_back
  validate_expected_screen(screen_name)
end

When /^back is clicked in the header menu to return to (fullscreen-dialog|popup-dialog|browse|mediacard|search|channels) screen for desktop$/ do |screen_name|
  if APP_TYPE == 'Desktop'
    @browse_screen.click_back
    validate_expected_screen(screen_name)
  end
end

Then /^playlist header button is not displayed$/ do
  wait.until { (not @browse_screen.playlist.displayed?) rescue true }
end

#################
# LogIn button #
#################

When /^the login button is clicked$/ do
  if APP_TYPE == "Desktop"
    @browse_screen.signin.click
  else
    @dialog.settings_option("login").click
  end
end

Then /^the login button is visible$/ do
  if APP_TYPE == "Desktop"
    fail "Login button was not visible when expected" if not @browse_screen.signin.displayed?
  else
    fail "Login button was not visible when expected" if not @dialog.settings_option("login").displayed?
  end
end

##################
# Catchup button #
##################
Then(/^catchup button is not displayed$/) do
  begin
    fail "Catchup button was displayed when not expected" if @browse_screen.catchup_button.displayed?
  rescue Selenium::WebDriver::Error::NoSuchElementError
  end
end

Then(/^catchup button is displayed$/) do
  wait.until{ @browse_screen.catchup_button.displayed? }
end