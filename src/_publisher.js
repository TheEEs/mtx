import Swal from "sweetalert2";
import MediaMTXWebRTCPublisher from "./publisher";
const populateCodecs = () => {
    const videoCodecSelect = document.getElementById('videoCodec');
    const audioCodecSelect = document.getElementById('audioCodec');
    const tempPC = new RTCPeerConnection({});
    tempPC.addTransceiver('video', { direction: 'sendonly' });
    tempPC.addTransceiver('audio', { direction: 'sendonly' });

    return tempPC.createOffer()
        .then((desc) => {
            const sdp = desc.sdp.toLowerCase();

            for (const codec of ['av1/90000', 'vp9/90000', 'vp8/90000', 'h264/90000', 'h265/90000']) {
                if (sdp.includes(codec)) {
                    const opt = document.createElement('option');
                    opt.value = codec;
                    opt.text = codec.split('/')[0].toUpperCase();
                    videoCodecSelect.appendChild(opt);
                }
            }
            for (const codec of ['opus/48000', 'g722/8000', 'pcmu/8000', 'pcma/8000']) {
                if (sdp.includes(codec)) {
                    const opt = document.createElement('option');
                    opt.value = codec;
                    opt.text = codec.split('/')[0].toUpperCase();
                    audioCodecSelect.appendChild(opt);
                }
            }
            tempPC.close();
        });
};

document.addEventListener('DOMContentLoaded', () => {
    const sharing_button = document.getElementById('broadcastBtn');
    const preview_video = document.querySelector("video#preview")

    populateCodecs();

    sharing_button.addEventListener("click", async () => {
        const videoCodec = document.getElementById('videoCodec').value;
        const audioCodec = document.getElementById('audioCodec').value;

        // Kiểm tra xem người dùng đã chọn codec hay chưa
        if (videoCodec.includes('Chọn') || audioCodec.includes('Chọn')) {
            Swal.fire({
                icon: 'warning',
                title: 'Chưa chọn Codec',
                text: 'Vui lòng chọn đầy đủ Video Codec và Audio Codec trước khi bắt đầu phát sóng.',
                confirmButtonColor: '#3085d6',
            });
            return;
        }

        let stream;

        try {
            if (!navigator.mediaDevices || !navigator.mediaDevices.getDisplayMedia) {
                throw new Error('Tính năng ghi màn hình không được hỗ trợ trên trình duyệt này.');
            }
            stream = await navigator.mediaDevices.getDisplayMedia({
                video: true,
                audio: true
            });
            preview_video.srcObject = stream;
            const publisher = new MediaMTXWebRTCPublisher({
                //url: new URL('whip', window.location.href) + window.location.search,
                url: new URL('whip', `https://${process.env.LOCAL_MTX_HOST || window.location.host}/stream/`) + window.location.search,
                stream,
                videoCodec,
                videoBitrate:10000,
                audioBitrate:32,
                audioCodec,
                onError: (err) => {
                    const dot = document.getElementById('connectionDot');
                    const status = document.getElementById('status');
                    dot.className = "w-3 h-3 rounded-full bg-error ml-2";
                    status.innerText = "Lỗi: " + err;
                    status.classList.remove('hidden');
                    status.className = "badge badge-lg badge-error mt-2";
                },
                onConnected: () => {
                    const dot = document.getElementById('connectionDot');
                    const status = document.getElementById('status');
                    dot.className = "w-3 h-3 rounded-full bg-success ml-2 animate-pulse";
                    status.innerText = "Đang phát sóng";
                    status.classList.remove('hidden');
                    status.className = "badge badge-lg badge-success mt-2";
                },
            });
            window.publisher = publisher;
            sharing_button.disabled = true;
        } catch (err) {
            console.error("Lỗi ghi màn hình:", err);
            Swal.fire({
                icon: 'error',
                title: 'Lỗi ghi màn hình',
                text: err.message || err,
            });

            return;
        }

    })
})