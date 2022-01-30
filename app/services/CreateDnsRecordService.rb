class CreateDnsRecordService
  attr_reader :ip

  def initialize(args)
    @ip = args[:ip]
  end

  def call
    DnsRecord.find_or_create_by!(ip_address: ip)
  end
end
