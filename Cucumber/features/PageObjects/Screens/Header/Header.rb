# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for header bar
class Header
  def initialize(browser, app_type, env = 'ott.nagra.com')
    @browser = browser
    if app_type == 'Phone'
      self.class.send(:include, HeaderPhone)
    elsif app_type == 'Desktop'
      self.class.send(:include, HeaderDesktop)
    end
  end

  # Category menu button (clickable portion)
  def all_categories
    return @browser.find_element(:id, 'categoryMenuButton').find_element(:css, 'i')
  end

  def categories_container
    element = @browser.find_element(:class, 'browse-category-menu-scroller')
    element.define_singleton_method(:open?) do
      return attribute('class').include?('transition-in')
    end
    return element
  end

  # Search button
  def search
    @browser.find_element(:id, 'searchButton')
  end

  # Click search button and wait for dialog not to be displayed (i.e. for phone)
  def click_search
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    # The 1st click is required to clear the drop down if it being displayed
    search.click

    if count > 0
      wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    end
    sleep(1)
  end

  # Click header to clear the search dropdown
  def click_clear_dropdown
    header = @browser.find_element(:id, 'header')
    @browser.touch.single_tap(header).perform
  end

  # search bar for tablets
  def search_bar
    return @browser.find_element(:id, 'defaultToolbar').find_element(:class, 'search-inline-container').find_element(:class, 'search-inline-container-icon-close')
  end

  # Click to close the search text container for tablets
  def close_search_bar
    search_bar.click
  end

  # Settings button
  def settings
    @browser.find_element(:id, 'settingsButton')
  end

  #log out button
  def logout
      @browser.find_element(:id, 'LogOutButton')
  end

  def logout_click
      logout.click
  end

  #logIn button
  def signin
    @browser.find_element(:id, 'LogInButton')
  end

  # Click the setting button and wait for dialog to be displayed
  def click_settings
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    # To close the search bar if already open, so that settings  menu can be clicked
    close_search_bar if APP_TYPE == 'Tablet' && search_bar.displayed?

    settings.click
    if count > 0
      wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    end
    sleep(1)
  end

  # Parental Controls button
  def parental_controls
    @browser.find_element(:id, 'parentalButton')
  end

  def parental_lock_attribute
    return @browser.find_element(:class, 'icon-lock')
  end

  def parental_unlock_attribute
    return @browser.find_element(:class, 'icon-unlock')
  end

  def parental_controls_rating
    if APP_TYPE == "Phone"
      raise "parental_controls_rating not valid for Phone app_type"
    else
      return parental_controls.find_element(:css, 'sup')
    end
  end

  # Channels button
  def channels_button
    @browser.find_element(:id, 'channelsButton')
  end

  # Click the channels button and wait for the dialog to not to be displayed (i.e. for phone)
  def click_channels
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    channels_button.click
    if count > 0
      wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    end
    sleep(1)
  end

  # Portal button
  def portal_button
    @browser.find_element(:id, 'portalButton')
  end

  #Catchup button
  def catchup_button
      @browser.find_element(:id, 'catchupButton')
  end

 
  # Click the portal button and wait for the dialog to not to be displayed
  def click_portal
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    portal_button.click
    if count > 0
      wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    end
    sleep(1)
  end

 # Click the catchup button and wait for the dialog to not to be displayed

  def click_catchup
      count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
      catchup_button.click
      if count > 0
          wait = Selenium::WebDriver::Wait.new(timeout: 60)
          wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
      end
      sleep(1)
  end

  # Browse button
  def browse
    @browser.find_element(:id, 'browseButton')
  end
   # Downloads button
  def downloads
    @browser.find_element(:id, 'downloadsButton')
  end

  # Playlist button
  def playlist
    @browser.find_element(:id, 'playlistButton')
  end

  # Click the browse button and wait for the dialog not to be displayed (i.e. for phone)
  def click_browse
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    browse.click
    if count > 0
          wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    end
    sleep(1)
  end

  def click_downloads
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    downloads.click
    if count > 0
      wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    end
    sleep(1)
  end

  def click_playlist
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    playlist.click
    if count > 0
          wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    end
    sleep(1)
  end

  # Back button (this is displayed on the mediacard header)
  def back
    wait = Selenium::WebDriver::Wait.new(timeout: 60)
    wait.until { @browser.find_element(:id, 'backButton').find_element(:class, 'icon-chevron-left') }
  end

  # Click the back button and wait for the dialog not the be displayed (i.e for phone)
  def click_back
    count = count_dialogs
    back.click
    if count > 0
      wait = Selenium::WebDriver::Wait.new(timeout: 10)
      wait.until { count_dialogs != count }
    end
    sleep(1)
  end

  # Returns the number of dialogs being displayed
  def count_dialogs
    @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count + @browser.find_elements(:class, 'browse-category-menu-scroller').count
  end

  # Click the back button and wait for the dialog not the be displayed (i.e for phone)
  def click_back_from_mediacard
    back.click
    sleep(5)
  end
end
