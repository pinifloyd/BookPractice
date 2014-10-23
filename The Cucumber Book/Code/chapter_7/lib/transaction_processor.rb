require_relative 'transaction_queue'
require_relative 'balance_store'

transaction_queue = TransactionQueue.new
balance_store     = BalanceStore.new

puts 'transaction processor ready'

loop do
  transaction_queue.read do |message|
    balance_store.balance = balance_store.balance + message.to_i
  end
end