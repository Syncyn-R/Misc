import os,threading

def runffmpeg(File):
    os.system("ffmpeg -i " + File + " -c:v nvenc -c:a copy -b:a 320k -b:v 10M " + File.split(".")[0] + ".mp4 -y")

def main():
    Files = os.listdir()
    for File in Files:
        #if(File != __file__): #某啥b要の兼容性,暂时弃用
        if(File != os.path.basename(__file__)) & (File.split(".")[-1] == "MOV"): 
            #thread = threading.Thread(target=runffmpeg,args=(File,))
            #thread.start()
            runffmpeg(File)

main()