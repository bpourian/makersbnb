require 'date'

class Space < Sequel::Model
  plugin :validation_helpers
  many_to_one :user
  self.raise_on_save_failure = false

  def validate
    super
    validates_presence [:space_name, :space_description, :space_price, :availability_start, :availability_end, :user_id]
    validates_max_length 50, :space_name
    validates_format(/\A\d+(?:\.\d{1,2})?\z/, :space_price)
    begin
      start_date = Date.iso8601(availability_start.to_s)
      end_date = Date.iso8601(availability_end.to_s)
      errors.add(:availability_end, 'must not precede the start date') if end_date < start_date
    rescue Date::Error
      errors.add(:availability_start, 'and end must use YYYY-MM-DD dates')
    end
  end

  def self.get(id)
    self[id] if id.is_a?(Integer)
  end
end
