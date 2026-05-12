import { Controller } from "@hotwired/stimulus"

import MediaMTXWebRTCReader from "reader";

export default class extends Controller {
    reader = null;
    static targets = ["badge", "badgeText", "whipUrl", "tokenCopied"]
    static values = {
        url: String,
        token: String,
        roomId: String
    }
    connect() {
        this.whipUrlTarget.innerText = new URL(`${this.roomIdValue}/whip`, this.urlValue) + window.location.search
        this.reader = new MediaMTXWebRTCReader({
            url: new URL(`${this.roomIdValue}/whep`, this.urlValue) + window.location.search,
            user: "",
            pass: "",
            token: this.tokenValue,
            onError: (err) => {
                this.badgeTarget.classList.replace("badge-success", "badge-neutral");
                this.badgeTextTarget.innerText = "Chưa phát"
                console.error(err);
            },
            onTrack: (evt) => {
                this.badgeTarget.classList.replace("badge-neutral", "badge-success");
                this.badgeTextTarget.innerText = "Đang phát"
                document.getElementById("playing_video").srcObject = evt.streams[0];
            },
            onDataChannel: (evt) => {
                evt.channel.binaryType = "arraybuffer";
                evt.channel.onmessage = (msg) => {
                    console.log("Data channel message: ", msg.data);
                }
            }
        });
    }
    async copyTokenToClipboard(e) {
        try {
            await navigator.clipboard.writeText(this.tokenValue);
            this.tokenCopiedTarget.innerText = e.params.copied;
            console.log('Token copied to clipboard');
        } catch (err) {
            console.error('Failed to copy: ', err);
        }
    }

    disconnect() {
        this.reader.close();
        delete this.reader;
    }
}