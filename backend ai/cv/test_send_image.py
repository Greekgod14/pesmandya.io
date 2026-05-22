from PIL import Image
import io
import requests

# create a simple green image (simulates a healthy leaf)
img = Image.new('RGB', (512, 512), (34,139,34))
buf = io.BytesIO()
img.save(buf, format='JPEG')
buf.seek(0)
files = {'file': ('leaf.jpg', buf, 'image/jpeg')}

resp = requests.post('http://127.0.0.1:8001/cv/analyze', files=files, timeout=120)
print('status:', resp.status_code)
print(resp.text)
