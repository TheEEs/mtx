// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import LocalTime from "local-time"
import { themeChange } from 'theme-change'

LocalTime.start()
document.addEventListener("turbo:morph", () => {
  LocalTime.run()
})

document.addEventListener("turbo:render", () => {
  themeChange(false)
})

document.addEventListener("turbo:load", () => {
  themeChange(false)
})