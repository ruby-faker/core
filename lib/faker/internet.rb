# frozen_string_literal: true

module Faker
  class Internet < Base
    class << self
      def email(name = nil, *separators)
        if separators
          [username(name, separators), domain_name].join("@")
        else
          [username(name), domain_name].join("@")
        end
      end

      def free_email(name = nil)
        [username(name), fetch("internet.free_email")].join("@")
      end

      def safe_email(name = nil)
        [username(name), "example." + sample(%w[org com net])].join("@")
      end

      def username(specifier = nil, separators = %w[. _])
        with_locale(:en) do
          return shuffle(specifier.scan(/[[:word:]]+/)).join(sample(separators)).downcase if specifier.respond_to?(:scan)

          if specifier.is_a?(Integer)
            # If specifier is Integer and has large value, Argument error exception is raised to overcome memory full error
            raise ArgumentError, "Given argument is too large" if specifier > 10**6

            tries = 0 # Don't try forever in case we get something like 1_000_000.
            result = nil
            loop do
              result = username(nil, separators)
              tries += 1
              break unless result.length < specifier && tries < 7
            end
            return result * (specifier / result.length + 1) if specifier.positive?
          elsif specifier.is_a?(Range)
            tries = 0
            result = nil
            loop do
              result = username(specifier.min, separators)
              tries += 1
              break unless !specifier.include?(result.length) && tries < 7
            end
            return result[0...specifier.max]
          end

          sample([
            prepare(Name.first_name),
            [Name.first_name, Name.last_name].map { |name| prepare(name) }.join(sample(separators)),
          ])
        end
      end

      def password(min_length = 8, max_length = 16, mix_case = true, special_chars = false)
        temp = Lorem.characters(count: min_length)
        diff_length = max_length - min_length
        if diff_length.positive?
          diff_rand = rand(diff_length + 1)
          temp += Lorem.characters(count: diff_rand)
        end

        if mix_case
          temp.chars.each_with_index do |char, index|
            temp[index] = char.upcase if index.even?
          end
        end

        if special_chars
          chars = %w[! @ # $ % ^ & *]
          rand(1..min_length).times do |i|
            temp[i] = chars[rand(chars.length)]
          end
        end

        temp
      end

      def domain_name(subdomain = false)
        with_locale(:en) do
          domain_elements = [prepare(domain_word), domain_suffix]
          domain_elements.unshift(prepare(domain_word)) if subdomain
          domain_elements.join(".")
        end
      end

      def domain_word
        with_locale(:en) { prepare(Company.name.split(" ").first) }
      end

      def domain_suffix
        fetch("internet.domain_suffix")
      end

      def mac_address(prefix = "")
        prefix_digits = prefix.split(":").map { |d| d.to_i(16) }
        address_digits = Array.new((6 - prefix_digits.size)) { rand(256) }
        (prefix_digits + address_digits).map { |d| format("%02x", d) }.join(":")
      end

      def ip_v4_address
        [rand_in_range(0, 255), rand_in_range(0, 255),
         rand_in_range(0, 255), rand_in_range(0, 255),].join(".")
      end

      def private_ip_v4_address
        addr = nil
        loop do
          addr = ip_v4_address
          break if private_net_checker[addr]
        end
        addr
      end

      def public_ip_v4_address
        addr = nil
        loop do
          addr = ip_v4_address
          break unless reserved_net_checker[addr]
        end
        addr
      end

      def private_nets_regex
        [
          /^10\./,                                       # 10.0.0.0    - 10.255.255.255
          /^100\.(6[4-9]|[7-9]\d|1[0-1]\d|12[0-7])\./,   # 100.64.0.0  - 100.127.255.255
          /^127\./,                                      # 127.0.0.0   - 127.255.255.255
          /^169\.254\./,                                 # 169.254.0.0 - 169.254.255.255
          /^172\.(1[6-9]|2\d|3[0-1])\./,                 # 172.16.0.0  - 172.31.255.255
          /^192\.0\.0\./,                                # 192.0.0.0   - 192.0.0.255
          /^192\.168\./,                                 # 192.168.0.0 - 192.168.255.255
          /^198\.(1[8-9])\./, # 198.18.0.0  - 198.19.255.255
        ]
      end

      def private_net_checker
        ->(addr) { private_nets_regex.any? { |net| net =~ addr } }
      end

      def reserved_nets_regex
        [
          /^0\./,                 # 0.0.0.0      - 0.255.255.255
          /^192\.0\.2\./,         # 192.0.2.0    - 192.0.2.255
          /^192\.88\.99\./,       # 192.88.99.0  - 192.88.99.255
          /^198\.51\.100\./,      # 198.51.100.0 - 198.51.100.255
          /^203\.0\.113\./,       # 203.0.113.0  - 203.0.113.255
          /^(22[4-9]|23\d)\./,    # 224.0.0.0    - 239.255.255.255
          /^(24\d|25[0-5])\./, # 240.0.0.0    - 255.255.255.254  and  255.255.255.255
        ]
      end

      def reserved_net_checker
        ->(addr) { (private_nets_regex + reserved_nets_regex).any? { |net| net =~ addr } }
      end

      def ip_v4_cidr
        "#{ip_v4_address}/#{rand(1..31)}"
      end

      def ip_v6_address
        (1..8).map { rand(65_536).to_s(16) }.join(":")
      end

      def ip_v6_cidr
        "#{ip_v6_address}/#{rand(1..127)}"
      end

      def url(host = domain_name, path = "/#{username}", scheme = "http")
        "#{scheme}://#{host}#{path}"
      end

      def slug(words = nil, glue = nil)
        glue ||= sample(%w[- _])
        (words || Faker::Lorem.words(count: 2).join(" ")).delete(",.").gsub(" ", glue).downcase
      end

      def device_token
        shuffle(rand(16**64).to_s(16).rjust(64, "0").chars.to_a).join
      end

      def user_agent(vendor = nil)
        agent_hash = translate("faker.internet.user_agent")
        agents = vendor.respond_to?(:to_sym) && agent_hash[vendor.to_sym] || agent_hash[sample(agent_hash.keys)]
        sample(agents)
      end

      alias user_name username

      def fix_umlauts(string)
        string.gsub(/[äöüß]/i) do |match|
          case match.downcase
          when "ä" then "ae"
          when "ö" then "oe"
          when "ü" then "ue"
          when "ß" then "ss"
          end
        end
      end

      private

      def prepare(string)
        fix_umlauts(romanize_cyrillic(string)).gsub(/\W/, "").downcase
      end

      def romanize_cyrillic(string)
        if CYRILLIC_SUBS[Faker::Config.locale] && CYRILLIC_CHARS[Faker::Config.locale]
          return string.gsub(CYRILLIC_SUBS[Faker::Config.locale], CYRILLIC_CHARS[Faker::Config.locale])
        end

        string
      end
    end

    CYRILLIC_CHARS = {
      "uk" => { # Based on conventions abopted by BGN/PCGN for Ukrainian
        "а" => "a",  "б" => "b",  "в" => "v",  "г" => "h",  "ґ" => "g",  "д" => "d",
        "е" => "e",  "є" => "ye", "ж" => "zh", "з" => "z",  "и" => "y",  "і" => "i",
        "ї" => "yi", "й" => "y",  "к" => "k",  "л" => "l",  "м" => "m",  "н" => "n",
        "о" => "o",  "п" => "p",  "р" => "r",  "с" => "s",  "т" => "t",  "у" => "u",
        "ф" => "f",  "х" => "kh", "ц" => "ts", "ч" => "ch", "ш" => "sh", "щ" => "shch",
        "ю" => "yu", "я" => "ya",
        "А" => "a",  "Б" => "b",  "В" => "v",  "Г" => "h",  "Ґ" => "g",  "Д" => "d",
        "Е" => "e",  "Є" => "ye", "Ж" => "zh", "З" => "z",  "И" => "y",  "І" => "i",
        "Ї" => "yi", "Й" => "y",  "К" => "k",  "Л" => "l",  "М" => "m",  "Н" => "n",
        "О" => "o",  "П" => "p",  "Р" => "r",  "С" => "s",  "Т" => "t",  "У" => "u",
        "Ф" => "f",  "Х" => "kh", "Ц" => "ts", "Ч" => "ch", "Ш" => "sh", "Щ" => "shch",
        "Ю" => "yu", "Я" => "ya",
        "ь" => "", # Ignore symbol, because its standard presentation is not allowed in URLs
      },
      "ru" => { # Based on conventions abopted by BGN/PCGN for Russian
        "а" => "a",  "б" => "b",  "в" => "v",  "г" => "h",  "ґ" => "g",  "д" => "d",
        "е" => "e",  "є" => "ye", "ж" => "zh", "з" => "z",  "и" => "y",  "і" => "i",
        "ї" => "yi", "й" => "y",  "к" => "k",  "л" => "l",  "м" => "m",  "н" => "n",
        "о" => "o",  "п" => "p",  "р" => "r",  "с" => "s",  "т" => "t",  "у" => "u",
        "ф" => "f",  "х" => "kh", "ц" => "ts", "ч" => "ch", "ш" => "sh", "щ" => "shch",
        "ю" => "yu", "я" => "ya",
        "А" => "a",  "Б" => "b",  "В" => "v",  "Г" => "h",  "Ґ" => "g",  "Д" => "d",
        "Е" => "e",  "Є" => "ye", "Ж" => "zh", "З" => "z",  "И" => "y",  "І" => "i",
        "Ї" => "yi", "Й" => "y",  "К" => "k",  "Л" => "l",  "М" => "m",  "Н" => "n",
        "О" => "o",  "П" => "p",  "Р" => "r",  "С" => "s",  "Т" => "t",  "У" => "u",
        "Ф" => "f",  "Х" => "kh", "Ц" => "ts", "Ч" => "ch", "Ш" => "sh", "Щ" => "shch",
        "Ю" => "yu", "Я" => "ya",
        "ь" => "", # Ignore symbol, because its standard presentation is not allowed in URLs
      },
    }

    CYRILLIC_SUBS = {
      "uk" => /[а-яА-ЯіїєґІЇЄҐ]/,
      "ru" => /[а-яА-Я]/,
    }
  end
end
