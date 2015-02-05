from math import floor
from random import randint

def randMap():
	mapSize = randint(3,15)
	featureGenerator(mapSize)

def featureGenerator(mapSize):
	mS = mapSize
	haz = floor(mapSize*mS/4)
	map = [[0 for i in range(mS)] for j in range(mS)]
	map[0][0] = "start"
	gold = 0
	wumpus = 0
	count = 0

	while not((gold > 0) and (wumpus > 0)):
		x = randint(0,mS-1)
		y = randint(0,mS-1)
		if map[x][y] == 0 and gold == 0 and x != mS-1 and y != mS-1 and x != 0 and y != 0:
			map[x][y] = "gold"
			gold += 1
		if map[x][y] == 0 and wumpus == 0:
			map[x][y] = "wumpus"
			wumpus += 1

	while count < haz:
		x = randint(0,mS-1)
		y = randint(0,mS-1)
		if randint(1,8) % 8 < 5 and map[x][y] == 0:
			map[x][y] = "pit"
			count+=1
	displayMap(mS,map)
	
	while True:
		keepMap = input("Do you wish to keep this map? y:n:enter ")
		if keepMap == "y":
			writeMap(mS,map)
			exit(0)
		elif keepMap == "n":
			exit(0)
		elif keepMap == "":
			featureGenerator(mS)
		else:
			print("Invalid input. ")

def writeMap(mapSize,map):
	fileName = "Wumpus Map " + str(mapSize) + " by " + str(mapSize) + ".txt"
	f = open(fileName, 'w')
	f.write("bounds(1," + str(mapSize) + ").\n")
	f.write("tPanels(" + str(int(floor((mapSize*mapSize)/4))) + ").\n")
	output = ""
	for x in range(mapSize):
		for y in range(mapSize):
			if map[x][y] == "wumpus":
				output += "panel(" + str(x+1) + "," + str(y+1) + ",wumpus).\n"
			elif map[x][y] == "pit":
				output += "panel(" + str(x+1) + "," + str(y+1) + ",pit).\n"
			elif map[x][y] == "start":
				output+= "panel(" + str(x+1) + "," + str(y+1) + ",start).\n"
			elif map[x][y] == "gold":
				output += "panel(" + str(x+1) + "," + str(y+1) + ",gold).\n"
			else:
				pass
	f.write(output)
	f.close()

def displayMap(mapSize,map):
	print("Map Size: " + str(mapSize) + "\n")
	output = ""
	for x in range(mapSize-1,-1,-1):
		for y in range(0,mapSize):
			if map[x][y] == 0:
				output += "[ ]"
			elif map[x][y] == "wumpus":
				output += "[W]"
			elif map[x][y] == "pit":
				output += "[P]"
			elif map[x][y] == "gold":
				output += "[G]"
			elif map[x][y] == "start":
				output += "[S]"
		output+= "\n"
	print(output)

if __name__ == "__main__":
	choice = ""
	while True:
		choice = input("Please enter a map size (integer number) greater than 2 or enter r for a random size map. ")
		if isinstance(choice, int):
			featureGenerator(choice)
		elif choice == "r":
			randMap()
		else:
			print(choice, "is not valid input. ")
