# model for downloading csv file and add values to DB
# README before read this class
require 'csv'

module Spree
  class CsvDownloader < Spree::Base

    # TODO: delete and add initialize
    class << self
      def read_csv
        csv_string = prepare_csv
        struct(csv_string)
      end

      private

      # read data from csv-file, delete nil
      def prepare_csv(path_to_file = 'sample.csv')
        csv_array = CSV.read(
          path_to_file,
          {
            headers: true,
            header_converters: :symbol,
            converters: :all,
            col_sep: ';'
          }
        )

        # remove arrays where all values are nil
        csv_array.reject { |array| array.to_hash.values.all?(&:nil?) }
      end

      # TODO: make logs more beauty
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
            Rails.logger.info "+" * 10
            Rails.logger.info "Exception when creating a new product:"
            Rails.logger.info exception
            Rails.logger.info "+" * 10
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
    end
  end
end
