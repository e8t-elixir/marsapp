// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import topbar from "topbar";
import { LiveSocket } from "phoenix_live_view";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// const localStream
let localStream;
let users = {};

let initStream = async () => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      audio: true,
      video: true,
      widht: "1280",
    });
    localStream = stream;
    document.getElementById("local-video").srcObject = stream;
  } catch (e) {
    console.error(e);
  }
};

let addUserConnection = (userUuid) => {
  if (users[userUuid] === undefined) {
    users[userUuid] = {
      peerConn: null,
    };
  }
  return users;
};

let removeUserConnection = (userUuid) => {
  delete users[userUuid];
  return users;
};

let stun = { urls: "stun:stun.l.google.com:19302" };
// let stun = { urls: "stun:littlechat.app:3478" };

// lv: liveview 的 this
// fromUser: 其他 peer
// 转发来的 offer
let createPeerConnection = (lv, fromUser, offer) => {
  let newPeerConn = new RTCPeerConnection({
    iceServers: [stun],
  });
  users[fromUser].peerConn = newPeerConn;
  localStream
    .getTracks()
    .forEach((track) => newPeerConn.addTrack(track, localStream));

  if (offer !== undefined) {
    // create answer
    newPeerConn.setRemoteDescription({ type: "offer", sdp: offer });
    newPeerConn
      .createAnswer()
      .then((answer) => {
        newPeerConn.setLocalDescription(answer);
        console.log(`Sending ANSWER to requester: ${answer}`);
        lv.pushEvent("new_answer", { toUser: fromUser, description: answer });
      })
      .catch(console.error);
  }

  newPeerConn.onicecandidate = async ({ candidate }) => {
    // fromUser 会成为新的 toUser 需要将 candidate 发送回来
    lv.pushEvent("new_ice_candidate", { toUser: fromUser, candidate });
  };

  // 创建 peer connection 时不添加 onnegotiationneeded 回调，避免 chrome webrtc 实现 bug
  if (offer === undefined) {
    newPeerConn.onnegotiationneeded = async () => {
      try {
        newPeerConn
          .createOffer()
          .then((offer) => {
            newPeerConn.setLocalDescription(offer);
            console.log(`Sending OFFER to the requester: ${offer}`);
            lv.pushEvent("new_offer", { toUser: fromUser, description: offer });
          })
          .catch(console.error);
      } catch (e) {
        console.error(e);
      }
    };
  }

  // 添加 stream 到对应 video tag
  newPeerConn.ontrack = async (event) => {
    console.log(`Track received: ${event}`);
    document.getElementById(`video-remote-${fromUser}`).srcObject =
      event.streams[0];
  };
  return newPeerConn;
};

let Hooks = {};

Hooks.JoinCall = {
  mounted() {
    initStream();
  },
};

// 在 html data-user-uuid 中获取 uuid

Hooks.InitUser = {
  mounted() {
    addUserConnection(this.el.dataset.userUuid);
  },
  destroyed() {
    removeUserConnection(this.el.dataset.userUuid);
  },
};

Hooks.HandleOfferRequest = {
  mounted() {
    let fromUser = this.el.dataset.fromUserUuid;
    console.log(`new offer request from: ${fromUser}`);
    createPeerConnection(this, fromUser);
  },
};

Hooks.HandleOffer = {
  mounted() {
    let data = this.el.dataset;
    let fromUser = data.fromUserUuid;
    let sdp = data.sdp;

    if (sdp != "") {
      console.log(`new sdp OFFER from: ${fromUser} ${sdp}`);
      createPeerConnection(this, fromUser, sdp);
    }
  },
};
Hooks.HandleAnswer = {
  mounted() {
    let data = this.el.dataset;
    let fromUser = data.fromUserUuid;
    let sdp = data.sdp;
    let peerConn = users[fromUser].peerConn;
    if (sdp != "") {
      console.log(`new sdp ANSWER from: ${fromUser} ${sdp}`);
      peerConn.setRemoteDescription({ type: "answer", sdp });
    }
  },
};

Hooks.HandleIceCandidateOffer = {
  mounted() {
    let data = this.el.dataset;
    let fromUser = data.fromUserUuid;
    let iceCandidate = JSON.parse(data.iceCandidate);
    let peerConn = users[fromUser].peerConn;

    console.log(`new ice candidate from: ${fromUser} ${iceCandidate}`);
    peerConn.addIceCandidate(iceCandidate);
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
