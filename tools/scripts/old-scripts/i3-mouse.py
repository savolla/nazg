#!/usr/bin/python

import keyboard as k
import pyautogui as p
import time

wait_time = 0.05
step_interval = 25
jump = 250

while True:
	x,y = p.position()
	time.sleep(wait_time)

	# fast movement
	if (k.is_pressed("ctrl+shift+up")):
		p.moveTo(x ,y - step_interval - jump )	

	elif (k.is_pressed("ctrl+shift+down")):
		p.moveTo(x ,y + step_interval+jump )

	elif (k.is_pressed("ctrl+shift+left")):
		p.moveTo(x - step_interval-jump ,y )

	elif (k.is_pressed("ctrl+shift+right")):
		p.moveTo(x + step_interval+jump,y )

	# streight movement
	elif (k.is_pressed("ctrl+up")):
		p.moveTo(x ,y - step_interval )	

	elif (k.is_pressed("ctrl+down")):
		p.moveTo(x ,y + step_interval )

	elif (k.is_pressed("ctrl+left")):
		p.moveTo(x - step_interval ,y )

	elif (k.is_pressed("ctrl+right")):
		p.moveTo(x + step_interval,y )

	elif (k.is_pressed("ctrl+shift+f12")):
		p.click(button="right")

	elif (k.is_pressed("ctrl+f12")):
		p.click()

