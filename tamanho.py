import PIL
from PIL import Image
from os import listdir
from os.path import isfile, join
onlyfiles = [f for f in listdir("Imagens") if isfile(join("Imagens", f))]
lowest = 1000
    
for i in onlyfiles:
    print(i)
    image = PIL.Image.open("Imagens/" + i)

    width, height = image.size

    print(width, height,"\n --------------")
    if width < lowest:
        lowest = width


print("\n lowest = ", lowest)



