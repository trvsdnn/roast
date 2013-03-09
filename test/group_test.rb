require 'test_helper'

describe Roast::Group do

  before do
    @group = Roast::Group.new(:base)
    @group <<  Roast::Host.new('127.0.0.1', 'foo.bar.dev')
    @group << Roast::Host.new('10.0.1.1', 'example.org')
  end

  it "adds a host to the group" do
    host = Roast::Host.new('127.0.0.1', 'something.dev')
    @group << host
    @group.hosts.has_key?(host.hostname).must_equal true
  end

  it "outputs host entries to cli correctly" do
    @group.to_cli.must_equal <<-RESULT.gsub(/^\s{4}/, "")
     - \e[4mbase\e[0m
          foo.bar.dev    127.0.0.1\e[0m
          example.org    10.0.1.1\e[0m
    RESULT
  end

  it "converts the group to a string correctly" do
    @group.to_hosts_file.must_equal <<-RESULT.gsub(/^\s+/, "").chomp
    ## ROAST [base]
    127.0.0.1    foo.bar.dev
    10.0.1.1     example.org
    ## TSAOR
    RESULT
  end

end
