import datetime
import re
import os

def sortConjectures(conjListFile, exclude = 'is_3_bootstrappable'):
    conjList = []
    fileLength = 0
    with open(f"{conjListFile}.txt", 'r') as cL:
        for line in cL:
            conjList.append(line)
            fileLength += 1
    getConjName = r"\(([^)([^)]+)\)"
    propertyNames = []
    for i in conjList:
        props = re.findall(getConjName, i)
        for j in props:
            if j not in propertyNames:
                propertyNames.append(j)
    if exclude in propertyNames:
        propertyNames.remove(exclude)
    outputFileName = f"{conjListFile}-sorted.txt"
    file = open(outputFileName, 'w')
    for i in propertyNames:
        conjWithProp = []
        for j in conjList:
            if f"({i})" in j:
                conjWithProp.append(j)
        file.write(f"Property {i} appears {len(conjWithProps)} times in {fileLength} conjectures: \n")
        for k in conjWithProp:
            file.write(k)
        file.write('\n')
    file.close()

def filterConjectures(conjListFile, conjFilter):
    conjList = []
    fileLength = 0
    with open(f"{conjListFile}.txt", 'r') as cL:
        for line in cL:
            conjList.append(line)
            fileLength += 1
    outputFileName = f"{conjListFile}-filtered.txt"
    file = open(outputFileName, 'w')
    for i in conjList:
        if checkConjSubstring(i, conjFilter):
            file.write(i)
    file.close()

def removeDupes(conjListFile):
    input_file = f"{conjListFile}.txt"
    output_file = f"{conjListFile}-unDuped.txt"

    with open(input_file) as input:
        unique = set(line.rstrip('\n') for line in input)
    with open(output_file, 'w') as output:
        for line in unique:
            output.write(line)
            output.write('\n')

def makeConjectureFileName(conjName):
    return f"conjectures/{conjName}-Conjectures"