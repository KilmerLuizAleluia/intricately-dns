module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        # TODO: Implement this action
      end

      # POST /dns_records
      def create
        dns_record = create_dns
        create_hostnames(dns_record)

        render json: { id: dns_record.id }, status: :created
      end

      def dns_params
        params.permit(
          :page,
          :included,
          :excluded,
          dns_records: [:ip, hostnames_attributes: [:hostname]]
        )
      end

      private

      def create_dns
        ip = dns_params[:dns_records][:ip]
        DnsRecord.create!(ip_address: ip)
      end

      def create_hostnames(dns_record)
        hostnames_attributes = dns_params[:dns_records][:hostnames_attributes]
        hostnames_attributes.each{ |hn|
          Hostname.create!(name: hn[:hostname], dns_records: [dns_record])
        }
      end
    end
  end
end
