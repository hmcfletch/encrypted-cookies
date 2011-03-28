module EncryptedCookies
  module CookieJar
    # Returns a jar that'll automatically set the assigned cookies to the top level domain, regardless of if there 
    # is a subdomain present or not. Example:
    # 
    #     cookies.encypted[:encrypted_cookie] = "you don't know what this says"
    #     # => Set-Cookie: LSuus8pkXd...ckqiG6qGlwuhSQn--4Eb16w1z7ouNXQZAxV5Bjw==; path=/; expires=Sun, 27-Mar-2011 03:24:16 GMT
    # 
    # This jar allows chaining with other jars as well, so you can set tld, signed cookies. Examples:
    # 
    #     cookies.permanent.encypted[:encrypted_permanent] = "you don't know what this says, but it will be here for 20 years"
    #     # => Set-Cookie: Sok2G6hGs...XFeUpDWQLT8=--UZe+JlZPlMuxHYSq09oV0w==; path=/; expires=Thu, 27 Mar 2031 13:48:43 GMT
    # 
    # To read encypted cookies:
    # 
    #     cookies.encrypted[:encrypted_cookie] # => "you don't know what this says"
    #     cookies.encrypted[:encrypted_permanent] # => "you don't know what this says, but it will be here for 20 years"
    def encrypted
      @encrypted ||= EncryptedCookieJar.new(self, @secret)
    end
  end
end

ActionDispatch::Cookies::CookieJar.send(:include, EncryptedCookies::CookieJar)