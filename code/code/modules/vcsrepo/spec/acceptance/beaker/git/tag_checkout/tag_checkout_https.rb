test_name 'C3449 - checkout a tag (https protocol)'

# Globals
repo_name = 'testrepo_tag_checkout'
tag = '0.0.2'

hosts.each do |host|
  ruby = (host.is_pe? && '/opt/puppet/bin/ruby') || 'ruby'
  tmpdir = host.tmpdir('vcsrepo')
  step 'setup - create repo' do
    git_pkg = 'git'
    if host['platform'] =~ %r{ubuntu-10}
      git_pkg = 'git-core'
    end
    install_package(host, git_pkg)
    my_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../..'))
    scp_to(host, "#{my_root}/acceptance/files/create_git_repo.sh", tmpdir)
    on(host, "cd #{tmpdir} && ./create_git_repo.sh")
  end
  step 'setup - start https server' do
    https_daemon = <<-MANIFEST
    require 'webrick'
    require 'webrick/https'
    server = WEBrick::HTTPServer.new(
    :Port               => 8443,
    :DocumentRoot       => "#{tmpdir}",
    :SSLEnable          => true,
    :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
    :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open("#{tmpdir}/server.crt").read),
    :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open("#{tmpdir}/server.key").read),
    :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ])
    WEBrick::Daemon.start
    server.start
    MANIFEST
    create_remote_file(host, '/tmp/https_daemon.rb', https_daemon)
    # on(host, "#{ruby} /tmp/https_daemon.rb")
  end

  teardown do
    on(host, "rm -fr #{tmpdir}")
    on(host, "ps ax | grep '#{ruby} /tmp/https_daemon.rb' | grep -v grep | awk '{print \"kill -9 \" $1}' | sh ; sleep 1")
  end

  step 'get tag sha from repo' do
    on(host, "git --git-dir=#{tmpdir}/testrepo.git rev-list HEAD | tail -1") do |res|
      @sha = res.stdout.chomp
    end
  end

  step 'checkout a tag with puppet' do
    pp = <<-MANIFEST
    vcsrepo { "#{tmpdir}/#{repo_name}":
      ensure => present,
      source => "https://github.com/johnduarte/testrepo.git",
      provider => git,
      revision => '#{tag}',
    }
    MANIFEST

    apply_manifest_on(host, pp, catch_failures: true)
    apply_manifest_on(host, pp, catch_changes: true)
  end

  step "verify checkout out tag is #{tag}" do
    on(host, "ls #{tmpdir}/#{repo_name}/.git/") do |res|
      fail_test('checkout not found') unless res.stdout.include? 'HEAD'
    end

    on(host, "git --git-dir=#{tmpdir}/#{repo_name}/.git name-rev HEAD") do |res|
      fail_test('tag not found') unless res.stdout.include? tag.to_s
    end
  end
end
