class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  def self.encode(payload, exp = 1.hour.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::ExpiredSignature, JWT::DecodeError
    nil
  end
end