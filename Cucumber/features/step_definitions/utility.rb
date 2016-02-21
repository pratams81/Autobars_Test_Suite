###################
# Startup/Utility #
###################

# A simple wait step.
# Please have a very good reason to use this
And /^wait (\d+) seconds$/ do |seconds|
  sleep(seconds.to_i)
end

# Open the application.
# When run against an app with DELAY_INITIALISATION set
# the browser will open, navigate to the app, but
# Launch.initialise will not be executed
Given /^app is opened/ do
  set_timeouts
  create_driver
end

# Continue into the application, start the initialisation process
Given /^app is started$/ do
  step "app is configured for cwmciwla lab"
  start_app
end

# Open and start the application, composes app is opened and app is started steps
Given /^app is open and started$/ do
  set_timeouts
  create_driver
  start_app
end

When /^the application is reloaded$/ do
  @driver.navigate.refresh
end

Then /^url is (.*)$/ do |url|
  wait.until { @driver.current_url == url }
end

Given /^the interceptor is loaded$/ do
  load_script(@driver, "js/XHRi.js")
  load_script(@driver, "js/XHRiUtil.js")
end

Given /^app is open and configured for ([A-z]*) tests/ do |test_type|
  set_timeouts
  create_driver
end


######################
# Screenshot methods #
######################

# Compare screenshots
# TODO: Verify this actually works, never tested
Then /compare screenshots "(.*?)" with "(.*?)"/ do |actual, expected|
  actual_screenshot_path = 'screenshots/actual/'
  expected_screenshot_path = 'screenshots/expected/'
  diff_screeshot_path = 'screenshots/diff/'
  images = [
    ChunkyPNG::Image.from_file(File.join(actual_screenshot_path, actual)),
    ChunkyPNG::Image.from_file(File.join(expected_screenshot_path, expected))
  ]

  diff = []

  images.first.height.times do |y|
    images.first.row(y).each_with_index do |pixel, x|
      diff << [x, y] unless pixel == images.last[x, y]
    end
  end

  puts "pixels (total): #{images.first.pixels.length}"
  puts "pixels changed: #{diff.length}"
  diff_percent = (diff.length.to_f / images.first.pixels.length) * 100
  puts "pixels changed (%): #{diff_percent}%"

  if diff_percent > 0
    x, y = diff.map { |xy| xy[0] }, diff.map { |xy| xy[1] }

    images.last.rect(x.min, y.min, x.max, y.max, ChunkyPNG::Color.rgb(0, 255, 0))
    images.last.save(File.join(diff_screeshot_path, 'diff.png'))
  else
    puts 'IMAGES MATCH'
  end
end

#####################
# JS Script Loading #
#####################
def load_script(driver, file)
  file = File.read(file)
  driver.execute_script(file)
end
