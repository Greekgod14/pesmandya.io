import http.server
import socketserver
import os

PORT = 8080
ROOT = os.path.join(os.path.dirname(__file__), 'backend ai', 'cv')

os.chdir(ROOT)

class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

with socketserver.TCPServer(('0.0.0.0', PORT), QuietHandler) as httpd:
    print(f"Serving backend ai/cv at http://127.0.0.1:{PORT}")
    print("Open index.html, market.html, or dashboard.html in your browser.")
    httpd.serve_forever()
