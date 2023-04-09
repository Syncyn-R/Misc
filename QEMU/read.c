#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>
#include <string.h>

static struct termios termattr;

int xoricanon(){
    termattr.c_lflag &= ~ICANON;
    tcsetattr(0, TCSANOW, &termattr);
}

int xorecho(){
//    printf("%d\n",termattr.c_lflag);
//    printf("%d\n",termattr.c_lflag & ECHO);
//    printf("%d\n",ECHO);
    int isecho = termattr.c_lflag & ECHO;
    if(isecho == ECHO){
//	printf("is off\n");
	termattr.c_lflag &= ~ECHO;
    }
    else{
//	printf("is on\n");
	termattr.c_lflag |= ECHO;
    }
    tcsetattr(0, TCSANOW, &termattr);
}

int readchar(){
    int ch;
    while (1) {
        ch = getchar();
	write(1,&ch,1);
    }
}

int main(int argc,char *argv[]){
    tcgetattr(0, &termattr);
    xoricanon();
    if(argc > 1){
    	if(strcmp(argv[1],"echo") == 0){
	    xorecho();
	}
    }else{
        xoricanon();
	xorecho();
        readchar();
    }
}
