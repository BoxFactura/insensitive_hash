# frozen_string_literal: true

require 'insensitive_hash/version'
require 'insensitive_hash/insensitive_hash'

# :nodoc:
class Hash
  # @param [Hash] options Options
  # @option options [Boolean] :safe Whether to detect key clash on merge
  # @return [InsensitiveHash]
  def insensitive options = {}
    InsensitiveHash.new.tap do |ih|
      ih.safe         = options[:safe] if options.key?(:safe)
      ih.default      = default
      ih.default_proc = default_proc if default_proc

      ih.merge_recursive!(self)
    end
  end
end
