################################
# Augmentator Helper Functions #
################################

Given /^augmentator has cleared routes$/ do
  openroute("/clearroutes")
end

And /^augmentator has opened npvr sdp$/ do
  openroute("/appendfileconfig=npvrLocker/sdp.json")
end

And /^augmentator has opened npvr mds$/ do
  openroute("/appendfileconfig=npvrLocker/mds.json")
end

And /^augmentator has opened npvr locker$/ do
  openroute("/appendfileconfig=npvrLocker/npvrLocker.json")
end

And /^augmentator has loaded npvr test data from "(.*?)"$/ do |filename|
  ending = ""
  if filename != ""
    ending = "?file=" + filename
  end
  openroute("/readRecordings" + ending)
end

And /^augmentator has cleared recordings$/ do 
  openroute("/clearRecordings")
end

And /^augmentator has set recording "(.*?)" to status "(.*?)"$/ do |id, status|
  openroute("/changerecordingstate?recordingId=" + id + "&status=" + status)
end

And /^augmentator has opened SDP Device Type augmentation$/ do
  openroute("/appendfileconfig=deviceContext/deviceContext.json")
end

def openroute(route)
  url = "http://localhost:" + ENV['AUGMENTATOR_PORT'] + route
  @driver.execute_script("new $N.apps.core.XssRequest('GET', '#{url}', function() {}, function() {}).send();", timeout: 1000)
  sleep(1)
end
