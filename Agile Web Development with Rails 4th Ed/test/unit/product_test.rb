require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test 'product price must be positive' do
    product = Product.new(title: 'Programming Ruby', description: 'Description', image_url: 'image.jpg')

    product.price = -1
    assert product.invalid?
    assert_equal 'must be greater than or equal to 0.01', product.errors[:price].join('; ')

    product.price = 0
    assert product.invalid?
    assert_equal 'must be greater than or equal to 0.01', product.errors[:price].join('; ')

    product.price = 1
    assert product.valid?
  end

  test 'image url' do
    %w(red.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif).each do |name|
      assert new_product(name).valid?, "#{name} should not be invalid"
    end

    %w(fred.doc fred.gif/more fred.gif.more).each do |name|
      assert new_product(name).invalid?, "#{name} should not be valid"
    end
  end

  test 'product is not valid without a unique title' do
    product = Product.new(title: products(:ruby).title, description: 'Description', price: 1, image_url: 'image.jpg')
    assert !product.save
    assert_equal 'has already been taken', product.errors[:title].join('; ')
  end

  test 'product is not valid with title less than 10 simbols' do
    product = Product.new(title: 'Title', description: 'Description', price: 1, image_url: 'image.jpg')
    assert !product.save
    assert_equal 'is too short (minimum is 10 characters)', product.errors[:title].join('; ')
  end

  def new_product(image_url)
    Product.new(title: 'Programming Ruby', description: 'Description', price: 1, image_url: image_url)
  end

end
