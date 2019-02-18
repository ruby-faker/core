# frozen_string_literal: true

module Faker
  # Based on Perl's Text::Lorem
  class Lorem < Base
    class << self
      def word
        sample(translate("faker.lorem.words"))
      end

      def words(count: 3, supplemental: false)
        resolved_num = resolve(count)
        word_list = (
          translate("faker.lorem.words") +
          (supplemental ? translate("faker.lorem.supplemental") : [])
        )
        word_list *= ((resolved_num / word_list.length) + 1)
        shuffle(word_list)[0, resolved_num]
      end

      def character
        sample(Types::CHARACTERS)
      end

      def characters(count: 255)
        Alphanumeric.alphanumeric(count)
      end

      def multibyte
        sample(translate("faker.lorem.multibyte")).pack("C*").force_encoding("utf-8")
      end

      def sentence(count: 4, supplemental: false, random_words_to_add: 0)
        words(count: count + rand(random_words_to_add.to_i), supplemental: supplemental).join(" ").capitalize + locale_period
      end

      def sentences(count: 3, supplemental: false)
        1.upto(resolve(count)).collect { sentence(count: 3, supplemental: supplemental) }
      end

      def paragraph(count: 3, supplemental: false, random_sentences_to_add: 0)
        sentences(count: resolve(count) + rand(random_sentences_to_add.to_i), supplemental: supplemental).join(locale_space)
      end

      def paragraphs(count: 3, supplemental: false)
        1.upto(resolve(count)).collect { paragraph(count: 3, supplemental: supplemental) }
      end

      def paragraph_by_chars(count: 256, supplemental: false)
        paragraph = paragraph(count: 3, supplemental: supplemental)

        paragraph += " " + paragraph(count: 3, supplemental: supplemental) while paragraph.length < count

        paragraph[0...count - 1] + "."
      end

      def question(count: 4, supplemental: false, random_words_to_add: 0)
        words(count: count + rand(random_words_to_add), supplemental: supplemental).join(" ").capitalize + locale_question_mark
      end

      def questions(count: 3, supplemental: false)
        1.upto(resolve(count)).collect { question(count: 3, supplemental: supplemental) }
      end

      private

      def locale_period
        translate("faker.lorem.punctuation.period") || "."
      end

      def locale_space
        translate("faker.lorem.punctuation.space") || " "
      end

      def locale_question_mark
        translate("faker.lorem.punctuation.question_mark") || "?"
      end
    end
  end
end
