class SelectIncludedHostnamesService
  attr_reader :dns_records, :included

  def initialize(args)
    @dns_records = args[:dns_records]
    @included = args[:included]
  end

  def call
    dns_records.select { |dns|
      ((included_ids) - dns.hostname_ids).empty?
    }
  end

  def included_ids
    return [] unless included.present?
    names = included.split(',')
    names.map { |name| Hostname.find_by(name: name).id }
  end
end