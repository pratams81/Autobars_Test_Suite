#################
# Logout button #
#################

When /^the logout button is clicked$/ do
  if APP_TYPE == "Desktop"
    @browse_screen.logout.click
  else
    @dialog.settings_option("logout").click
  end
end

Then /^the logout button is visible$/ do
  if APP_TYPE == "Desktop"
    fail "Logout button was not visible when expected" if not @browse_screen.logout.displayed?
  else
    fail "Logout button was not visible when expected" if not @dialog.settings_option("logout").displayed?
  end
end

Then(/^logout button is disabled$/) do
  fail 'Logout should be disabled' if !@mediacard_screen.logout.attribute(:class)=="mc-action-button-disabled webkit-render-fix"
end

Then /^the (Launch Online|Launch Offline) button is displayed$/ do |network_mode|
  if network_mode == "Launch Online"
    fail "Relaunch Online button was not visible when expected" if not @dialog.settings_option("checkNetworkDownloadToGo").displayed?
  else
    fail "Launch offline button was not visible when expected" if not @dialog.settings_option("goOffline").displayed?
  end
end

# ONLY VALID FROM BROWSE_SCREEN
Then /^rating is set to (ALL|U|PG|12|15)$/ do |rating|
  if APP_TYPE == 'phone'
    @browse_screen.click_settings

  else
    actual_rating = @browse_screen.parental_controls_rating.text
    if actual_rating != rating
      fail "Expected parental controls rating to be #{rating} but found #{actual_rating}"
    end
  end
end
