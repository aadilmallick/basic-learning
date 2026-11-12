"""Extracted from lesson 07. See the Markdown chapter for explanation and requirements."""

import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from capstone import load_predictor, predict_rows

model = load_predictor('capstone-model.pt')

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/predict':
            self.send_error(404)
            return
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if length <= 0 or length > 65536:
                raise ValueError('Invalid request length')
            payload = json.loads(self.rfile.read(length))
            rows = payload['rows']
            if not isinstance(rows, list) or len(rows) > 256:
                raise ValueError('Invalid batch')
            predictions = predict_rows(model, rows)
            body = json.dumps({'model_version': 1, 'predictions': predictions}).encode()
        except (ValueError, TypeError, KeyError, OverflowError):
            self.send_error(400, 'Invalid prediction request')
            return
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

if __name__ == '__main__':
    print('Local demo listening on http://127.0.0.1:8000/predict')
    HTTPServer(('127.0.0.1', 8000), Handler).serve_forever()
