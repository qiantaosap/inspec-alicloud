title "Test single AliCloud VPN"

alicloud_vpc_id = input(:alicloud_vpc_id, value: "", description: "AliCloud VPC ID")
alicloud_vpn_gateway_id = input(:alicloud_vpn_gateway_id, value: "", description: "AliCloud VPC Gateway ID")
alicloud_vpn_gateway_name = input(:alicloud_vpn_gateway_name, value: "", description: "AliCloud VPC Gateway Name")
alicloud_vpn_gateway_description = input(:alicloud_vpn_gateway_description, value: "", description: "AliCloud VPN Gateway description")
alicloud_vpn_gateway_status = input(:alicloud_vpn_gateway_status, value: "", description: "AliCloud VPC Gateway status")
alicloud_vpn_gateway_business_status = input(:alicloud_vpn_gateway_business_status, value: "", description: "AliCloud VPC Gateway business status")
alicloud_vpn_gateway_internet_ip = input(:alicloud_vpn_gateway_internet_ip, value: "", description: "AliCloud VPN Gateway internet IP")
alicloud_vpn_gateway_bandwidth = input(:alicloud_vpn_gateway_bandwidth, value: "", description: "AliCloud VPN Gateway peak bandwidth")

control "alicloud-vpn-gateway-1.0" do
  impact 1.0
  title "Ensure AliCloud VPN Gateway has the correct properties."

  describe alicloud_vpn_gateway(alicloud_vpn_gateway_id) do
    it { should exist }
    its("vpn_gateway_name") { should eq alicloud_vpn_gateway_name }
    its("description") { should eq alicloud_vpn_gateway_description }
    its("vpc_id") { should eq alicloud_vpc_id }
    its("status") { should cmp alicloud_vpn_gateway_status }
    its("business_status") { should cmp alicloud_vpn_gateway_business_status }
    its("internet_ip") { should eq alicloud_vpn_gateway_internet_ip }
    its("ipsec_enabled") { should cmp "enable" }
    its("ssl_enabled") { should cmp "disable" }
    its("spec") { should cmp alicloud_vpn_gateway_bandwidth + "M" }
  end

  describe alicloud_vpc(vpc_id: "no-such-vpc") do
    it { should_not exist }
  end
end
