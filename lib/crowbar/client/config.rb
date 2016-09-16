#
# Copyright 2015, SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "inifile"
require "hashie"
require "singleton"

module Crowbar
  module Client
    #
    # General configuration for the Crowbar CLI
    #
    class Config
      include Singleton

      attr_writer :options
      attr_writer :config
      attr_writer :values

      #
      # Define base configuration
      #
      # @param options [Hash] the base configuration
      #
      def configure(options)
        self.options = Hashie::Mash.new(
          options
        )

        self.config = parser
        self.values = merge
      end

      #
      # Define default config
      #
      # @return [Hashie::Mash] the default config
      #
      def defaults
        @defaults ||= Hashie::Mash.new(
          alias: default_alias,
          username: default_username,
          password: default_password,
          server: default_server,
          timeout: default_timeout,
          anonymous: default_anonymous,
          apiversion: default_apiversion,
          debug: default_debug
        )
      end

      #
      # Define parameter config
      #
      # @return [Hashie::Mash] the parameter config
      #
      def options
        @options ||= defaults
      end

      #
      # Define file config
      #
      # @return [Hashie::Mash] the file config
      #
      def config
        @config ||= Hashie::Mash.new
      end

      #
      # Define merged config
      #
      # @return [Hashie::Mash] the merged config
      #
      def values
        @values ||= Hashie::Mash.new
      end

      protected

      #
      # Define a default alias value
      #
      # @return [String] the default alias value
      #
      def default_alias
        ENV["CROWBAR_ALIAS"] || "default"
      end

      #
      # Define a default username value
      #
      # @return [String] the default username value
      #
      def default_username
        ENV["CROWBAR_USERNAME"] || "crowbar"
      end

      #
      # Define a default password value
      #
      # @return [String] the default password value
      #
      def default_password
        ENV["CROWBAR_PASSWORD"] || "crowbar"
      end

      #
      # Define a default server value
      #
      # @return [String] the default server value
      #
      def default_server
        ENV["CROWBAR_SERVER"] || "http://127.0.0.1:80"
      end

      #
      # Define a default timeout value
      #
      # @return [Integer] the default timeout value
      #
      def default_timeout
        if ENV["CROWBAR_TIMEOUT"].present?
          ENV["CROWBAR_TIMEOUT"].to_i
        else
          300
        end
      end

      #
      # Define a default anonymous flag
      #
      # @return [Bool] the default anonymous flag
      #
      def default_anonymous
        if ENV["CROWBAR_ANONYMOUS"].present?
          [
            true, 1, "1", "t", "T", "true", "TRUE"
          ].include? ENV["CROWBAR_ANONYMOUS"]
        else
          false
        end
      end

      #
      # Define a default api version
      #
      # @return [Float] the default crowbar api version
      #
      def default_apiversion
        if ENV["CROWBAR_APIVERSION"].present?
          ENV["CROWBAR_APIVERSION"].to_f
        else
          Crowbar::Client::Util::ApiVersion.default
        end
      end

      #
      # Define a default debug flag
      #
      # @return [String] the default alias flag
      #
      def default_debug
        if ENV["CROWBAR_DEBUG"].present?
          [
            true, 1, "1", "t", "T", "true", "TRUE"
          ].include? ENV["CROWBAR_DEBUG"]
        else
          false
        end
      end

      #
      # Merge the different configs together
      #
      # @return [Hashie::Mash] the merged config
      #
      def merge
        result = {}.tap do |overwrite|
          defaults.keys.each do |key|
            overwrite[key] = case
            when options[key] != defaults[key]
              options[key]
            when config[key].present?
              config[key]
            when options[key].present?
              options[key]
            else
              defaults[key]
            end
          end
        end

        Hashie::Mash.new(
          result
        )
      end

      #
      # Load and parse the config file
      #
      # @return [Hashie::Mash] the config content
      #
      def parser
        ini = Hashie::Mash.new(
          IniFile.load(
            finder
          ).to_h
        )

        if ini[options.alias]
          ini[options.alias]
        else
          Hashie::Mash.new
        end
      rescue
        Hashie::Mash.new
      end

      #
      # Find the first config file
      #
      # @return [String] the first config
      #
      def finder
        paths.detect do |temp|
          File.exist? temp
        end
      end

      #
      # Define the available config file paths
      #
      # @return [Array] the available paths
      #
      def paths
        [
          File.join(
            ENV["HOME"],
            ".crowbarrc"
          ),
          File.join(
            "/etc",
            "crowbarrc"
          )
        ]
      end

      class << self
        #
        # Define base configuration
        #
        # @see #configure
        # @param options [Hash] the base configuration
        #
        def configure(options)
          instance.configure(options)
        end

        #
        # Define default config
        #
        # @see #defaults
        # @return [Hashie::Mash] the default config
        #
        def defaults
          instance.defaults
        end

        #
        # Define parameter config
        #
        # @see #options
        # @return [Hashie::Mash] the parameter config
        #
        def options
          instance.options
        end

        #
        # Define file config
        #
        # @see #config
        # @return [Hashie::Mash] the file config
        #
        def config
          instance.config
        end

        #
        # Define merged config
        #
        # @see #values
        # @return [Hashie::Mash] the merged config
        #
        def values
          instance.values
        end

        #
        # Magic to catch missing method calls
        #
        # @param method [Symbol] the method that is missing
        # @param arguments [Array] the list of attributes
        # @yield
        #
        def method_missing(method, *arguments, &block)
          case
          when method.to_s.ends_with?("=")
            key = method.to_s.gsub(/=\z/, "")

            if values.key?(key)
              values[key] = arguments.first
            else
              super
            end
          when values.key?(method)
            values[method]
          else
            super
          end
        end

        #
        # Magic to catch missing respond_to calls
        #
        # @param method [Symbol] the method that is missing
        # @param include_private [Bool] should include private methods
        # @return [Bool] the class responds to it or not
        #
        def respond_to?(method, include_private = false)
          case
          when method.to_s.ends_with?("=")
            key = method.to_s.gsub(/=\z/, "")

            if values.key?(key)
              true
            else
              super
            end
          when values.key?(method)
            true
          else
            super
          end
        end
      end
    end
  end
end
