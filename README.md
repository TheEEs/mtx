# MTX - Lightweight WebRTC Live Streaming Platform

<p align="center">
  <a href="https://github.com/theees/mtx/actions">
    <img alt="CI/CD Pipeline" src="https://img.shields.io/github/actions/workflow/status/theees/mtx/ci-cd.yml?logo=github-actions&logoColor=white&label=CI%2FCD%20Pipeline" />
  </a>
  <a href="https://github.com/theees/mtx/releases">
    <img src="https://img.shields.io/badge/Version-v0.2.1--alpha-blue" alt="Version" />
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
  <a href="#giấy-phép--license">
    <img src="https://img.shields.io/badge/License-MIT-informational" alt="License" />
  </a>
</p>

<p align="center">
  <strong><a href="#-tiếng-việt">🇻🇳 Tiếng Việt</a></strong> | 
  <strong><a href="#-english">🇬🇧 English</a></strong>
</p>

---

## 🇻🇳 Tiếng Việt

### 1. Giới thiệu dự án

**MTX** là một dự án mã nguồn mở nhỏ gọn, cung cấp giải pháp phát sóng trực tiếp (live streaming) độ trễ cực thấp (sub-second latency) theo mô hình tự lưu trữ (self-hosted). Dự án kết hợp:
- **[MediaMTX](https://github.com/bluenviron/mediamtx)**: Máy chủ truyền thông hiệu năng cao hỗ trợ giao thức WebRTC (WHIP / WHEP).
- **[Caddy](https://caddyserver.com/)**: Reverse proxy tự động quản lý SSL/TLS và điều hướng lưu lượng video/web.
- **[Ruby on Rails 8](https://rubyonrails.org/)**: Ứng dụng quản trị kênh phát sóng, phân quyền người dùng và quản lý phiên phát sóng.

Dự án được xây dựng với tinh thần học hỏi, thử nghiệm công nghệ WebRTC hiện đại và phục vụ các nhu cầu phát sóng nội bộ hoặc quy mô vừa và nhỏ. Hệ thống tập trung vào tính tinh gọn, bảo mật, dễ thiết lập và bảo trì.

---

### 2. Mục đích dự án

- **Tự lưu trữ WebRTC đơn giản**: Cho phép cá nhân và tổ chức tự dựng máy chủ truyền phát video với độ trễ dưới 1 giây mà không phụ thuộc vào các dịch vụ đám mây bên thứ ba.
- **Quản lý phòng phát sóng linh hoạt**: Cung cấp giao diện trực quan để khởi tạo phòng, cấu hình phát sóng công khai hoặc riêng tư, đặt lịch khả dụng và cấp quyền cho phần mềm truyền phát (OBS Studio, FFmpeg,...).
- **Xem trực tiếp không cần plugin**: Trình phát video chuẩn hóa qua giao thức WHEP chạy trực tiếp trên các trình duyệt hiện đại qua thẻ HTML5 `<video>`, không đòi hỏi cài đặt tiện ích mở rộng.

---

### 3. Tính năng nổi bật

- **Truyền phát video độ trễ cực thấp (WebRTC)**:
  - **WHIP (WebRTC HTTP Ingestion Protocol)**: Đẩy luồng trực tiếp từ OBS Studio hoặc các encoder tương thích, xác thực bảo mật bằng Bearer JWT Token.
  - **WHEP (WebRTC HTTP Egress Protocol)**: Trình phát trong trình duyệt xem luồng video thời gian thực với độ trễ tính bằng mili-giây.
- **Quản lý phòng & Phân quyền bảo mật**:
  - **Phòng công khai & Phòng riêng tư**: Dễ dàng chuyển đổi chế độ công khai hoặc riêng tư qua công tắc bật/tắt.
  - **Mật khẩu phòng (Tùy chọn)**: Hỗ trợ cài đặt mật khẩu cho phòng riêng tư. Người xem (đã đăng nhập) cần nhập đúng mật khẩu để mở khóa và xem luồng phát.
  - **Lịch trình phát sóng**: Hỗ trợ thiết lập thời gian bắt đầu (`valid_from`) và kết thúc (`valid_to`), tự động hiển thị thông báo trạng thái khi phòng chưa mở hoặc đã kết thúc.
  - **Khóa luồng phát theo thời gian thực**: Chủ phòng có thể ngắt phiên phát sóng trực tiếp thông qua API của MediaMTX.
  - **Phân quyền với [Pundit](https://github.com/varvet/pundit)**: Khách vãng lai và thành viên có thể khám phá các kênh công khai; chỉ người tạo phòng mới có quyền xem thông số kết nối WHIP, chỉnh sửa thông tin hoặc xóa kênh.
- **Tài khoản & Xác thực chuẩn Rails 8**:
  - Đăng ký tài khoản, gửi email xác nhận kích hoạt tài khoản và quy trình khôi phục mật khẩu.
  - Bảo vệ webhook xác thực máy chủ qua token JWT ký thuật toán `HS512`.
- **Trải nghiệm người dùng & Giao diện tối giản**:
  - **Đa giao diện (Sáng / Tối)**: Chuyển đổi theme mượt mà, lưu vào `localStorage` và xử lý chống nháy sáng (anti-FOUC).
  - **Đa ngôn ngữ (Tiếng Việt / English)**: Hỗ trợ song ngữ đầy đủ từ giao diện đến thông báo lỗi validation; lưu giữ bền vững xuyên suốt các lần mở trình duyệt qua Cookie dài hạn và Session.
  - **Hiển thị thời gian bản địa**: Định dạng ngày giờ tự động thích ứng múi giờ người dùng qua thư viện `local-time`.

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
                  |     (Reverse Proxy & Auto-TLS)    |
                  +--------+-----------------+--------+
                           |                 |
                   /whip, /whep              | Web Traffic (Port 3000)
                           |                 |
                           v                 v
            +----------------------+  +---------------------+
            |       MediaMTX       |  |     Rails 8 App     |
            |   (WebRTC Server)    |  |  (Solid Queue / DB) |
            +----------+-----------+  +----------+----------+
                       ^                         |
                       |--- JWT Webhook Callback |
```

---

### 5. Yêu cầu môi trường

- [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/engine/install/) & [Docker Compose v2](https://docs.docker.com/compose/)
- *(Tùy chọn khi phát triển trực tiếp trên máy)*: Ruby 3.4.10, SQLite 3.x

---

### 6. Cài đặt và Khởi chạy

#### Cách 1: Sử dụng Docker Compose (Khuyên dùng)

1. **Tải mã nguồn về máy**:
   ```bash
   git clone https://github.com/theees/mtx.git
   cd mtx
   ```

2. **Cấu hình mạng và tên miền**:
   - Kiểm tra và chỉnh sửa tên miền trong [`caddy/Caddyfile`](caddy/Caddyfile) phù hợp với môi trường của bạn (`localhost` hoặc domain thật).
   - Kiểm tra các cổng kết nối trong [`docker-compose.yml`](docker-compose.yml) (mặc định: `80`, `443`, `8890/udp`, `8189/udp`).

3. **Khởi chạy hệ thống**:
   ```bash
   docker compose up -d --build
   ```

4. **Trải nghiệm ứng dụng**:
   - Mở trình duyệt và truy cập `http://localhost` (hoặc tên miền bạn đã cấu hình).

---

#### Cách 2: Phát triển ứng dụng Rails cục bộ

Nếu bạn muốn tùy chỉnh hoặc phát triển thêm tính năng cho ứng dụng quản trị Rails:

1. **Di chuyển vào thư mục `admin`**:
   ```bash
   cd admin
   ```

2. **Cài đặt các gói phụ thuộc (Gems)**:
   ```bash
   bundle install
   ```

3. **Khởi tạo cơ sở dữ liệu SQLite**:
   ```bash
   bin/rails db:prepare
   ```

4. **Khởi chạy Rails Server**:
   ```bash
   bin/rails server
   ```
   Ứng dụng sẽ hoạt động tại `http://localhost:3000`.

5. **Chạy bộ kiểm thử (Test suite)**:
   ```bash
   bin/rails test
   ```

---

### 7. Hướng dẫn đóng góp (Contributing)

Mọi đóng góp, báo cáo lỗi và đề xuất cải tiến đều rất đáng trân trọng! Bạn có thể tham gia đóng góp theo quy trình sau:

1. **Fork** kho lưu trữ này về tài khoản GitHub của bạn.
2. Tạo nhánh mới mô tả nội dung bạn dự định thực hiện:
   ```bash
   git checkout -b feature/ten-tinh-nang
   # hoặc: git checkout -b fix/loi-can-sua
   ```
3. Viết code tuân thủ phong cách lập trình Rails và bổ sung các ca kiểm thử tương ứng.
4. Kiểm tra để đảm bảo toàn bộ test case đều chạy thành công:
   ```bash
   bin/rails test
   ```
5. Commit thay đổi với thông điệp rõ ràng:
   ```bash
   git commit -m "feat: bổ sung tính năng X"
   ```
6. Đẩy nhánh lên remote repository:
   ```bash
   git push origin feature/ten-tinh-nang
   ```
7. Mở một **Pull Request (PR)** trên GitHub để cùng thảo luận và rà soát mã nguồn.

---
---

## 🇬🇧 English

### 1. Introduction

**MTX** is a lightweight, self-hosted WebRTC live streaming platform designed to provide ultra-low latency broadcasting. It combines:
- **[MediaMTX](https://github.com/bluenviron/mediamtx)**: A high-performance media server supporting standardized WebRTC protocols (WHIP / WHEP).
- **[Caddy](https://caddyserver.com/)**: An automated reverse proxy handling SSL/TLS certificates and routing video/web traffic.
- **[Ruby on Rails 8](https://rubyonrails.org/)**: A web application managing broadcast rooms, user authorization, and streaming lifecycle.

Built with a learning-oriented mindset, MTX is ideal for experiments, internal broadcasting, and small-to-medium streaming scenarios. The platform emphasizes simplicity, security, and straightforward maintenance.

---

### 2. Project Purpose

- **Simplify Self-Hosted WebRTC**: Enable individuals and organizations to operate their own sub-second latency streaming infrastructure without third-party cloud lock-in.
- **Flexible Broadcast Management**: Offer an intuitive dashboard to create channels, toggle public or private visibility, set schedules, and retrieve encoder configuration (for OBS Studio, FFmpeg, etc.).
- **Plugin-Free In-Browser Viewing**: Deliver live video through standardized WHEP natively rendered inside HTML5 `<video>` elements without requiring third-party plugins.

---

### 3. Key Features

- **Sub-Second Low-Latency Streaming (WebRTC)**:
  - **WHIP (WebRTC HTTP Ingestion Protocol)**: Ingest live streams directly from OBS Studio or compatible encoders secured with JWT Bearer Tokens.
  - **WHEP (WebRTC HTTP Egress Protocol)**: Real-time playback inside the browser with millisecond-grade latency.
- **Room Management & Access Control**:
  - **Public & Private Rooms**: Easily switch visibility using an interactive toggle.
  - **Room Password (Optional)**: Set an optional password for private rooms. Viewers (signed-in accounts) must enter the correct password to unlock and watch the stream.
  - **Broadcast Scheduling**: Set active start (`valid_from`) and end (`valid_to`) times with helpful notices when a room is not yet started or has expired.
  - **Real-Time Stream Termination**: Channel owners can terminate/kick out active WebRTC publisher sessions via MediaMTX APIs.
  - **Role-Based Authorization ([Pundit](https://github.com/varvet/pundit))**: Public channels are discoverable by everyone; only room owners can view WHIP parameters, edit settings, or delete channels.
- **Rails 8 Authentication & Security**:
  - User registration, email confirmation, and password reset flows.
  - MediaMTX daemon webhook authentication protected by `HS512` signed JWT tokens.
- **Minimalist & Accessible UI**:
  - **Light / Dark Theme**: Smooth theme switching persisted in `localStorage` with anti-FOUC script.
  - **Bilingual Support (Vietnamese & English)**: Complete internationalization persisted across browser sessions via persistent cookies and sessions.
  - **Localized Timestamps**: Relative and localized date/time formatting via `local-time`.

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
            |   (WebRTC Server)    |  |  (Solid Queue / DB) |
            +----------+-----------+  +----------+----------+
                       ^                         |
                       |--- JWT Webhook Callback |
```

---

### 5. Prerequisites

- [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/engine/install/) & [Docker Compose v2](https://docs.docker.com/compose/)
- *(Optional for local Rails development)*: Ruby 3.4.10, SQLite 3.x

---

### 6. Installation & Quick Start

#### Method 1: Using Docker Compose (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/theees/mtx.git
   cd mtx
   ```

2. **Configure your domain**:
   - Inspect and update [`caddy/Caddyfile`](caddy/Caddyfile) to match your environment (`localhost` or production domain).
   - Verify network ports in [`docker-compose.yml`](docker-compose.yml) (default: `80`, `443`, `8890/udp`, `8189/udp`).

3. **Start the services**:
   ```bash
   docker compose up -d --build
   ```

4. **Access the application**:
   - Open your browser at `http://localhost` (or your configured domain).

---

#### Method 2: Local Rails Development

If you wish to develop or modify the Rails dashboard directly:

1. **Navigate to the `admin` directory**:
   ```bash
   cd admin
   ```

2. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

3. **Prepare the SQLite database**:
   ```bash
   bin/rails db:prepare
   ```

4. **Start the development server**:
   ```bash
   bin/rails server
   ```
   The application will be accessible at `http://localhost:3000`.

5. **Run the test suite**:
   ```bash
   bin/rails test
   ```

---

### 7. Contributing

Contributions, bug reports, and suggestions are warmly appreciated! To contribute:

1. **Fork** this repository to your GitHub account.
2. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   # or: git checkout -b fix/issue-description
   ```
3. Implement your changes following Rails best practices and write appropriate tests.
4. Ensure all tests pass:
   ```bash
   bin/rails test
   ```
5. Commit your work with clear, concise messages:
   ```bash
   git commit -m "feat: add feature X"
   ```
6. Push to your branch:
   ```bash
   git push origin feature/your-feature-name
   ```
7. Open a **Pull Request (PR)** on GitHub for review and discussion.

---

### Giấy phép / License

Dự án được phân phối dưới giấy phép **[MIT License](https://opensource.org/licenses/MIT)**.  
This project is open-source software licensed under the **[MIT License](https://opensource.org/licenses/MIT)**.
