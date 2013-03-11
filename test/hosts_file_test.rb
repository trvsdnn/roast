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
    hosts.groups.length.must_equal 3
    [[ '127.0.0.1', 'local.dev' ], [ '10.0.1.2', 'something.dev' ]].each_with_index do |host, i|
      hosts['base'].hosts[i].ip_address.must_equal host.first
      hosts['base'].hosts[i].hostname.must_equal host.last
    end
    [[ '10.0.20.1', 'staging.something.com' ], [ '10.0.20.2', 'staging-two.something.com' ]].each_with_index do |host, i|
      hosts['staging'].hosts[i].ip_address.must_equal host.first
      hosts['staging'].hosts[i].hostname.must_equal host.last
    end
  end

  it "adds entries to an existing group" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.add('staging', '10.0.1.1', 'added-entry.dev')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    10.0.1.1      added-entry.dev
    ## TSAOR
    RESULT
  end

  it "adds a new entry and group if the group doesn't exist" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.add('testing', '10.0.30.1', 'something.testing')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    ## TSAOR

    ## ROAST [testing]
    10.0.30.1    something.testing
    ## TSAOR
    RESULT
  end

  it "disables an entry via hostname" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.disable('local.dev')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    # 127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "disables entries via ip address" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.disable('127.0.0.1')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    # 127.0.0.1    local.dev
    10.0.1.2     something.dev
    # 127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "enables an entry via hostname" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.enable('staging.three.something.com')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "enables an entry via ip address" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.enable('10.10.30.1')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "enables a group" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.enable_group('foo')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    10.0.3.1    foo.bar
    10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "disables a group" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.disable_group('staging')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    # 10.0.20.1     staging.something.com
    # 10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "deletes an entry via hostname" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.delete('local.dev')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "deletes entries via ip address" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.delete('127.0.0.1')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    10.0.1.2    something.dev
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR

    ## ROAST [staging]
    10.0.20.1     staging.something.com
    10.0.20.2     staging-two.something.com
    # 10.10.30.1    staging.three.something.com
    ## TSAOR
    RESULT
  end

  it "deletes a group" do
    hosts    = hosts_from_file('one')
    new_path = File.join(FILES_PATH, 'one.new')

    hosts.groups.length.must_equal 3
    hosts.delete_group('staging')
    hosts.write(new_path)
    File.read(new_path).must_equal <<-RESULT.gsub(/^ +/, "").chomp
    127.0.0.1	localhost
    255.255.255.255	broadcasthost

    127.0.0.1 hl2rcv.adobe.com # HEHE
    10.0.1.1 example.dev

    ::1             localhost
    fe80::1%lo0     localhost

    ## ROAST [base]
    127.0.0.1    local.dev
    10.0.1.2     something.dev
    127.0.0.1    example.org
    ## TSAOR

    ## ROAST [foo]
    # 10.0.3.1    foo.bar
    # 10.0.3.2    food.bar
    ## TSAOR
    RESULT
  end

  it "does not create a backup file if the output file is a different name" do
    hosts = hosts_from_file('one')
    hosts.groups.length.must_equal 3
    hosts['base'] << Roast::Host.new('127.0.0.1', 'example.org')
    hosts.write(File.join(FILES_PATH, 'two.new'))
    File.exist?(File.join(FILES_PATH, 'one.bak')).wont_equal true
  end

  it "creates a backup file if the output file is the same as the input file" do
    hosts = hosts_from_file('one')
    hosts.groups.length.must_equal 3
    hosts['base'] << Roast::Host.new('127.0.0.1', 'example.org')
    hosts.write
    File.exist?(File.join(FILES_PATH, 'one.bak')).must_equal true
  end

  def hosts_from_file(file_name)
    path = File.join(FILES_PATH, file_name)
    @hosts = Roast::HostsFile.new(path).read
  end

end
