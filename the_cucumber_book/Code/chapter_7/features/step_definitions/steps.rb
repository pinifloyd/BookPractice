Then /^(#{CAPTURE_CASH_AMOUNT}) should be dispensed$/ do |amount|
  expect(cash_slot.contents).to eq(amount)
end