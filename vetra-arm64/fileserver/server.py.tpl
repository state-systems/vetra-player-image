#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os
import json
import mimetypes
import re

class CORSRequestHandler(SimpleHTTPRequestHandler):
    streaming_extensions = {
        '.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v',
        '.mp3', '.wav', '.ogg', '.m4a', '.aac', '.flac', '.wma'
    }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='/mnt/vetra/dev', **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '<PLAYER_URL>')
        self.send_header('Access-Control-Allow-Headers', 'Range')
        super().end_headers()
    
    def do_OPTIONS(self):
        """Handle preflight CORS requests"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Methods', 'GET, HEAD, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Range, Content-Type')
        self.end_headers()
    
    def do_HEAD(self):
        """Handle HEAD requests for media files"""
        path = self.path.split('?')[0]
        file_extension = os.path.splitext(path.lower())[1]
        
        if file_extension in self.streaming_extensions:
            try:
                file_path = self.translate_path(path)
                if os.path.exists(file_path) and os.path.isfile(file_path):
                    file_size = os.path.getsize(file_path)
                    mime_type, _ = mimetypes.guess_type(file_path)
                    if not mime_type:
                        mime_type = 'application/octet-stream'
                    
                    self.send_response(200)
                    self.send_header('Content-Type', mime_type)
                    self.send_header('Content-Length', str(file_size))
                    self.send_header('Accept-Ranges', 'bytes')
                    self.end_headers()
                else:
                    self.send_error(404, "File not found")
            except Exception as e:
                self.send_error(500, f"Error handling HEAD request: {str(e)}")
        else:
            super().do_HEAD()
    
    def do_GET(self):
        # Parse the path and remove query parameters
        path = self.path.split('?')[0]
        
        # If requesting root path, return JSON file listing
        if path == '/':
            self.send_json_listing()
        else:
            # Check if this is a media file that should support streaming
            file_extension = os.path.splitext(path.lower())[1]
            if file_extension in self.streaming_extensions:
                self.serve_media_file(path)
            else:
                # For all other paths, use the default file serving behavior
                super().do_GET()
    
    def serve_media_file(self, path):
        """Serve media files with HTTP range support for streaming"""
        try:
            # Convert URL path to file path
            file_path = self.translate_path(path)
            
            # Check if file exists and is readable
            if not os.path.exists(file_path) or not os.path.isfile(file_path):
                self.send_error(404, "File not found")
                return
            
            file_size = os.path.getsize(file_path)
            
            mime_type, _ = mimetypes.guess_type(file_path)
            if not mime_type:
                mime_type = 'application/octet-stream'
            
            # Check for Range header
            range_header = self.headers.get('Range')
            
            if range_header:
                # Parse Range header (e.g., "bytes=0-1023" or "bytes=1024-")
                range_match = re.match(r'bytes=(\d+)-(\d*)', range_header)
                if range_match:
                    start = int(range_match.group(1))
                    end = int(range_match.group(2)) if range_match.group(2) else file_size - 1
                    
                    # Ensure valid range
                    if start >= file_size:
                        self.send_error(416, "Range Not Satisfiable")
                        return
                    
                    if end >= file_size:
                        end = file_size - 1
                    
                    content_length = end - start + 1
                    
                    # Send partial content response
                    self.send_response(206)  # Partial Content
                    self.send_header('Content-Type', mime_type)
                    self.send_header('Content-Length', str(content_length))
                    self.send_header('Content-Range', f'bytes {start}-{end}/{file_size}')
                    self.send_header('Accept-Ranges', 'bytes')
                    self.end_headers()
                    
                    # Send the requested range
                    with open(file_path, 'rb') as f:
                        f.seek(start)
                        remaining = content_length
                        while remaining > 0:
                            chunk_size = min(8192, remaining)  # 8KB chunks
                            chunk = f.read(chunk_size)
                            if not chunk:
                                break
                            self.wfile.write(chunk)
                            remaining -= len(chunk)
                else:
                    # Invalid range format
                    self.send_error(400, "Bad Request - Invalid Range")
                    return
            else:
                # No range header, send entire file
                self.send_response(200)
                self.send_header('Content-Type', mime_type)
                self.send_header('Content-Length', str(file_size))
                self.send_header('Accept-Ranges', 'bytes')
                self.end_headers()
                
                # Send entire file in chunks
                with open(file_path, 'rb') as f:
                    while True:
                        chunk = f.read(8192)  # 8KB chunks
                        if not chunk:
                            break
                        self.wfile.write(chunk)
                        
        except Exception as e:
            self.send_error(500, f"Error serving media file: {str(e)}")
    
    def send_json_listing(self):
        """Send JSON response with file listing"""
        try:
            # Get the directory we're serving
            directory = '/mnt/vetra/dev'
            
            # Check if directory exists
            if not os.path.exists(directory):
                self.send_error(404, "Directory not found")
                return
            
            files = []
            
            # Recursively walk through all directories and subdirectories
            for root, dirs, filenames in os.walk(directory):
                # Filter out hidden directories (starting with dot) from further traversal
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                
                for filename in filenames:
                    # Skip hidden files (starting with dot)
                    if filename.startswith('.'):
                        continue
                        
                    file_path = os.path.join(root, filename)
                    
                    try:
                        stat = os.stat(file_path)
                        
                        # Get relative path from the base directory
                        relative_path = os.path.relpath(file_path, directory)
                        
                        # Try to get MIME type
                        mime_type, _ = mimetypes.guess_type(file_path)
                        file_type = mime_type if mime_type else "application/octet-stream"
                        
                        files.append({
                            "filename": relative_path,
                            "type": file_type,
                            "size": stat.st_size
                        })
                    
                    except (OSError, IOError):
                        # Skip files we can't access
                        continue
            
            # Sort files by relative path
            files.sort(key=lambda x: x['filename'].lower())
            
            # Send JSON response
            response = {
                "directory": directory,
                "files": files,
                "total_files": len(files)
            }
            
            json_data = json.dumps(response, indent=2)
            
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Content-Length', str(len(json_data.encode('utf-8'))))
            self.end_headers()
            self.wfile.write(json_data.encode('utf-8'))
            
        except Exception as e:
            self.send_error(500, f"Error listing directory: {str(e)}")

if __name__ == '__main__':
    server_address = ('127.0.0.1', 8000)
    httpd = HTTPServer(server_address, CORSRequestHandler)
    print(f"Serving on http://{server_address[0]}:{server_address[1]}")
    httpd.serve_forever()