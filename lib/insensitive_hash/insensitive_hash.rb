class InsensitiveHash < Hash
  def initialize hash = {}
    @key_map = {}

    hash.each do |key, value|
      self[key] = value
    end
  end

  def [] key
    super(@key_map[encode key])
  end

  def []= key, value
    delete key
    @key_map[encode key] = key

    super(key, InsensitiveHash.wrap(value))
  end

  def has_key? key
    super @key_map[encode key]
  end

  def delete key
    super @key_map[encode key]
  end

private
  def self.wrap value
    case value
    when Hash
      value.class == InsensitiveHash ? value : InsensitiveHash.new(value)
    when Array
      value.map { |v| InsensitiveHash.wrap v }
    else
      value
    end
  end

  def encode key
    case key
    when String
      key.downcase
    when Symbol
      key.to_s.downcase
    else
      key
    end
  end
end

