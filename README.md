# MTX - Lightweight WebRTC Live Streaming Platform

<p align="center">
  <a href="https://github.com/TheEEs/mtx/actions/workflows/ci.yml">
    <img src="https://img.shields.io/badge/CI%20Build-Passing-brightgreen?logo=github-actions&logoColor=white" alt="CI Status" />
  </a>
  <a href="https://github.com/TheEEs/mtx">
    <img src="https://img.shields.io/badge/Deploy-Running-success?logo=docker&logoColor=white" alt="Deployment Status" />
  </a>
  <a href="https://github.com/TheEEs/mtx/releases">
    <img src="https://img.shields.io/badge/Version-v0.2.0--alpha-blue" alt="Version" />
  </a>
  <a href="https://www.ruby-lang.org">
    <img src="https://img.shields.io/badge/Ruby-3.4.10-CC342D?logo=ruby&logoColor=white" alt="Ruby Version" />
  </a>
  <a href="https://rubyonrails.org">
    <img src="https://img.shields.io/badge/Rails-8.1.3-CC0000?logo=rubyonrails&logoColor=white" alt="Rails Version" />
  </a>
  <a href="https://github.com/bluenviron/mediamtx">
    <img src="https://img.shields.io/badge/MediaMTX-v1.17.1-00ADD8?logo=webrtc&logoColor=white" alt="MediaMTX Version" />
  </a>
  <a href="#license">
    <img src="https://img.shields.io/badge/License-MIT-informational" alt="License" />
  </a>
</p>

<p align="center">
  <strong><a href="#ti%E1%BA%BFng-vi%E1%BB%87t">🇻🇳 Tiếng Việt</a></strong> | 
  <strong><a href="#english">🇬🇧 English</a></strong>
</p>

---

## Tiếng Việt

### 1. Giới thiệu dự án

**MTX** là một dự án mã nguồn mở nhỏ gọn, được xây dựng nhằm cung cấp giải pháp phát sóng trực tiếp (live streaming) độ trễ thấp tự lưu trữ (self-hosted). Dự án kết hợp máy chủ truyền thông [MediaMTX](https://github.com/bluenviron/mediamtx) hỗ trợ giao thức WebRTC hiện đại, máy chủ proxy an toàn [Caddy](https://caddyserver.com/) và ứng dụng quản lý kênh phát sóng bằng [Ruby on Rails 8](https://rubyonrails.org/).

Dự án này ban đầu được phát triển với mục đích học tập, thử nghiệm các công nghệ truyền phát video độ trễ thấp trong trình duyệt và phục vụ nhu cầu phát trực tiếp nội bộ hoặc quy mô vừa và nhỏ. Dự án không hướng tới việc thay thế các nền tảng thương mại quy mô lớn, mà tập trung vào sự đơn giản, dễ cài đặt và dễ bảo trì.

---

### 2. Mục đích dự án

- **Đơn giản hóa việc tự lưu trữ WebRTC**: Giúp cá nhân và nhóm nhỏ dễ dàng dựng máy chủ phát sóng WebRTC với độ trễ chỉ dưới 1 giây mà không phụ thuộc vào hạ tầng bên thứ ba.
- **Quản lý kênh phát sóng trực quan**: Cung cấp giao diện web tinh gọn để tạo phòng phát, đặt lịch hoạt động, kiểm soát bảo mật và tạo thông số kết nối cho phần mềm phát sóng (OBS Studio, FFmpeg,...).
- **Trải nghiệm xem trực tiếp không cần plugin**: Người xem theo dõi video trực tiếp ngay trên trình duyệt hiện đại qua giao thức WHEP chuẩn hóa, không cần cài đặt phần mềm phụ trợ.

---

### 3. Tính năng chính

- **Truyền phát độ trễ cực thấp (Sub-second Latency)**:
  - **WHIP (WebRTC HTTP Ingestion Protocol)**: Đẩy luồng từ OBS Studio hoặc các encoder tương thích thông qua Bearer Token bảo mật (JWT).
  - **WHEP (WebRTC HTTP Egress Protocol)**: Người xem theo dõi luồng phát trực tiếp qua phần tử HTML5 `<video>` với độ trễ tính bằng mili-giây.
- **Quản lý phòng phát sóng & Lịch trình**:
  - Đặt khung thời gian phát sóng (`valid_from` đến `valid_to`), tự động thông báo khi phòng đã hết hạn.
  - Hỗ trợ khóa/mở luồng phát sóng theo thời gian thực (ngắt kết nối stream trực tiếp trên MediaMTX).
- **Phân quyền & Tài khoản người dùng**:
  - Hệ thống xác thực Rails 8 với xác nhận email kích hoạt tài khoản.
  - Phân quyền bằng [Pundit](https://github.com/varvet/pundit): Trang chủ hiển thị công khai các kênh mới; chỉ chủ sở hữu kênh mới có quyền chỉnh sửa, xem thông số WHIP và quản lý luồng của mình.
- **Giao diện & Trải nghiệm người dùng**:
  - Thiết kế tối giản, hỗ trợ giao diện **Sáng (Light) / Tối (Dark)** với cơ chế lưu client-side và chống nháy sáng (anti-FOUC).
  - Hỗ trợ song ngữ **Tiếng Việt** và **Tiếng Anh** (lưu lựa chọn vào session, hiển thị thời gian linh hoạt với `local-time`).

---

### 4. Kiến trúc hệ thống

```
                  +-----------------------------------+
                  |          Clients (Browser)        |
                  +--------+-----------------+--------+
                           |                 |
                HTTP / HTTPS                 | WebRTC (WHEP / WHIP)
                           |                 |
                           v                 v
                  +-----------------------------------+
                  |           Caddy Proxy             |
                  |     (Reverse Proxy & SSL Auto)    |
                  +--------+-----------------+--------+
                           |                 |
                   /whip, /whep              | Web Traffic (Port 3000)
                           |                 |
                           v                 v
            +----------------------+  +---------------------+
            |       MediaMTX       |  |     Rails 8 App     |
            |   (WebRTC Server)    |  | (Auth, Rooms, Pundit|
            +----------+-----------+  +----------+----------+
                       ^                         |
                       |--- JWT Webhook Callback |
```

---

### 5. Yêu cầu hệ thống

Trước khi bắt đầu, hãy đảm bảo máy chủ hoặc máy tính của bạn đã cài đặt:
- [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/engine/install/) & [Docker Compose v2](https://docs.docker.com/compose/)
- *(Tùy chọn cho môi trường dev cục bộ)*: Ruby 3.4.10, SQLite 3.x, Node.js (nếu cần tinh chỉnh asset)

---

### 6. Cài đặt và Khởi chạy

#### Cách 1: Chạy bằng Docker Compose (Khuyên dùng)

1. **Sao chép mã nguồn về máy**:
   ```bash
   git clone https://github.com/TheEEs/mtx.git
   cd mtx
   ```

2. **Cấu hình biến môi trường**:
   - Điều chỉnh cấu hình tên miền trong [`caddy/Caddyfile`](caddy/Caddyfile) phù hợp với domain hoặc IP của bạn.
   - Kiểm tra các cổng cần thiết trong [`docker-compose.yml`](docker-compose.yml) (mặc định: `80`, `443`, `8890/udp`, `8189/udp`).

3. **Khởi động các dịch vụ**:
   ```bash
   docker compose up -d --build
   ```

4. **Truy cập ứng dụng**:
   - Mở trình duyệt và truy cập: `http://localhost` (hoặc domain bạn đã cấu hình).

---

#### Cách 2: Phát triển cục bộ (Local Development)

Nếu bạn muốn phát triển trực tiếp phần ứng dụng web Rails:

1. **Di chuyển vào thư mục `admin`**:
   ```bash
   cd admin
   ```

2. **Cài đặt các thư viện (Gems)**:
   ```bash
   bundle install
   ```

3. **Khởi tạo cơ sở dữ liệu**:
   ```bash
   bin/rails db:prepare
   ```

4. **Khởi động máy chủ phát triển Rails**:
   ```bash
   bin/rails server
   ```
   Ứng dụng sẽ khả dụng tại: `http://localhost:3000`.

5. **Chạy kiểm thử (Test suite)**:
   ```bash
   bin/rails test
   ```

---

### 7. Hướng dẫn đóng góp (Contributing)

Chúng tôi luôn hoan nghênh những đóng góp giúp dự án hoàn thiện hơn! Nếu bạn phát hiện lỗi hoặc muốn đề xuất cải tiến:

1. **Fork** kho lưu trữ này về tài khoản GitHub của bạn.
2. Tạo một nhánh mới mô tả tính năng hoặc bản sửa lỗi:
   ```bash
   git checkout -b feature/ten-tinh-nang-moi
   # hoặc: git checkout -b fix/mo-ta-loi
   ```
3. Thực hiện thay đổi, tuân thủ phong cách lập trình của Rails và viết bổ sung test nếu cần thiết.
4. Đảm bảo toàn bộ test hiện có đều vượt qua thành công:
   ```bash
   bin/rails test
   ```
5. Commit thay đổi với thông điệp rõ ràng:
   ```bash
   git commit -m "feat: bổ sung tính năng X"
   ```
6. Push lên nhánh của bạn:
   ```bash
   git push origin feature/ten-tinh-nang-moi
   ```
7. Mở một **Pull Request (PR)** và mô tả ngắn gọn về những nội dung bạn đã thay đổi.

---

### 8. Giấy phép (License)

Dự án được phân phối dưới giấy phép [MIT License](https://opensource.org/licenses/MIT). Bạn hoàn toàn tự do sử dụng, chỉnh sửa và triển khai theo nhu cầu của mình.

---
---

## English

### 1. Introduction

**MTX** is a modest, lightweight open-source platform designed to provide a self-hosted live streaming solution with ultra-low latency. It integrates the [MediaMTX](https://github.com/bluenviron/mediamtx) media server for modern WebRTC streaming, [Caddy](https://caddyserver.com/) for automatic HTTPS and reverse proxying, and a straightforward channel management web application built on [Ruby on Rails 8](https://rubyonrails.org/).

This project was built primarily for learning, testing low-latency in-browser video streaming technologies, and serving small-to-medium or internal streaming use cases. It does not aim to replace large-scale commercial platforms, but rather focuses on simplicity, ease of deployment, and straightforward maintenance.

---

### 2. Project Purpose

- **Simplify Self-Hosted WebRTC**: Make it easy for individuals and small teams to deploy a sub-second latency streaming server without relying on third-party cloud infrastructure.
- **Straightforward Channel Management**: Provide a clean web dashboard to create broadcast rooms, set active schedules, manage security access, and obtain encoder connection credentials (for OBS Studio, FFmpeg, etc.).
- **Plugin-Free Playback**: Allow viewers to watch live streams directly in modern browsers via standardized WHEP without requiring third-party player plugins or heavy extensions.

---

### 3. Key Features

- **Sub-Second Low Latency Streaming**:
  - **WHIP (WebRTC HTTP Ingestion Protocol)**: Publish video streams from OBS Studio or compatible encoders using authenticated Bearer Tokens (JWT).
  - **WHEP (WebRTC HTTP Egress Protocol)**: Stream playback directly through HTML5 `<video>` tags with millisecond-level latency.
- **Channel & Schedule Management**:
  - Set active broadcasting windows (`valid_from` to `valid_to`) with automatic expiration warnings.
  - Real-time stream blocking/unblocking (disconnect active streams directly via MediaMTX session API).
- **User Authentication & Authorization**:
  - Built on Rails 8 authentication with email confirmation and password reset flows.
  - Authorized with [Pundit](https://github.com/varvet/pundit): public exploration on the homepage, strict creator-only permissions for channel editing, WHIP credential retrieval, and stream management.
- **Clean User Experience**:
  - Minimalist UI with **Light / Dark** theme switching, persisted via `localStorage` with zero flash of unstyled content (anti-FOUC).
  - Bilingual support (**Vietnamese** and **English**) persisted across sessions with localized timestamps via `local-time`.

---

### 4. System Architecture

```
                  +-----------------------------------+
                  |          Clients (Browser)        |
                  +--------+-----------------+--------+
                           |                 |
                HTTP / HTTPS                 | WebRTC (WHEP / WHIP)
                           |                 |
                           v                 v
                  +-----------------------------------+
                  |           Caddy Proxy             |
                  |     (Reverse Proxy & Auto-TLS)    |
                  +--------+-----------------+--------+
                           |                 |
                   /whip, /whep              | Web Traffic (Port 3000)
                           |                 |
                           v                 v
            +----------------------+  +---------------------+
            |       MediaMTX       |  |     Rails 8 App     |
            |   (WebRTC Server)    |  | (Auth, Rooms, Pundit|
            +----------+-----------+  +----------+----------+
                       ^                         |
                       |--- JWT Webhook Callback |
```

---

### 5. Prerequisites

Before getting started, make sure you have installed:
- [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/engine/install/) & [Docker Compose v2](https://docs.docker.com/compose/)
- *(Optional for standalone local development)*: Ruby 3.4.10, SQLite 3.x

---

### 6. Installation & Quick Start

#### Method 1: Run with Docker Compose (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/TheEEs/mtx.git
   cd mtx
   ```

2. **Configure your domain**:
   - Check and adjust domain configurations in [`caddy/Caddyfile`](caddy/Caddyfile) to match your domain or IP address.
   - Verify network ports in [`docker-compose.yml`](docker-compose.yml) (default: `80`, `443`, `8890/udp`, `8189/udp`).

3. **Start the services**:
   ```bash
   docker compose up -d --build
   ```

4. **Access the web app**:
   - Open your browser at `http://localhost` (or your configured domain).

---

#### Method 2: Local Rails Development

If you want to work directly on the Rails application:

1. **Navigate to the `admin` directory**:
   ```bash
   cd admin
   ```

2. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

3. **Prepare the database**:
   ```bash
   bin/rails db:prepare
   ```

4. **Start the Rails development server**:
   ```bash
   bin/rails server
   ```
   The application will be running at `http://localhost:3000`.

5. **Run the test suite**:
   ```bash
   bin/rails test
   ```

---

### 7. Contributing

Contributions, bug reports, and suggestions are always welcome! If you would like to help improve the project:

1. **Fork** this repository to your GitHub account.
2. Create a new branch describing your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   # or: git checkout -b fix/issue-description
   ```
3. Make your changes adhering to Rails conventions, and add test cases where applicable.
4. Ensure all existing tests pass:
   ```bash
   bin/rails test
   ```
5. Commit your work with a clear, concise commit message:
   ```bash
   git commit -m "feat: add feature description"
   ```
6. Push to your branch:
   ```bash
   git push origin feature/your-feature-name
   ```
7. Open a **Pull Request (PR)** describing your changes.

---

### 8. License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). You are free to use, modify, and distribute it according to your needs.
