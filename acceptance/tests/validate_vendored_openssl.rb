test_name 'Validate openssl version and fips' do

  tag 'audit:high'

  def openssl_command(host)
    puts "privatebindir=#{host['privatebindir']}"
    "env PATH=\"#{host['privatebindir']}:${PATH}\" openssl"
  end

  agents.each do |agent|
    openssl = openssl_command(agent)

    step "check openssl version" do
      on(agent, "#{openssl} version -v") do |result|
        assert_match(/^OpenSSL 1\.1\.1/, result.stdout)
      end
    end
  end
end
