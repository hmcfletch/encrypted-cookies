require 'securerandom'

module EncryptedCookies
  class EncryptedCookieJar < ActionDispatch::Cookies::CookieJar #:nodoc:
    MAX_COOKIE_SIZE = 4096 # Cookies can typically store 4096 bytes.
    SECRET_MIN_LENGTH = 30 # Characters

    def initialize(parent_jar, secret)
      ensure_secret_secure(secret)
      @parent_jar = parent_jar
      @encrypter  = ActiveSupport::MessageEncryptor.new(secret)
    end

    def [](name)
      if encrypted_message = @parent_jar[name]
        @encrypter.decrypt_and_verify(encrypted_message)
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      nil
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      nil
    end

    def []=(key, options)
      if options.is_a?(Hash)
        options.symbolize_keys!
        options[:value] = @encrypter.encrypt_and_sign(options[:value])
      else
        options = { :value => @encrypter.encrypt_and_sign(options) }
      end

      raise ActionDispatch::Cookies::CookieOverflow if options[:value].size > MAX_COOKIE_SIZE
      @parent_jar[key] = options
    end

    def method_missing(method, *arguments, &block)
      @parent_jar.send(method, *arguments, &block)
    end

    protected

    # To prevent users from using something insecure like "Password" we make sure that the
    # secret they've provided is at least 30 characters in length.
    def ensure_secret_secure(secret)
      if secret.blank?
        raise ArgumentError, "A secret is required to generate an " +
          "integrity hash for cookie session data. Use " +
          "config.secret_token = \"some secret phrase of at " +
          "least #{SECRET_MIN_LENGTH} characters\"" +
          "in config/initializers/secret_token.rb"
      end

      if secret.length < SECRET_MIN_LENGTH
        raise ArgumentError, "Secret should be something secure, " +
          "like \"#{SecureRandom.hex(16)}\".  The value you " +
          "provided, \"#{secret}\", is shorter than the minimum length " +
          "of #{SECRET_MIN_LENGTH} characters"
      end
    end
  end
end

ActionDispatch::Cookies.send(:include, EncryptedCookies)
