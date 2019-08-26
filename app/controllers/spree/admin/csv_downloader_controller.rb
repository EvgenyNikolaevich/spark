module Spree
  module Admin
    class CsvDownloaderController < Spree::Admin::ResourceController
      def index
        @product = CsvDownloader.read_csv
      end
    end
  end
end
