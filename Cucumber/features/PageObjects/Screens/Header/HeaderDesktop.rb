# encoding: UTF-8
# Author: Elin Lloyd

# helper methods for specifically for desktop header
module HeaderDesktop
  # Search field in the desktop header
  def search_field
    @browser.find_element(:id, 'defaultToolbar').find_element(:class, 'search-inline-container').find_element(:class, 'search-inline-input')
  end

  # Search button in the desktop header
  def search_button
  #  @browser.find_element(:id, 'defaultToolbar').find_element(:class, 'search-inline-container').find_element(:class, 'search-inline-container-icon')
   @browser.find_element(:id, 'defaultToolbar').find_element(:class, 'search-inline-container').find_element(:class,'search-inline-container-icon-search')
   end

  # Click search in the desktop header
  def click_search
       click_clear_dropdown
       search_button.click
      end

  # Click away on the desktop
  def click_clear_dropdown
    header = @browser.find_element(:id, 'header')
    header.click
  end

  def search_for(search_string, clear_field_first)
    if search_string != :return
      # Make sure the texfield is cleared of any old searches 1st
      search_field.send_keys(:backspace) while search_field.attribute('value').length > 0 if clear_field_first
    end
    search_field.send_keys(search_string)
    sleep(1)
  end

  # Returns the search suggestions container element
  def search_suggestions
    # This needs to be in this class so we can check that it's not present
    @browser.find_element(:class, 'search-suggestions-inline-container')
  end

  # Click the back button and wait for the dialog not the be displayed (i.e for phone)
  def click_back
    back.click
    sleep(1)
  end

  def logout
    return @browser.find_element(:id, 'LogOutButton')
  end

  # This is required as mixin inheritance is broken in ruby - fixed in ruby 2.0 by using prepend rather than include
  def self.append_features(mod)
    instance_methods(false).each do |method|
      mod.send(:remove_method, method) if mod.instance_methods(false).include?(method)
    end
    super
  end
end
