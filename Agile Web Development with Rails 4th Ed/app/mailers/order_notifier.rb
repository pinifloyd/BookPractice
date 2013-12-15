class OrderNotifier < ActionMailer::Base
  default from: "Sergey Hanchar <depot@example.com>"

  def received(order)
    @order = order

    mail to: order.email, subject: 'Подтверждение заказа в Pragmatic Store'
  end

  def shipped(order)
    @order = order

    mail to: order.email, subject: 'Заказ из Pragmatic Store отправлен'
  end
end
