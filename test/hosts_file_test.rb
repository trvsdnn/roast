require 'test_helper'

describe Roast::HostsFile do
  FILES_PATH = File.expand_path("../files", __FILE__)

  after do
    baks = Dir[File.join(FILES_PATH, '*.bak')]
    news = Dir[File.join(FILES_PATH, '*.new')]
    FileUtils.rm(baks)
    FileUtils.rm(news)
  end

  it "parses a hostfile and creates groups and host entries" do
    hosts = hosts_from_file('one')
    hosts.groups.length.must_equal 2
    [[ '127.0.0.1', 'local.dev' ], [ '10.0.1.2', 'something.dev' ]].each_with_index do |host, i|
      hosts['base'].hosts[i].ip_address.must_equal host.first
      hosts['base'].hosts[i].hostname.must_equal host.last
    end
    [[ '10.0.20.1', 'staging.something.com' ], [ '10.0.20.2', 'staging-two.something.com' ]].each_with_index do |host, i|
      hosts['staging'].hosts[i].ip_address.must_equal host.first
      hosts['staging'].hosts[i].hostname.must_equal host.last
    end
  end

  it "parses a hostfile and writes with updated entries" do
    hosts = hosts_from_file('one')
    hosts.groups.length.must_equal 2
    hosts['base'] << Roast::Host.new('127.0.0.1', 'example.org')
    hosts.write(File.join(FILES_PATH, 'one.new'))
  end

  it "does not create a backup file if the output file is a different name" do
    hosts = hosts_from_file('one')
    hosts.groups.length.must_equal 2
    hosts['base'] << Roast::Host.new('127.0.0.1', 'example.org')
    hosts.write(File.join(FILES_PATH, 'two.new'))
    File.exist?(File.join(FILES_PATH, 'one.bak')).wont_equal true
  end

  it "creates a backup file if the output file is the same as the input file" do
    hosts = hosts_from_file('one')
    hosts.groups.length.must_equal 2
    hosts['base'] << Roast::Host.new('127.0.0.1', 'example.org')
    hosts.write
    File.exist?(File.join(FILES_PATH, 'one.bak')).must_equal true
  end

  def hosts_from_file(file_name)
    path = File.join(FILES_PATH, file_name)
    @hosts = Roast::HostsFile.new(path).read
  end

end
