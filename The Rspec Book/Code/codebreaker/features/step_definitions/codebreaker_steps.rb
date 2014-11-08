class TerminalOutput
  def messages
    @messages ||= []
  end

  def puts(message)
    messages << message
  end
end

def terminal_output
  @terminal_output ||= TerminalOutput.new
end

#
#  From Starts Game Feature
#
Given /^I am not yet playing$/ do
end

When /^I start a new game$/ do
  game = Codebreaker::Game.new(terminal_output)
  game.start('1234')
end

Then /^I should see "([^"]*)"$/ do |message|
  expect(terminal_output.messages).to include(message)
end

#
#  From Submits Guess Feature
#
Given /^the secret code is "([^"]*)"$/ do |secret|
  @game = Codebreaker::Game.new(terminal_output)
  @game.start(secret)
end

When /^I guess "([^"]*)"$/ do |guess|
  @game.guess(guess)
end

Then /^the mark should be "([^"]*)"$/ do |mark|
  expect(terminal_output.messages).to include(mark)
end