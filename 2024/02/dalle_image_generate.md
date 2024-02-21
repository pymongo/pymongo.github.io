# [dalle画图体验](/2024/02/dalle_image_generate.md)

既然我有一个独享的openai key 我抽空试了下 dall-e-3 调用 api 画图

```python
# https://platform.openai.com/docs/api-reference/images/create
import requests

key='sk-'
body={
    "model": "dall-e-3",
    "prompt": "In a light rainy money on forest Florida state, a personal and photogenic lustrous red eye adult male eastern box turtle come out of his burrow.",
    "n": 1,
    "size": "1024x1024",
    "response_format": "b64_json"
}
#base_url='api.openai.com'
base_url='one-api.xiaobaiteam.com'
url=f"https://{base_url}/v1/images/generations"

r = requests.post(url, json=body, headers={
    "Authorization": f"Bearer {key}",
    "Content-Type": "application/json"
})
if r.status_code != 200:
    print(r.text)
    import sys
    sys.exit(1)

data = r.json()['data'][0]
base64_image = data['b64_json']
revised_prompt = data['revised_prompt']
print(revised_prompt)

import base64
from io import BytesIO
from PIL import Image
image_data = base64.b64decode(base64_image)
image = Image.open(BytesIO(image_data))
image.save('output.png', 'PNG')
```

dalle画出来的有点卡通风那样不真实，我表哥公司业务需要买了midjournay，后来我把同样的 prompt 发给表哥的 midjourney 试试，结果画出来的动物栩栩如生逼真多了
