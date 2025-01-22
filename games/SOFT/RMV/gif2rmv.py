import sys
from PIL import Image
from PIL import ImageSequence
import os

# RMV file format:
#
# 3 bytes - signature 'RMV'
# 1 bytes - pseudographics type: 'R' for RK-86 2*2 and 'A' for Apogey 3*2 and 'P' for Palmira or Partner 2*3
# 2 bytes - number of frames (little endian)
# 1 byte - frame width in bytes
# 1 byte - frame height in bytes
# 2 byte - frame size in bytes
# 6 bytes - reserved, 0
# frames:
#   binary data

rk, apogey, palmira = range(3)

# Uncomment one of theese lines
#target = rk
#target = apogey
target = palmira

print('img2rmv v. 1.1 (c) Viktor Pykhonin, 2024')

if len(sys.argv) != 2:
  print('Usage img2rmv <source_image>')
  exit()

gif_file = sys.argv[1]
rmv_file = os.path.splitext(sys.argv[1])[0] + '.rmv'

with open(rmv_file, 'wb') as f:

    gif = Image.open(gif_file)

    n_frames = gif.n_frames

    file_header = bytearray()

    if target == rk:
        file_header += b'RMVR'
    elif target == apogey: 
        file_header += b'RMVA'
    else: # target == palmira:
        file_header += b'RMVP'
    
    file_header += int.to_bytes(n_frames, 2, 'little')

    w, h = gif.size

    if target == rk:
        cw = (w + 3) // 4 * 2
        ch = (h + 1) // 2
        new_w = cw * 2
        new_h = ch * 2
    elif target == apogey:
        cw = (w + 5) // 6 * 2
        ch = (h + 1) // 2
        new_w = cw * 3
        new_h = ch * 2
    else: # target == palmira:
        cw = (w + 3) // 4 * 2
        ch = (h + 2) // 3
        new_w = cw * 2
        new_h = ch * 3

    print(f'Source image {w}*{h}, target image {new_w}*{new_h}, {cw}*{ch} bytes')

    resize = new_w != w or new_h != h

    file_header += int.to_bytes(cw, 1, 'little')
    file_header += int.to_bytes(ch, 1, 'little')
    file_header += int.to_bytes(cw * ch, 2, 'little')
    file_header += b'\x00' * 6

    f.write(file_header)

    for img in ImageSequence.Iterator(gif):

        #img = img.resize((128, 64), resample=0)
        img = img.convert('1')

        if resize:
            img = img.crop((0, 0, new_w, new_h))
     
        pixels = img.load()

        bin = bytearray(cw * ch)

        for y in range(ch):
            for x in range(cw):
                if target == rk:
                    bin[y * cw + x] = (pixels[x*2, y*2] & 1) | (pixels[x*2 + 1, y*2] & 2) | (pixels[x*2 + 1, y*2 + 1] & 4) | (pixels[x*2, y*2 + 1] & 0x10)
                elif target == apogey:
                    bin[y * cw + x] = (pixels[x*3, y*2] & 1) | (pixels[x*3 + 1, y*2] & 2) | (pixels[x*3 + 2, y*2] & 4) | \
                                      (pixels[x*3, y*2 + 1] & 0x08) | (pixels[x*3 + 1, y*2 + 1] & 0x10) | (pixels[x*3 + 2, y*2 + 1] & 0x20)
                else: # target == palmira:
                    bin[y * cw + x] = (pixels[x*2, y*3] & 1) | (pixels[x*2 + 1, y*3] & 2) | \
                                      (pixels[x*2, y*3 + 1] & 4) |  (pixels[x*2 + 1, y*3 + 1] & 0x08) | \
                                      (pixels[x*2, y*3 + 2] & 0x10) | (pixels[x*2 + 1, y*3 + 2] & 0x20)
    
        f.write(bin)

    print(f'Written {n_frames} frames to {rmv_file}')
