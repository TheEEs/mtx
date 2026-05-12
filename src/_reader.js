import MediaMTXWebRTCReader from "./reader";
let reader = null;
document.addEventListener('DOMContentLoaded', () => {
    reader = new MediaMTXWebRTCReader({
        url: `https://${window.location.host}/stream/whep`,
        user: "",
        pass: "",
        token: "",
        onError: (err) => {
            const dot = document.getElementById('connectionDot');
            const status = document.getElementById('status');
            dot.className = "w-3 h-3 rounded-full bg-error ml-2";
            status.innerText = "Lỗi: " + err;
            status.classList.remove('hidden');
            status.className = "badge badge-lg badge-error mt-2";
            console.error(err);
        },
        onTrack: (evt) => {
            const dot = document.getElementById('connectionDot');
            const status = document.getElementById('status');
            dot.className = "w-3 h-3 rounded-full bg-success ml-2 animate-pulse";
            status.innerText = "Đang phát sóng";
            status.classList.remove('hidden');
            status.className = "badge badge-lg badge-success mt-2";
            document.getElementById("playing_video").srcObject = evt.streams[0];
        },
        onDataChannel: (evt) => {
            evt.channel.binaryType = "arraybuffer";
            evt.channel.onmessage = (msg) => {
                console.log("Data channel message: ", msg.data);
            }
        }
    });
})