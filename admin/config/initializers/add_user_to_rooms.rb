Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.table_exists?(:rooms)
    unless ActiveRecord::Base.connection.column_exists?(:rooms, :user_id)
      ActiveRecord::Base.connection.add_reference(:rooms, :user, foreign_key: true)
    end
    unless ActiveRecord::Base.connection.column_exists?(:rooms, :is_public)
      ActiveRecord::Base.connection.add_column(:rooms, :is_public, :boolean, default: true, null: false)
    end
    unless ActiveRecord::Base.connection.column_exists?(:rooms, :password_digest)
      ActiveRecord::Base.connection.add_column(:rooms, :password_digest, :string)
    end
  end
rescue => e
  Rails.logger.warn "Could not ensure room schema: #{e.message}"
end
