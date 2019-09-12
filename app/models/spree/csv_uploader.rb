require 'csv'

module Spree
  # model for uploading csv file and add values to DB
  class CsvUploader < Spree::Base
    class << self
      def read_csv(file_path)
        csv_string = prepare_csv(file_path)
        struct(csv_string)
      end

      private

      def prepare_csv(file_path)
        csv_array = CSV.read(
          file_path,
          headers: true,
          header_converters: :symbol,
          converters: :all,
          col_sep: ';'
        )
        csv_array.reject { |array| array.to_hash.values.all?(&:nil?) }
      end

      # TODO: need reorganization
      def struct(csv_string)
        product_list = {}
        csv_string.map do |value|
          product = {
            name: value[:name],
            description: value[:description],
            price: set_price(value[:price]),
            available_on: value[:availability_date],
            slug: value[:slug],
            #stock_total: value[:stock_total],
            shipping_category_id: shipping_category_id_by_name(value[:category])
          }
          product_list[value[:name]] = save_product(product)
        end
        product_list
      end

      def save_product(product)
        Spree::Product.create!(product)
        'The product was successfully created.'
      rescue ActiveRecord::RecordInvalid => exception
        logger('Exception when creating a new product:', exception)
        "The product was not created, because of #{exception}"
      end

      def shipping_category_id_by_name(name)
        name = 'Default' if name.blank?
        Spree::ShippingCategory.find_or_create_by(name: name).id
      end

      def set_price(amount, currency = 'USD', variant_id = 1)
        # variant_id is some business thing, what should it be?..
        Spree::Price.create(amount: amount,
                            currency: currency,
                            variant_id: variant_id)
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
