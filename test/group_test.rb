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
    @group.hosts.include?(host).must_equal true
  end

  it "disables and enables all hosts in the group" do
    @group.disable!
    @group.must_be :disabled?
    @group.hosts.all? { |h| h.disabled? }.must_equal true

    @group.enable!
    @group.must_be :enabled?
    @group.hosts.all? { |h| h.enabled? }.must_equal true
  end

  it "finds hosts by ip address" do
    results = @group.find_host('127.0.0.1')
    results.wont_be :empty?
    results.size.must_equal 1
    results.first.must_equal @group.hosts.first
  end

  it "finds hosts by hostname" do
    results = @group.find_host('example.org')
    results.wont_be :empty?
    results.size.must_equal 1
    results.first.must_equal @group.hosts.last
  end

  it "deletes hosts by ip address" do
    deleted = @group.hosts.first
    results = @group.delete_host('127.0.0.1')
    results.wont_be :empty?
    results.size.must_equal 1
    results.first.must_equal deleted
    @group.hosts.size.must_equal 1
    @group.hosts.include?(deleted).wont_equal true
  end

  it "deletes hosts by hostname" do
    deleted = @group.hosts.last
    results = @group.delete_host('example.org')
    results.wont_be :empty?
    results.size.must_equal 1
    results.first.must_equal deleted
    @group.hosts.size.must_equal 1
    @group.hosts.include?(deleted).wont_equal true
  end

  it "returns an empty array if host could not be found" do
    results = @group.find_host('something.else')
    results.must_be :empty?
  end

  it "outputs host entries to cli correctly" do
    @group.to_cli.must_equal <<-RESULT.gsub(/^\s{4}/, "")
     - \e[4mbase\e[0m
          foo.bar.dev    127.0.0.1\e[0m
          example.org    10.0.1.1\e[0m
    RESULT
  end

  it "converts the group to a string correctly" do
    @group.to_hosts_file.must_equal <<-RESULT.gsub(/^\s+/, "")
    ## [base]
    127.0.0.1    foo.bar.dev
    10.0.1.1     example.org
    RESULT
  end

end
