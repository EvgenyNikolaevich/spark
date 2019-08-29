# model for uploading csv file and add values to DB
# README before read this class
require 'csv'

module Spree
  class CsvUploader < Spree::Base
    class << self
      def read_csv(file_path = 'sample.csv')
        csv_string = prepare_csv(file_path)
        struct(csv_string)
      end

      private

      def prepare_csv(file_path)
        csv_array = CSV.read(
          file_path,
          {
            headers: true,
            header_converters: :symbol,
            converters: :all,
            col_sep: ';'
          }
        )

        csv_array.reject { |array| array.to_hash.values.all?(&:nil?) }
      end

      # TODO: move to another place?
      def struct(csv_string)
        csv_string.map do |value|
          begin
            Spree::Product.create!(name: value[1],
                                   description: value[2],
                                   price: set_price(value[3]),
                                   available_on: value[4],
                                   slug: value[5],
                                   #stock_total: value[6],
                                   shipping_category_id: shipping_category_id_by_name(value[7])
                                  )
          rescue ActiveRecord::RecordInvalid => exception
            logger('Exception when creating a new product:', exception)
          end
        end
      end

      # TODO: move to another place
      def shipping_category_id_by_name(name)
        name = 'Default' if name.blank?
        Spree::ShippingCategory.find_or_create_by(name: name).id
      end

      # TODO: move to another place
      def set_price(amount, currency = 'USD', variant_id = 1)
        # variant_id is some business thing, what should it be?..
        Spree::Price.create(amount: amount, currency: currency, variant_id: variant_id)
      end

      def logger(message, exception)
        Rails.logger.info "+" * 10
        Rails.logger.info message
        Rails.logger.info exception
        Rails.logger.info "+" * 10
      end
    end
  end
end
