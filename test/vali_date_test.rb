require 'test_helper'
require 'active_support/core_ext/integer/time'
require 'active_model'

class ValiDateTest < Minitest::Test
  class Person
    include ActiveModel::Model
    include ValiDate

    ATTRS = [:birth, :first_drive, :death, :funeral]
    attr_accessor *ATTRS

    def attributes
      Hash[ATTRS.map { |attr| [attr, send(attr)] }]
    end

    vali_date :birth, before: :death
    vali_date :first_drive, at_least: 16.years, after: :birth
    vali_date :funeral, after: :death, strict: true
  end

  def setup
    @person = Person.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::ValiDate::VERSION
  end

  def test_it_does_something_useful
    ruleset = Person.send(:vali_dator)
    # require 'pry'; binding.pry
  end
end
