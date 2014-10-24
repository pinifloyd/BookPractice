Given /^the system knows about the following fruit:$/ do |fruits|
  FruitApp.data = fruits.hashes
end

When /^the client requests GET (.*)$/ do |path|
  get(path)
end

Then /^the response should be JSON:$/ do |json|
  expect(JSON.parse(last_response.body)).to eq(JSON.parse(json))
end