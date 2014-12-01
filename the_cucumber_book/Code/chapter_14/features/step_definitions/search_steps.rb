Capybara.match = :prefer_exact

When /^I search for "([^"]*)"$/ do |query|
  visit('/search')
  fill_in('query', with: query)
  click_button('Search')
end

Then /^the results should be:$/ do |expected_results|
  # wait until a matching element is found on the page
  find('ol.results li')
  results = [['content']] + page.all('ol.results li').map { |li| [li.text] }
  expected_results.diff!(results)
end

When /^I enter "([^"]*)" in the search field$/ do |query|
  visit('/search')
  fill_in('query', with: query)
end