import subprocess
import re

result=subprocess.run(["nm","xbinary"],shell=False,stdout=subprocess.PIPE)
symbolsXstr=result.stdout.decode('utf-8')
symbolsX=symbolsXstr.split("\n")
symbolsX = list(filter(None, symbolsX))
symbolsX.pop()
for i, item  in  enumerate(symbolsX):
    symbolsX[i]=re.sub(r'^.*?U _', 'U _', symbolsX[i])
    symbolsX[i]=re.sub(r'^.*?T _', 'T _', symbolsX[i])
    symbolsX[i]=re.sub(r'^.*?S _', 'S _', symbolsX[i])
    symbolsX[i]=re.sub(r'^.*?D _', 'D _', symbolsX[i])


result=subprocess.run(["nm","ybinary"],shell=False,stdout=subprocess.PIPE)
symbolsYstr=result.stdout.decode('utf-8')
symbolsY=symbolsYstr.split("\n")
symbolsY = list(filter(None, symbolsY))
symbolsY.pop()
for i, item  in  enumerate(symbolsY):
    symbolsY[i]=re.sub(r'^.*?U _', 'U _', symbolsY[i])
    symbolsY[i]=re.sub(r'^.*?T _', 'T _', symbolsY[i])
    symbolsY[i]=re.sub(r'^.*?S _', 'S _', symbolsY[i])
    symbolsY[i]=re.sub(r'^.*?D _', 'D _', symbolsY[i])

diff = set(symbolsX) - set(symbolsY)
print(diff)
