import { Controller } from "@hotwired/stimulus"
import MediaMTXWebRTCPublisher from "publisher"

const KNOWN_VIDEO_CODECS = [
  { id: "h264", label: "H.264 / AVC" },
  { id: "vp8",  label: "VP8" },
  { id: "vp9",  label: "VP9" },
  { id: "av1",  label: "AV1" }
]

const KNOWN_AUDIO_CODECS = [
  { id: "opus", label: "Opus" },
  { id: "pcmu", label: "PCMU (G.711 µ-law)" },
  { id: "pcma", label: "PCMA (G.711 A-law)" }
]

export default class extends Controller {
  static targets = [
    "modal",
    "unsupportedView",
    "configView",
    "videoCodecSelect",
    "audioCodecSelect",
    "includeAudioCheckbox",
    "activeBanner",
    "duration",
    "status",
    "errorAlert",
    "errorMessage",
    "startShareButton"
  ]

  static values = {
    url: String,
    token: String,
    roomId: String,
    connectedText: { type: String, default: "Đã kết nối luồng" },
    connectingText: { type: String, default: "Đang kết nối..." }
  }

  publisher = null
  stream = null
  timerInterval = null
  startTime = null

  disconnect() {
    this.stop()
  }

  get isSupported() {
    return (
      typeof navigator !== "undefined" &&
      Boolean(navigator.mediaDevices) &&
      typeof navigator.mediaDevices.getDisplayMedia === "function"
    )
  }

  open(event) {
    event?.preventDefault()
    this.clearError()

    if (!this.isSupported) {
      if (this.hasUnsupportedViewTarget) {
        this.unsupportedViewTarget.classList.remove("hidden")
      }
      if (this.hasConfigViewTarget) {
        this.configViewTarget.classList.add("hidden")
      }
    } else {
      if (this.hasUnsupportedViewTarget) {
        this.unsupportedViewTarget.classList.add("hidden")
      }
      if (this.hasConfigViewTarget) {
        this.configViewTarget.classList.remove("hidden")
      }
      this.populateCodecs()
    }

    this.showModal()
  }

  showModal() {
    if (!this.hasModalTarget) return

    if (typeof this.modalTarget.showModal === "function") {
      this.modalTarget.showModal()
    } else {
      this.modalTarget.classList.add("modal-open")
    }
  }

  closeModal() {
    if (!this.hasModalTarget) return

    if (typeof this.modalTarget.close === "function") {
      this.modalTarget.close()
    } else {
      this.modalTarget.classList.remove("modal-open")
    }
  }

  populateCodecs() {
    if (this.hasVideoCodecSelectTarget) {
      const supportedVideos = this.getAvailableVideoCodecs()
      this.videoCodecSelectTarget.innerHTML = ""
      supportedVideos.forEach((codec, index) => {
        const option = document.createElement("option")
        option.value = codec.id
        option.text = `${codec.label} (${codec.id.toUpperCase()})`
        if (index === 0) option.selected = true
        this.videoCodecSelectTarget.appendChild(option)
      })
    }

    if (this.hasAudioCodecSelectTarget) {
      const supportedAudios = this.getAvailableAudioCodecs()
      this.audioCodecSelectTarget.innerHTML = ""
      supportedAudios.forEach((codec, index) => {
        const option = document.createElement("option")
        option.value = codec.id
        option.text = `${codec.label} (${codec.id.toUpperCase()})`
        if (index === 0) option.selected = true
        this.audioCodecSelectTarget.appendChild(option)
      })
    }
  }

  getAvailableVideoCodecs() {
    if (typeof RTCRtpSender !== "undefined" && typeof RTCRtpSender.getCapabilities === "function") {
      try {
        const caps = RTCRtpSender.getCapabilities("video")
        if (caps && Array.isArray(caps.codecs)) {
          const supported = new Set()
          for (const c of caps.codecs) {
            const name = c.mimeType.replace(/^video\//i, "").toLowerCase()
            supported.add(name)
          }
          const matched = KNOWN_VIDEO_CODECS.filter((c) => supported.has(c.id))
          if (matched.length > 0) return matched
        }
      } catch (err) {
        console.warn("Error querying video capabilities:", err)
      }
    }
    return KNOWN_VIDEO_CODECS.slice(0, 3)
  }

  getAvailableAudioCodecs() {
    if (typeof RTCRtpSender !== "undefined" && typeof RTCRtpSender.getCapabilities === "function") {
      try {
        const caps = RTCRtpSender.getCapabilities("audio")
        if (caps && Array.isArray(caps.codecs)) {
          const supported = new Set()
          for (const c of caps.codecs) {
            const name = c.mimeType.replace(/^audio\//i, "").toLowerCase()
            supported.add(name)
          }
          const matched = KNOWN_AUDIO_CODECS.filter((c) => supported.has(c.id))
          if (matched.length > 0) return matched
        }
      } catch (err) {
        console.warn("Error querying audio capabilities:", err)
      }
    }
    return KNOWN_AUDIO_CODECS
  }

  async startSharing(event) {
    event?.preventDefault()
    this.clearError()

    if (!this.isSupported) {
      this.showError("Trình duyệt không hỗ trợ tính năng chia sẻ màn hình.")
      return
    }

    const includeAudio = this.hasIncludeAudioCheckboxTarget
      ? this.includeAudioCheckboxTarget.checked
      : true

    if (this.hasStartShareButtonTarget) {
      this.startShareButtonTarget.disabled = true
      this.startShareButtonTarget.classList.add("loading")
    }

    try {
      this.stream = await navigator.mediaDevices.getDisplayMedia({
        video: {
          cursor: "always"
        },
        audio: includeAudio
      })
    } catch (err) {
      if (this.hasStartShareButtonTarget) {
        this.startShareButtonTarget.disabled = false
        this.startShareButtonTarget.classList.remove("loading")
      }

      if (err.name === "NotAllowedError") {
        // Người dùng chủ động hủy hộp thoại chọn màn hình
        this.closeModal()
        return
      }

      this.showError(err.message || "Không thể truy cập màn hình.")
      return
    }

    if (this.hasStartShareButtonTarget) {
      this.startShareButtonTarget.disabled = false
      this.startShareButtonTarget.classList.remove("loading")
    }

    // Khi người dùng bấm dừng chia sẻ trên thanh điều khiển của trình duyệt / hệ điều hành
    const videoTrack = this.stream.getVideoTracks()[0]
    if (videoTrack) {
      videoTrack.addEventListener("ended", () => {
        this.stop()
      })
    }

    const videoCodec = this.hasVideoCodecSelectTarget
      ? this.videoCodecSelectTarget.value
      : "h264"
    const audioCodec = this.hasAudioCodecSelectTarget
      ? this.audioCodecSelectTarget.value
      : "opus"

    const whipBase = this.urlValue || window.location.origin
    const whipUrl = new URL(`${this.roomIdValue}/whip`, whipBase).toString() + window.location.search

    this.closeModal()

    if (this.hasActiveBannerTarget) {
      this.activeBannerTarget.classList.remove("hidden")
    }

    if (this.hasStatusTarget) {
      this.statusTarget.innerText = this.connectingTextValue
      this.statusTarget.classList.remove("text-error")
    }

    this.startTimer()

    this.publisher = new MediaMTXWebRTCPublisher({
      url: whipUrl,
      user: "",
      pass: "",
      token: this.tokenValue,
      stream: this.stream,
      videoCodec: videoCodec,
      videoBitrate: 3000,
      audioCodec: audioCodec,
      audioBitrate: 128,
      audioVoice: false,
      onError: (err) => {
        console.error("WebRTC Publisher error:", err)
        if (this.hasStatusTarget) {
          this.statusTarget.innerText = `Lỗi kết nối: ${err}`
          this.statusTarget.classList.add("text-error")
        }
      },
      onConnected: () => {
        console.log("WebRTC Publisher connected successfully")
        if (this.hasStatusTarget) {
          this.statusTarget.innerText = this.connectedTextValue
          this.statusTarget.classList.remove("text-error")
        }
      }
    })
  }

  stop(event) {
    event?.preventDefault()

    if (this.publisher) {
      try {
        this.publisher.close()
      } catch (e) {
        console.warn("Error closing publisher:", e)
      }
      this.publisher = null
    }

    if (this.stream) {
      try {
        this.stream.getTracks().forEach((track) => track.stop())
      } catch (e) {
        console.warn("Error stopping tracks:", e)
      }
      this.stream = null
    }

    this.stopTimer()

    if (this.hasActiveBannerTarget) {
      this.activeBannerTarget.classList.add("hidden")
    }
  }

  startTimer() {
    this.stopTimer()
    this.startTime = Date.now()
    if (this.hasDurationTarget) {
      this.durationTarget.innerText = "00:00"
    }
    this.timerInterval = setInterval(() => {
      const elapsedSec = Math.floor((Date.now() - this.startTime) / 1000)
      const mins = String(Math.floor(elapsedSec / 60)).padStart(2, "0")
      const secs = String(elapsedSec % 60).padStart(2, "0")
      if (this.hasDurationTarget) {
        this.durationTarget.innerText = `${mins}:${secs}`
      }
    }, 1000)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = null
    }
  }

  showError(message) {
    if (this.hasErrorAlertTarget && this.hasErrorMessageTarget) {
      this.errorMessageTarget.innerText = message
      this.errorAlertTarget.classList.remove("hidden")
    }
  }

  clearError() {
    if (this.hasErrorAlertTarget && this.hasErrorMessageTarget) {
      this.errorMessageTarget.innerText = ""
      this.errorAlertTarget.classList.add("hidden")
    }
  }
}
