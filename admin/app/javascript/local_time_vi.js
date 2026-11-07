import LocalTime from "local-time"

export const vi = {
  date: {
    dayNames: [
      "Chủ nhật",
      "Thứ hai",
      "Thứ ba",
      "Thứ tư",
      "Thứ năm",
      "Thứ sáu",
      "Thứ bảy"
    ],
    abbrDayNames: [
      "CN",
      "Thứ 2",
      "Thứ 3",
      "Thứ 4",
      "Thứ 5",
      "Thứ 6",
      "Thứ 7"
    ],
    monthNames: [
      "Tháng 1",
      "Tháng 2",
      "Tháng 3",
      "Tháng 4",
      "Tháng 5",
      "Tháng 6",
      "Tháng 7",
      "Tháng 8",
      "Tháng 9",
      "Tháng 10",
      "Tháng 11",
      "Tháng 12"
    ],
    abbrMonthNames: [
      "Thg 1",
      "Thg 2",
      "Thg 3",
      "Thg 4",
      "Thg 5",
      "Thg 6",
      "Thg 7",
      "Thg 8",
      "Thg 9",
      "Thg 10",
      "Thg 11",
      "Thg 12"
    ],
    yesterday: "hôm qua",
    today: "hôm nay",
    tomorrow: "ngày mai",
    on: "vào {date}",
    formats: {
      default: "%d %b, %Y",
      thisYear: "%d %b"
    }
  },
  time: {
    am: "SA",
    pm: "CH",
    singular: "{time}",
    singularAn: "{time}",
    elapsed: "{time} trước",
    second: "vài giây",
    seconds: "giây",
    minute: "1 phút",
    minutes: "phút",
    hour: "1 giờ",
    hours: "giờ",
    formats: {
      default: "%H:%M",
      default_24h: "%H:%M"
    }
  },
  datetime: {
    at: "{date} lúc {time}",
    formats: {
      default: "%d %B, %Y lúc %H:%M",
      default_24h: "%d %B, %Y lúc %H:%M"
    }
  }
}

// Cấu hình từ điển Tiếng Việt cho LocalTime
LocalTime.config.i18n = LocalTime.config.i18n || {}
LocalTime.config.i18n.vi = vi
LocalTime.config.defaultLocale = "vi"
LocalTime.config.useFormat24 = true

// Hàm đồng bộ ngôn ngữ và ép LocalTime tính toán lại toàn bộ thẻ <time>
export function syncLocaleAndTime() {
  const metaLocale = document.querySelector('meta[name="locale"]')?.getAttribute('content') ||
                     document.documentElement.getAttribute('lang') ||
                     "vi"

  document.documentElement.lang = metaLocale
  LocalTime.config.locale = metaLocale

  // Xóa thuộc tính data-localized và title cũ để ép local-time dịch và render lại
  const timeElements = document.querySelectorAll("time[data-local]")
  if (timeElements.length > 0) {
    timeElements.forEach(el => {
      el.removeAttribute("data-localized")
      el.removeAttribute("title")
    })
    LocalTime.run()
  }
}

// Đồng bộ ngay lập tức khi file tải
syncLocaleAndTime()

// Đồng bộ khi Turbo chuẩn bị render nội dung mới
document.addEventListener("turbo:before-render", (event) => {
  const meta = event.detail?.newBody?.ownerDocument?.querySelector('meta[name="locale"]') ||
               document.querySelector('meta[name="locale"]')
  if (meta) {
    const loc = meta.getAttribute("content")
    document.documentElement.lang = loc
    LocalTime.config.locale = loc
  }
})

// Đồng bộ lại toàn bộ thẻ <time> sau khi Turbo hoàn tất render hoặc chuyển trang
document.addEventListener("turbo:render", syncLocaleAndTime)
document.addEventListener("turbo:load", syncLocaleAndTime)
document.addEventListener("turbo:morph", syncLocaleAndTime)

export default vi
