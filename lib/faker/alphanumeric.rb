# frozen_string_literal: true

module Faker
  class Alphanumeric < Base
    class << self
      ALPHABET = ("a".."z").to_a
      ALPHANUMS = ALPHABET + (0..9).to_a

      def alpha(count = 32)
        char_count = resolve(count)
        return "" if char_count.to_i < 1

        Array.new(char_count) { sample(ALPHABET) }.join
      end

      def alphanumeric(count = 32)
        char_count = resolve(count)
        return "" if char_count.to_i < 1

        Array.new(char_count) { sample(ALPHANUMS) }.join
      end
    end
  end
end
