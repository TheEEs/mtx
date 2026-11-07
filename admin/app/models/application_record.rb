class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class


  def self.required?(field)
    validators_on(field).any? { |v| v.kind_of?(ActiveRecord::Validations::PresenceValidator) }
  end
end
