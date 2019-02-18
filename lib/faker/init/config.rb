module Faker
  class Config
    @locale = nil
    @random = nil

    class << self
      attr_writer :locale
      attr_writer :random

      def locale
        @locale || I18n.locale
      end

      def own_locale
        @locale
      end

      def random
        @random || Random::DEFAULT
      end
    end
  end
end
