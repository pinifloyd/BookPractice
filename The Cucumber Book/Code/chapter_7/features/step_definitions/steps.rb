World(KnowsMyAccount)

# Given /^I have deposited (#{CAPTURE_CASH_AMOUNT}) in my account$/ do |amount|
#   my_account.deposit(amount)
#
#   expect(my_account.balance).to eq(amount), "Expected the balance to be #{amount}"
# end

When /^I withdraw (#{CAPTURE_CASH_AMOUNT})$/ do |amount|
  teller.withdraw_from(my_account, amount)
end

Then /^(#{CAPTURE_CASH_AMOUNT}) should be dispensed$/ do |amount|
  expect(cash_slot.contents).to eq(amount)
end