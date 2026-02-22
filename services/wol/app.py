import os
import socket
import struct
import subprocess

from flask import Flask, jsonify, render_template

app = Flask(__name__)

TARGET_MAC = os.environ.get("WOL_TARGET_MAC", "98:ee:cb:d9:58:40")
TARGET_IP = os.environ.get("WOL_TARGET_IP", "192.168.0.127")
BROADCAST_ADDR = os.environ.get("WOL_BROADCAST", "192.168.0.255")
WOL_PORT = int(os.environ.get("WOL_PORT", "9"))


def build_magic_packet(mac: str) -> bytes:
    mac_bytes = bytes.fromhex(mac.replace(":", "").replace("-", ""))
    return b"\xff" * 6 + mac_bytes * 16


def send_wol(mac: str, broadcast: str, port: int) -> None:
    packet = build_magic_packet(mac)
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        sock.sendto(packet, (broadcast, port))


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/wake", methods=["POST"])
def wake():
    try:
        send_wol(TARGET_MAC, BROADCAST_ADDR, WOL_PORT)
        return jsonify({"success": True, "message": "Magic packet sent"})
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500


@app.route("/status")
def status():
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", "2", TARGET_IP],
            capture_output=True,
            timeout=5,
        )
        online = result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        online = False

    return jsonify({"online": online, "ip": TARGET_IP})
