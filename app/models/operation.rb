class Operation < ActiveRecord::Base
  attr_reader :name, :display_name

  def self.all
    [:avg, :sum, :min, :max].map { |c| new(c) }
  end

  def initialize(name)
    @name = name
    @display_name = name.capitalize
  end

  def to_param
    @name
  end
end
