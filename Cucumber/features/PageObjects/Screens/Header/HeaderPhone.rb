# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for specifically for phone header
module HeaderPhone
  # Search button in mobile menu (Opens the mobile menu first)
  def search
    click_mobile_menu
    get_mobile_menu_element('search')
  end

  # Browse button in mobile menu (Opens the mobile menu first)
  def browse
    click_mobile_menu
    get_mobile_menu_element('browse')
  end

  def downloads
    click_mobile_menu
    get_mobile_menu_element('downloads')
  end

  # Settings button in mobile menu (Opens the mobile menu first)
  def settings
    click_mobile_menu
    get_mobile_menu_element('settings')
  end

  # Click the setting option in the mobile menu
  def click_settings
    settings.click
  end

  # Categories button in mobile menu (Opens the mobile menu first)
  def categories_mobile
    click_mobile_menu
    get_mobile_menu_element('menu')
  end

  # Click categories button in mobile menu (mobile menu must be opened first)
  def click_categories
    categories_mobile.click unless @browser.find_elements(:class, 'browse-category-menu-scroller').count == 1
  end

  # Channels button in mobile menu (Opens the mobile menu first)
  def channels_button
    click_mobile_menu
    get_mobile_menu_element('epg')
  end

  def get_mobile_menu_element(attribute_name)
    options_menu = @browser.find_elements(:class, 'dialog-overlay-settings').last
    Selenium::WebDriver::Wait.new(timeout: 15).until { options_menu.find_elements(:class, 'dialog-list-no-bg') }
    options = options_menu.find_elements(:class, 'dialog-list-no-bg')
    options.each do |option|
      data_attribute = option.attribute('data-attribute')
      return option if data_attribute == attribute_name
    end
    raise "mobile menu option with attribute name #{attribute_name} was not found"
  end

  # Mobile menu button
  def mobile_menu
    mobile_menu = menu_header.find_element(:id, 'menuButton')
    mobile_menu
  end

  # Click the mobile menu button and wait until dialog is displayed
  def click_mobile_menu
       if close_search_bar.displayed?
        close_search_bar.click
   end
    # categoryMenuScroller is required because category screen is not part of the dialogs yet
    count = @browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count
    mobile_menu.click
    wait = Selenium::WebDriver::Wait.new(timeout: 60)
    wait.until { (@browser.find_elements(:class, 'dialog-overlay-settings').count + @browser.find_elements(:class, 'dialog').count) != count }
    sleep(1)
  end

  # Click the mobile menu button when categories menu is opened and wait until the categories menu is no longer displayed
  def click_mobile_menu_from_categories
    # This is required instead of click_mobile_menu because categories screen is not part of the dialog class
    if category_menu_scroller.displayed?
      mobile_menu.click
      wait = Selenium::WebDriver::Wait.new(timeout: 60)
      wait.until { category_menu_scroller == false }
    end
  end

  # Returns the category menu scroller element if it exists otherwise it returns false
  def category_menu_scroller
    @browser.find_element(:id, 'categoryMenuScroller')
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
  end

  # returns the mobile menu element in the item_name matches the element text
  def mobile_menu_item(item_name)
    menu_list = @browser.find_elements(:class, 'dialog-list')
    item_found = nil
    menu_list.each do |item|
      item_found = item if item.text == item_name
    end
    item_found
  end

  def header_text
    menu_header_title.text
  end

  def menu_header
    @browser.find_element(:id, 'header')
  end

  def menu_header_title
    menu_header.find_element(:id, 'headerTitle')
  end

  # Search field in the desktop header
  def search_field
    search_field = @browser.find_element(:id, 'defaultToolbar').find_element(:class, 'search-inline-container').find_element(:class, 'search-inline-input')
    if search_field.displayed?
      search_field
    else
      open_search_field
      search_field
    end
  end

  def open_search_field
      @browser.find_element(:id, 'defaultToolbar').find_element(:id, 'searchButton').click
    end

  # Search button in the desktop header
  def search_button
        @browser.find_element(:id, 'defaultToolbar').find_element(:class, 'search-inline-container').find_element(:class, 'search-inline-container-icon-search')
  end
 #search bar
  def close_search_bar
        @browser.find_element(:id, 'defaultToolbar').find_element(:class, 'search-inline-container').find_element(:class, 'search-inline-container-icon-close')
  end

  # Click search in the desktop header
  def click_search
    search_button.click
  end

  #close the search bar
  def close_search
    close_search_bar.click
  end


  def search_for(search_string, clear_field_first)
    if search_string != :return
      # Make sure the texfield is cleared of any old searches 1st
      search_field.send_keys(:backspace) while search_field.attribute('value').length > 0 if clear_field_first
    end
    sleep(5)
    search_field.send_keys(search_string)
    sleep(1)
  end

  # Returns the search suggestions container element
  def search_suggestions
    # This needs to be in this class so we can check that it's not present
    @browser.find_element(:class, 'search-suggestions-inline-container')
  end

  # This is required as mixin inheritance is broken in ruby - fixed in ruby 2.0 by using prepend rather than include
  def self.append_features(mod)
    instance_methods(false).each do |method|
      mod.send(:remove_method, method) if mod.instance_methods(false).include?(method)
    end
    super
  end
end
