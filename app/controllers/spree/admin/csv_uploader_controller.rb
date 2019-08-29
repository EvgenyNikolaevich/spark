module Spree
  module Admin
    class CsvUploaderController < Spree::Admin::ResourceController
      def index
        @product = CsvUploader.read_csv
      end
    end
  end
end
