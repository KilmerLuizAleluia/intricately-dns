module Api
  module V1
    class DnsRecordsController < ApplicationController
      PAGE_SIZE = 30

      # GET /dns_records
      def index
        return render status: :unprocessable_entity if dns_params[:page].nil?

        dns_records = call_paginated_dns_service
        json_response = call_build_index_json_service(dns_records)

        render json: json_response, status: :ok
      end

      # POST /dns_records
      def create
        dns_record = call_create_dns_service
        call_create_or_update_hostnames_service(dns_record)

        render json: { id: dns_record.id }, status: :created
      end

      private

      def call_paginated_dns_service
        RetrievePaginatedDnsService.new(
          page_size: PAGE_SIZE,
          page: dns_params[:page],
          included: dns_params[:included],
          excluded: dns_params[:excluded]
        ).call
      end

      def call_build_index_json_service(dns_records)
        BuildIndexJsonService.new(
          dns_records: dns_records,
          included: dns_params[:included]
        ).call
      end

      def call_create_dns_service
        CreateDnsRecordService.new(ip: dns_params[:dns_records][:ip]).call
      end

      def call_create_or_update_hostnames_service(dns_record)
        CreateOrUpdateHostnamesService.new(
          dns_record: dns_record,
          hostnames_attributes: dns_params[:dns_records][:hostnames_attributes]
        ).call
      end

      def dns_params
        params.permit(
          :page,
          :included,
          :excluded,
          dns_records: [:ip, hostnames_attributes: [:hostname]]
        )
      end
    end
  end
end
