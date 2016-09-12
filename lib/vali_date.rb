require 'active_support/core_ext/hash/keys'
require 'vali_date/rule_set'
require 'vali_date/rule_graph'
require 'vali_date/version'

module ValiDate
  def self.included(base)
    base.extend ClassMethods

    if base.respond_to?(:validate)
      base.validate :vali_date!
    end
  end

  module ClassMethods
    # vali_date(:birth, before: :death, strict: true, only_calendar: true)
    # vali_date(:birth, at_least: 18.years, before: :drink)
    def vali_date(source, options = {})
      options.symbolize_keys!

      Array(options.delete :before).each do |dest|
        vali_dator.add_rule(source, dest, options)
      end

      Array(options.delete :after).each do |dest|
        vali_dator.add_rule(dest, source, options)
      end
    end

    def vali_dator
      @vali_dator ||= ValiDate::RuleGraph.new
    end
  end

  def vali_date!
    graph = self.class.vali_dator.clone
    graph.populate(attributes).condense!
    # require 'pry'; binding.pry
    # TODO: enumerate over ages, test each, add errors
  end
end
