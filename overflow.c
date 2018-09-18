#include <stdio.h>

int main(int argc, char *argv[])
{
	char buf[100];        		//buffer for 100 characters
	gets(buf);         		//read in buffer, whatever size
	printf("%s\n", buf);       	//print the buffer
	return 0;        		//all good!
}

