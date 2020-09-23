# frozen_string_literal: true

# Insensitive Hash.
# @author Junegunn Choi <junegunn.c@gmail.com>
class InsensitiveHash < Hash
  # Thrown when safe mode is on and another Hash with conflicting keys cannot be merged safely
  class KeyClashError < RuntimeError; end

  def initialize(default = nil, &block)
    if block_given?
      raise ArgumentError, 'wrong number of arguments' unless default.nil?

      super(&block)
    else
      super
    end

    @key_map = {}
    @safe    = false
  end

  # Sets whether to detect key clashes
  # @param [Boolean]
  # @return [Boolean]
  def safe=(safe_val)
    raise ArgumentError, 'Neither true nor false' unless [true, false].include?(safe_val)

    @safe = safe_val
  end

  # @return [Boolean] Key-clash detection enabled?
  def safe?
    @safe
  end

  # Returns a normal, sensitive Hash
  # @return [Hash]
  def to_hash
    {}.merge self
  end
  alias sensitive to_hash

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def self.[](*init)
    h = Hash[*init]
    new.tap do |ih|
      ih.merge_recursive! h
    end
  end

  %w[[] assoc has_key? include? key? member?].each do |symb|
    class_eval <<-EVAL, __FILE__, __LINE__ + 1
      def #{symb}(key)
        super lookup_key(key)
      end
    EVAL
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def []=(key, value)
    delete key
    ekey = encode key
    @key_map[ekey] = key
    super key, value
  end
  alias store []=

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def merge!(other_hash)
    detect_clash other_hash
    other_hash.each do |key, value|
      store key, value
    end
    self
  end
  alias update! merge!

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def merge(other_hash)
    self.class.new.tap do |ih|
      ih.replace self
      ih.merge! other_hash
    end
  end
  alias update merge

  # Merge another hash recursively.
  # @param [Hash|InsensitiveHash] other_hash
  # @return [self]
  def merge_recursive!(other_hash)
    detect_clash other_hash
    other_hash.each do |key, value|
      deep_set key, value
    end
    self
  end
  alias update_recursive! merge_recursive!

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def delete(key, &block)
    super lookup_key(key, true), &block
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def clear
    @key_map.clear
    super
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def replace(other)
    super other

    self.safe = other.respond_to?(:safe?) ? other.safe? : safe?

    @key_map.clear
    each do |k, _v|
      ekey = encode k
      @key_map[ekey] = k
    end
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def shift
    super.tap do |ret|
      @key_map.delete_if { |_k, v| v == ret.first }
    end
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def values_at(*keys)
    keys.map { |k| self[k] }
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def fetch(*args, &block)
    args[0] = lookup_key(args[0]) if args.first
    super(*args, &block)
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def dup
    super.tap { |copy| copy.instance_variable_set :@key_map, @key_map.dup }
  end

  # @see http://www.ruby-doc.org/core-1.9.3/Hash.html Hash
  def clone
    super.tap { |copy| copy.instance_variable_set :@key_map, @key_map.dup }
  end

  private

  def deep_set(key, value)
    wv = wrap value
    self[key] = wv
  end

  def wrap(value)
    case value
    when InsensitiveHash
      value.tap { |ih| ih.safe = safe? }
    when Hash
      self.class.new.tap do |ih|
        ih.safe = safe?
        ih.merge_recursive!(value)
      end
    when Array
      value.map { |v| wrap v }
    else
      value
    end
  end

  def lookup_key(key, delete = false)
    @key_map = {} if @key_map.nil?
    ekey = encode key
    if @key_map.key?(ekey)
      delete ? @key_map.delete(ekey) : @key_map[ekey]
    else
      key
    end
  end

  def encode(key)
    case key
    when String, Symbol
      key.to_s.downcase.gsub(' ', '_')
    else
      key
    end
  end

  def detect_clash(hash)
    return unless @safe

    hash.keys.map { |k| encode k }.tap do |ekeys|
      raise KeyClashError, 'Key clash detected' if ekeys != ekeys.uniq
    end
  end
end
