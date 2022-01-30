class CreateOrUpdateHostnamesService
  attr_reader :dns_record, :hostnames_attributes

  def initialize(args)
    @dns_record = args[:dns_record]
    @hostnames_attributes = args[:hostnames_attributes]
  end

  def call
    hostnames_attributes.each{ |hostname|
      model_hostname = Hostname.find_or_create_by!(name: hostname[:hostname])
      model_hostname.dns_records << dns_record
      model_hostname.save!
    }
  end
end