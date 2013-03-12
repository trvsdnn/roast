require 'test_helper'

describe Roast::Host do

  it "validates the ip address" do
    ['foo', 'example.com', '127.0.0.1.1', '1277.0.0.1'].each do |ip|
      lambda { Roast::Host.new(ip, 'blah.dev') }.must_raise ArgumentError
    end
  end

  it "validates the hostname" do
    ['foo_com', '@#$asdf.com'].each do |hostname|
      lambda { Roast::Host.new('127.0.0.1', hostname) }.must_raise ArgumentError
    end
  end


end