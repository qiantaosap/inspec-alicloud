title "Test AliCloud VPN Gateway in bulk"

control "alicloud-vpn-gateways-1.0" do
  impact 1.0
  title "Ensure AliCloud VPN Gateway plural resource has the correct properties."

  describe alicloud_vpn_gateways do
    it { should exist }
    its("entries.count") { should be >= 1 }
  end
end
