module Spree
  module Admin
    class CsvUploaderController < Spree::Admin::ResourceController
      def upload
        if form_params[:file].present?
          Spree::CsvUploader.read_csv(form_params[:file])
          render 'show'
        else
          redirect_to action: 'index'
        end
      end

      private

      def form_params
        params.permit(:file)
      end
    end
  end
end
