import re
import os

def sortConjectures(conjListFile):
    conjList = []
    fileLength = 0
    with open('{}.txt'.format(conjListFile), 'r') as cL:
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
    if 'is_2_bootstrap_good' in propertyNames:
        propertyNames.remove('is_2_bootstrap_good')
    outputFileName = '{}-sorted.txt'.format(conjListFile)
    file = open(outputFileName, 'w')
    for i in propertyNames:
        conjWithProp = []
        for j in conjList:
            if '({})'.format(i) in j:
                conjWithProp.append(j)
        file.write('Property {} appears {} times in {} conjectures: \n'.format(i, len(conjWithProp), fileLength))
        for k in conjWithProp:
            file.write(k)
        file.write('\n')
    file.close()

def filterConjectures(conjListFile, conjFilter):
    conjList = []
    fileLength = 0
    with open('{}.txt'.format(conjListFile), 'r') as cL:
        for line in cL:
            conjList.append(line)
            fileLength += 1
    outputFileName = '{}-filtered.txt'.format(conjListFile)
    file = open(outputFileName, 'w')
    for i in conjList:
        if checkConjSubstring(i, conjFilter):
            file.write(i)
    file.close()

    
# def checkConjSubstring(conj, conjFilter):
#     for i in conjFilter:
#         if conj in i:
#             return False
#     return True

# def conjConcat(fileNames, outputFileName):
#     with open(outputFileName, 'w') as outfile:
#     for fname in filenames:
#         with open(fname) as infile:
#             outfile.write(infile.read())
#             infile.close()
#     outfile.close()