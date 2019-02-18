# frozen_string_literal: true

begin
  require "psych"
end

require "i18n"

I18n.load_path += Dir[File.join(__dir__, "locales", "**/*.yml")]
I18n.reload! if I18n.backend.initialized?

require "faker/init/config"
require "faker/init/base"
require "faker/init/unique_generator"

Dir.glob(File.join(__dir__, "faker", "/**/*.rb")).sort.grep_v(%r{faker/init/}).each {|file| require file }
