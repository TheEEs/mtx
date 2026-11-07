Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.table_exists?(:rooms) && !ActiveRecord::Base.connection.column_exists?(:rooms, :user_id)
    ActiveRecord::Base.connection.add_reference(:rooms, :user, foreign_key: true)
  end
rescue => e
  Rails.logger.warn "Could not check/add user_id to rooms: #{e.message}"
end
