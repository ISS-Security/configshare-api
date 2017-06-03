# frozen_string_literal: true

require 'rbnacl/libsodium'

# Parses Json information as needed
class SignedRequest
  def initialize(config)
    @verify_key = config.VERIFY_KEY
  end

  def parse(json_str)
    parsed = JSON.parse(json_str)

    raise 'Data not properly signed' unless
      verify(parsed['signature'], parsed['data'])

    symbolized_hash_keys(parsed['data'])
  end

  private

  def verify(signature64, message)
    verify_key_str = Base64.strict_decode64(@verify_key)
    signature = Base64.strict_decode64(signature64)
    verifier = RbNaCl::VerifyKey.new(verify_key_str)
    verifier.verify(signature, message.to_json)
  rescue
    false
  end

  def symbolized_hash_keys(data)
    Hash[data.map { |k, v| [k.to_sym, v] }]
  end
end
