#!/usr/bin/env python3
import os
import sys

instruFile = "process.conf"
configFile = "setup.conf"
error_File = "error.txt"

instruFileLineNo_total = 0
instruFileLinesNo_current = 0

configFileLineNo_total = 0
configFileLinesNo_current = 0



def initialize():
	
	#Initializing variables
	global instruFileLineNo_total
	global instruFileLinesNo_current
	global configFileLineNo_total
	global configFileLinesNo_current

	#Dictionarys used to store category line numbers
	configDict = {}
	instruDict = {}
	runFromTo  = []
	
	#if user is not root...kick them out of program
	if not os.geteuid()==0:
		sys.exit("\nMust be using a root user account in order to run this script.\n")
		
	print("\n\nBefore running this script, make sure this pc has access to a stable internet connection.\n")
	input("Press Enter to continue...")

	#Open config file and store all category line numbers
	configFileTxt = open(configFile, "r")
	configFileLines = configFileTxt.readlines()
	congigFileLineNo_total = len(configFileLines)
	
	for line in configFileLines:
		if line[0] == '[':
			category = findBetween(line, '[', ']')
			if category == "fail":
				print ("\nError: Improper category name in config file: line " + str(configFileLinesNo_current) + "\n")
				exit()
			else:
				configDict[category] = configFileLinesNo_current
		else:
			pass
				
		configFileLinesNo_current += 1
		
	#Open instruction file and store all category line numbers
	instruFileTxt = open(instruFile, "r")
	instruFileLines = instruFileTxt.readlines()
	instruFileLineNo_total = len(instruFileLines)
	
	for line in instruFileLines:
		if line[0] == '$':
			category = findBetween(line, '[', ']')
			if category == "fail":
				print ("\nError: Improper category name in instruction file: line " + str(instruFileLinesNo_current) + "\n")
				exit()
			else:
				instruDict[category] = instruFileLinesNo_current
		else:
			pass
				
		instruFileLinesNo_current += 1
	
	#Use arguments to determine actions
	if(len(sys.argv)==1 or sys.argv[1] == "post-install"):
		installer("post-install", configFileLines, instruFileLines, configDict, instruDict)	
	elif(sys.argv[1] == "install"):
		installer("install", configFileLines, instruFileLines, configDict, instruDict)	
	
	else:
		found = False
		for element in instruDict:
			if(sys.argv[1] == element):
				installer(element, configFileLines, instruFileLines, configDict, instruDict)
				found = True
		if found == False:
			print ("\nError: Unable to find Category\n")
			exit()

	print("\nInstallation of programs complete!\n")
	configFileTxt.close()
	instruFileTxt.close()
	exit()



def installer(action, configFileLines, instruFileLines, configDict, instruDict):
	
	#Initializing variables
	global instruFileLineNo_total
	global instruFileLinesNo_current
	global configFileLineNo_total
	global configFileLinesNo_current
	
	#Keeping track of current category & state
	currentCategory = ""
	instruFileLinesNo_current = 0
	configFileLinesNo_current = 0
	error = False

	#Delete and recreate error text file
	if os.path.isfile(error_File): 
		os.system("rm " + error_File)
	os.system("echo ERROR.TXT > " + error_File)
	with open(error_File, "a") as errorFileTxt:

		#Read instructions line by line
		for instruction in instruFileLines:
		
			#Refresh variables
			flags = ""
			data  = ""
			
			#Save subject name to variable 'categoryName'
			if instruction[0:3] == "$--":
				currentCategory = str(findBetween(instruction, '[', ']'))
			
			elif instruction[0] == '[':
				
				if action == "install" and currentCategory == "INSTALL_OS":
					result = parse_Files(instruction, currentCategory, configFileLines, instruFileLines, configDict, instruDict, errorFileTxt)
					if result == "fail":
						error = True
				
				if action ==  "post-install" and currentCategory != "INSTALL_OS":
					result = parse_Files(instruction, currentCategory, configFileLines, instruFileLines, configDict, instruDict, errorFileTxt)
					if result == "fail":
						error = True
				
				if currentCategory == action:
					result = parse_Files(instruction, currentCategory, configFileLines, instruFileLines, configDict, instruDict, errorFileTxt)
					if result == "fail":
						error = True
				
			#Ignore instruction if it starts with '#' and empty lines
			elif instruction[0] == "#" or not instruction.strip():
				pass
				
			#Generate error if improper syntax found
			else:
				errorFileTxt.write("Error: Improper command at line: " + str(instruFileLinesNo_current + 1) + "\n")
				error = True
		
			#Keep count of current line in scriptFile
			instruFileLinesNo_current += 1

	errorFileTxt.close()
	
	if error == False:
		print("\nInstallation of programs complete, No errors detected!\n")
	if error == True:
		print("\nErrors occured during installation, please check error log!\n")
	
	
	
def parse_Files(instruction, currentCategory, configFileLines, instruFileLines, configDict, instruDict, errorFileTxt):

	#Initializing variables
	global instruFileLineNo_total
	global instruFileLinesNo_current
	global configFileLineNo_total
	global configFileLinesNo_current
	
	#Program State
	program_state = "pass"
	
	flags = findBetween(instruction, '[', ']').split(':')
	data  = instruction.split(']',1)[1]

	#Act on flag instruction
	if(len(flags)) == 1:
		result = systemCommands(flags[0], data)
		if result == "fail":
			errorFileTxt.write("Error: Issue running command: " + str(instruFileLinesNo_current + 1) + "\n")
			return "error"
		else:
			return "pass"
					
	# Use config dictionary to find config setting, then act on presented setting.			
	elif(len(flags) == 2):
		configFileLinesNo_current = configDict[currentCategory] + 1
		value = ""
		
		while configFileLines[configFileLinesNo_current][0] != '[':
			readLine = configFileLines[configFileLinesNo_current]
			
			if(readLine[0] == '#' or not readLine.strip()):
				pass
			elif(flags[0] == findBetween(readLine, '', '(')):
				value = str(findBetween(readLine, '=', '\n')).replace(" ", "")
				if value.lower() == "y" or value.lower() == "yes" or value.lower() == "true":
					result = systemCommands(flags[1], data)
					if result == "fail":
						errorFileTxt.write("Error: Issue running command: " + str(instruFileLinesNo_current + 1) + "\n")
						return "error"
					else:
						return "pass"
			else:
				pass
				
			configFileLinesNo_current += 1

	# Use config dictionary to find config setting, then act on presented setting.			
	elif(len(flags) == 3):
		configFileLinesNo_current = configDict[currentCategory] + 1
		value = ""
		
		while configFileLines[configFileLinesNo_current][0] != '[':
			readLine = configFileLines[configFileLinesNo_current]
			
			if(readLine[0] == '#' or not readLine.strip()):
				pass
			elif(flags[0] == findBetween(readLine, '', '(')):
				value = str(findBetween(readLine, '=', '\n')).replace(" ", "")
				if value == flags[1]:
					result = systemCommands(flags[2], data)
					if result == "fail":
						errorFileTxt.write("Error: Issue running command: " + str(instruFileLinesNo_current + 1) + "\n")
						return "error"
					else:
						return "pass"
			else:
				pass
			
			configFileLinesNo_current += 1
			
	# Too many arguments presented in instruction.
	else:
		errorFileTxt.write("Error: Too many arguments presented: " + str(instruFileLinesNo_current + 1) + "\n")
		return "error"

################################################################################
# 	findBetween (string, string, string)
#
#	This function takes 3 inputs and from there extracts a piece of the inital
#	string in between the two additional symbols provided.
################################################################################
def findBetween(string, initialSymbol, finalSymbol): 
	try:
		start = string.index(initialSymbol) + len(initialSymbol)
		end = string.index(finalSymbol, start)
		return string[start:end]
	except ValueError:
		message = "Error: Unable to find value"
		print ("\n" + message + ": line " + str(instruFileLinesNo_current + 1)  + "\n")
		return "fail"

################################################################################
# 	systemCommands (string, string)
#
#	This function takes 2 inputs relating to what action the user wants done
#	along with data related to that action and act on them using the linux 
#	command line.
################################################################################
def systemCommands(action, data):

	#Run data as command
	if action == "command":
		log = os.system(data)
	#Refresh repos
	elif action == "refresh":
		print("recieved")
		log = os.system("pacman -Syy")
	#Update system
	elif action == "update":
		log = os.system("pacman -Syu")
	#Install listed packages
	elif action == "install":
		log = os.system("pacman -S --noconfirm " + data)
	#Uninstall listed packages
	elif action == "uninstall":
		log = os.system("pacman -Rns --noconfirm " + data)
	#Start deamon
	elif action == "start_demon":
		log = os.system("systemctl start " + data)
	#Stop deamon
	elif action == "stop_demon":
		log = os.system("systemctl stop " + data)
	#Enable deamon
	elif action == "enable_demon":
		log = os.system("systemctl enable " + data)
	#Disable deamon
	elif action == "disable_demon":
		log = os.system("systemctl disable " + data)
	#Move object
	elif action == "move":
		log = os.system("mv " + data)
	#Copy object
	elif action == "copy":
		log = os.system("cp " + data)
	#Delete file
	elif action == "delete":
		log = os.system("rm -r " + data)	
	#If action not on list return error
	else:
		message = "Error: Command not recognized"
		print ("\n" + message + ": line " + str(instruFileLinesNo_current + 1) + "\n")
		return "fail"
		
	#Return Results
	if log != 0:
		message = "Error: Issues running command"
		print ("\n" + message + ": line " + str(instruFileLinesNo_current + 1) + "\n")
		return "fail"
	else:
		return "pass"

		
################################################################################
# 	Start main program.
################################################################################		
if __name__ == '__main__':
	initialize()
