module Spree
  module Admin
    class CsvUploaderController < Spree::Admin::ResourceController
      def upload
        process_info = Spree::CsvUploader.read_csv(form_params[:file])
      end

      private

      def form_params
        params.permit(:file)
      end
    end
  end
end
