#!/bin/env python

import subprocess
#from collections import namedtuple
from types import SimpleNamespace

smem = subprocess.check_output(["smem", "-c", "command uss pss rss swap"]).decode("UTF-8")
print(smem)
smem = smem.split("\n")


#print(smem)


header = smem[0]
sizes = {}
count = 0
initial = True
for char in header:
    if initial and char == " ":
        initial = False

    if not initial and char != " ":
        sizes[len(sizes)] = count
        initial = True
        #count = 0

    count += 1

print(sizes)

commands = []
usss = []
psss = []
rsss = []
swaps = []
for process in smem[1:]:
    command = process[0:sizes[0]].strip()
    if not command:
        continue
    commands.append(command)
    usss.append(process[sizes[0]:sizes[1]].strip())
    psss.append(process[sizes[1]:sizes[2]].strip())
    rsss.append(process[sizes[2]:sizes[3]].strip())
    swaps.append(process[sizes[3]:].strip())

#print (commands)
#print(usss)
#print(swaps)



#Application = namedtuple('Application', ['name','count', 'uss', 'pss', 'rss', 'swap'])
applications = {}


for i in range(len(commands)):
#for command in commands:
    command = commands[i]
    uss = usss[i]
    pss = psss[i]
    rss = rsss[i]
    swap = swaps[i]

    if command in applications:
        application = applications[command]
        application.count += 1
        application.uss += uss
        application.pss += pss
        application.rss += rss
        application.swap += swap
    else:
        application = SimpleNamespace(count=1, command=command, uss=usss, pss=pss, rss=rss, swap=swap)
        #application = Application(command, 1, uss, pss, rss, swap)
        applications[command] = application

#print (applications.keys())


# class Application:
#     def __init__(self):

