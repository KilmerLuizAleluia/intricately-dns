class BuildRelatedHostnamesJsonService
  attr_reader :dns_records, :included

  def initialize(args)
    @dns_records = args[:dns_records]
    @included = args[:included]
  end

  def call
    hn_ids = []
    related_hostnames = []
    dns_records.each { |dns| hn_ids << dns.hostname_ids }
    hn_frequencies = hn_ids.flatten.tally

    hn_frequencies.each { |hn|
      next if included_ids.include?(hn[0])
      json = {
        count: hn[1],
        hostname: Hostname.find(hn[0]).name
      }
      related_hostnames << json
    }

    related_hostnames
  end

  def included_ids
    return [] unless included.present?
    names = included.split(',')
    names.map { |name| Hostname.find_by(name: name).id }
  end
end