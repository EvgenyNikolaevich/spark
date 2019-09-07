module Spree
  module Admin
    class CsvUploaderController < Spree::Admin::ResourceController
      def upload
        Spree::CsvUploader.read_csv('sample.csv')
      end

      private

      def form_params
        params.permit(:file)
      end
    end
  end
end
