# encoding: UTF-8
require 'selenium-webdriver'
require 'yaml'

screenshot_id = 0
# This is required to parse the language characters correctly
YAML::ENGINE.yamler = 'syck'
# Load data mappings
data_mappings = YAML.load(File.read("features/test_data_mapping/#{TEST_ENV}/assets.yml"))
data_maps = YAML.load(File.read("features/test_data_mapping/environment.yml"))

Before do
  validate_app_type
  validate_device_type
  set_timeouts
  @data_mappings = data_mappings
  @data_maps = data_maps
  @reinstall_app = false
end

After do |scenario|
   quit_browser
  # Reset step numbers
  screenshot_id = 0
end

AfterStep do |scenario|
  # TODO: tidy this up if trail proves successful
  if TAKE_SCREENSHOTS == 'True'
    screenshot_id = screenshot_id + 1
    if scenario.class == Cucumber::Ast::OutlineTable::ExampleRow
      scenario_name = scenario.scenario_outline.name.tr(' ', '_').tr('/', '_')
      example_name = scenario.name.tr(' ', '_').tr('/', '_').tr('|', '')
    else
      scenario_name = scenario.name.tr(' ', '_').tr('/', '_')
      example_name = nil
    end

    FileUtils.mkdir("screenshots/actual/#{scenario_name}") unless FileTest.directory?("screenshots/actual/#{scenario_name}")

    if example_name
      FileUtils.mkdir("screenshots/actual/#{scenario_name}/#{example_name}") unless FileTest.directory?("screenshots/actual/#{scenario_name}/#{example_name}")
      save_screenshot_embed("screenshots/actual/#{scenario_name}/#{example_name}/#{screenshot_id}.png", "#{screenshot_id}")
    else
      save_screenshot_embed("screenshots/actual/#{scenario_name}/#{example_name}/#{screenshot_id}.png", "#{screenshot_id}")
    end

    compare_screenshots
  end
end

# Compares images for the test step (expected screenshot need to be saved to screenshots/expected/<sceanrio_name>/<example_name>/<step_number>.png)
def compare_screenshots
  if COMPARE_SCREENSHOTS == 'True' && example_name
    # If there is a expected image then compare
    if FileTest.exists?("screenshots/expected/#{scenario_name}/#{example_name}/#{screenshot_id}.png")
      FileUtils.mkdir("screenshots/diff/#{scenario_name}/#{example_name}") unless FileTest.directory?("screenshots/diff/#{scenario_name}/#{example_name}")
      compare_images("screenshots/actual/#{scenario_name}/#{example_name}/#{screenshot_id}.png", "screenshots/expected/#{scenario_name}/#{example_name}/#{screenshot_id}.png",
                     "screenshots/diff/#{scenario_name}/#{example_name}/#{screenshot_id}.png", image_difference_percentage_tolerance)
    end
  elsif COMPARE_SCREENSHOTS == 'True' && !example_name
    if FileTest.exists?("screenshots/expected/#{scenario_name}/#{screenshot_id}.png")
      FileUtils.mkdir("screenshots/diff/#{scenario_name}") unless FileTest.directory?("screenshots/diff/#{scenario_name}")
      compare_images("screenshots/actual/#{scenario_name}/#{screenshot_id}.png", "screenshots/expected/#{scenario_name}/#{screenshot_id}.png",
                     "screenshots/diff/#{scenario_name}/#{screenshot_id}.png", image_difference_percentage_tolerance)
    end
  end
end

# Compares 2 images and fails if the differnce is not within the tolarance
def compare_images(actual, expected, diff_image, image_difference_percentage_tolerance)
  images = [
    ChunkyPNG::Image.from_file(actual),
    ChunkyPNG::Image.from_file(expected)
  ]

  diff = []

  images.first.height.times do |y|
    images.first.row(y).each_with_index do |pixel, x|
      diff << [x, y] unless pixel == images.last[x, y]
    end
  end

  diff_percent = (diff.length.to_f / images.first.pixels.length) * 100

  if diff_percent > image_difference_percentage_tolerance
    x, y = diff.map { |xy| xy[0] }, diff.map { |xy| xy[1] }

    images.last.rect(x.min, y.min, x.max, y.max, ChunkyPNG::Color.rgb(0, 255, 0))
    images.last.save(diff_image)
    puts "pixels (total): #{images.first.pixels.length}"
    puts "pixels changed: #{diff.length}"
    puts "pixels changed (%): #{diff_percent}%"
    embed(diff_image, 'image/png', 'diff-screenshot')
    fail "Images are not within the tolerence of #{image_difference_percentage_tolerance}%"
  end
end

# Saves a screenshots and embeds it in the test results
def save_screenshot_embed(screenshot, id)
  if driver
    driver.save_screenshot(screenshot)
    embed(screenshot, 'image/png', "Screenshot #{id}")
  end
end
