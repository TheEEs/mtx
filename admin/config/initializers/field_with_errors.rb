# config/initializers/field_with_errors.rb
ActionView::Base.field_error_proc = proc do |html_tag, instance|
  html_tag.html_safe
end
