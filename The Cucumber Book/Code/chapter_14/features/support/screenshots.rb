After '@javascript' do |scenario|
  if scenario.failed?
    page.driver.browser.save_screenshot("html-report/#{scenario.__ID__}.png")
    embed("#{scenario.__ID__}.png", "image/png", "SCREENSHOT")
  end
end