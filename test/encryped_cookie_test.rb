require File.expand_path( File.join( File.dirname( __FILE__ ), 'test_helper' ) )

# so that we can get access to the encrypted values and mess with them for testing
module EncryptedCookies
  class EncryptedCookieJar
    def encrypted_value(name)
      @parent_jar[name]
    end

    def set_encrypted_value(name, value)
      @parent_jar[name] = value
    end

  end
end

class TestEncryptedCookies < Test::Unit::TestCase

  GOOD_SECRET_1 = "200b85f78a0ac1add6494111d899107df8c25f72b13ec7480f906f4cb8bef32cc1e7b4c0d31f57493ff062cdd9bf37d41636fdfb453af7c7c73f598b257d3c89"
  GOOD_SECRET_2 = "8127a90b3352b34459a1649da6f3a01358632c06a7ded98e4633fcfc8d32a7508d8e87a1db1b826330f090f4518098860dd20c10604df9b1b577e1b39268deb6"
  BAD_SECRET    = "iamtooshort"

  def setup
    @cookie_jar             = ActionDispatch::Cookies::CookieJar.new
    @encrypted_cookie_jar   = EncryptedCookies::EncryptedCookieJar.new(@cookie_jar, GOOD_SECRET_1)
    @str                    = "test string"
  end

  def test_secret
    assert_raise (ArgumentError) { EncryptedCookies::EncryptedCookieJar.new(@cookie_jar, nil) }
    assert_raise (ArgumentError) { EncryptedCookies::EncryptedCookieJar.new(@cookie_jar, "") }
    assert_raise (ArgumentError) { EncryptedCookies::EncryptedCookieJar.new(@cookie_jar, BAD_SECRET) }
    assert_nothing_raised { EncryptedCookies::EncryptedCookieJar.new(@cookie_jar, GOOD_SECRET_1) }
  end

  def test_basic_encryption_decryption
    @encrypted_cookie_jar[:test] = @str

    assert @encrypted_cookie_jar.encrypted_value(:test) != @str
    assert @encrypted_cookie_jar[:test] == @str
  end

  def test_tampered_signature
    @encrypted_cookie_jar[:test] = @str
    enc_value = @encrypted_cookie_jar.encrypted_value(:test)

    data, digest = enc_value.split("--")
    @encrypted_cookie_jar.set_encrypted_value(:test, "#{data}--sdgsad")

    assert @encrypted_cookie_jar[:test].nil?
  end

  # a different encrypted cookie jar with a different secret can't read another's values
  def test_another_cookie_jar
    @encrypted_cookie_jar[:test] = @str
    enc_value = @encrypted_cookie_jar.encrypted_value(:test)

    encrypted_cookie_jar_2 = EncryptedCookies::EncryptedCookieJar.new(@cookie_jar, GOOD_SECRET_2)
    encrypted_cookie_jar_2.set_encrypted_value(:test, enc_value)

    assert encrypted_cookie_jar_2[:test].nil?
  end

  # a different encrypted jar with the same secret can decode the value
  def test_same_cookie_jar
    @encrypted_cookie_jar[:test] = @str
    enc_value = @encrypted_cookie_jar.encrypted_value(:test)

    encrypted_cookie_jar_2 = EncryptedCookies::EncryptedCookieJar.new(@cookie_jar, GOOD_SECRET_1)
    encrypted_cookie_jar_2.set_encrypted_value(:test, enc_value)

    assert encrypted_cookie_jar_2[:test] == @str
  end

end