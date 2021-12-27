#!/usr/bin/python3.5
# -*- coding: utf-8 -*-

'''
run using:  python3.5 /PATH/TO/PING-UNSYNCHED.py

purpose:    List and Ping UNSYNCHRONIZED NODES in an Ericsson ENM, valid for
            RBS, ERBS, RadioNode and PICO nodes


Date:       27/12/2021
Author:     MervanA@github
Licesne:    MIT License
'''

# Built-in/Generic Imports
import subprocess
import enmscripting
import time
import re

# Result file time stamp
globalProperties = open("/ericsson/tor/data/global.properties", 'r').read()
enm_short_name = re.search("(?m)PKI_EntityProfile_DN_ORGANIZATION_UNIT=(.*)$", globalProperties).group(1)
timestr = time.strftime("%Y%m%d-%H")
unsyncResultFile = 'UNSYNCHED-PING-{}_{}.txt'.format(enm_short_name, timestr)


# Ping and output function
def ping(nodeName, nodeType, nodeIp, ossPrefix):
    try:
        subprocess.check_output(["ping", "-c", "1", str(nodeIp)])
        result = True
    except subprocess.CalledProcessError:
        result = False
    with open(unsyncResultFile, 'a') as f:
        print('{0:10}{1:11}{2:16}{3:7}{4}'.format(str(nodeName), str(nodeType), str(nodeIp), str(result), str(ossPrefix)))
        if result is True:
            f.write('{0} {1} {2} {3}\n'.format(str(nodeName), str(nodeType), str(nodeIp), str(ossPrefix)))


# List all UNSYNCHRONIZED nodes in ENM
def getUnsyncList():
    global nodeList
    nodeList = []
    session = enmscripting.open()
    command = 'cmedit get * CmFunction.(syncStatus=="UNSYNCHRONIZED") --table'
    cmd = session.command()
    response = cmd.execute(command)
    for line in response.get_output().groups()[0]:
        nodeList.append(line[0])
    enmscripting.close(session)


# Get RBS, ERBS, RadioNode and MSRBS_1(PICO) nodes OAM IP address and run ping
def getNodeIp(nodeName, nodeType, ossPrefix):
    global nodeIp
    session = enmscripting.open()
    if str(nodeType) == 'RBS' or str(nodeType) == 'ERBS':
        command = 'cmedit get NetworkElement={},CppConnectivityInformation=1 --table'.format(str(nodeName))
        response = session.command().execute(command)
        for line in response.get_output().groups()[0]:
            nodeIp = str(line[4])
            ping(nodeName, nodeType, nodeIp, ossPrefix)
    elif str(nodeType) == 'RadioNode' or str(nodeType) == 'MSRBS_V1':
        command = 'cmedit get NetworkElement={},ComConnectivityInformation=1 --table'.format(str(nodeName))
        response = session.command().execute(command)
        for line in response.get_output().groups()[0]:
            nodeIp = str(line[4])
            ping(nodeName, nodeType, nodeIp, ossPrefix)
    enmscripting.close(session)


# Get UNSYNCHRONIZED node info and run getNodeIp function
def getNodeInfo():
    session = enmscripting.open()
    for node in nodeList:
        command = 'cmedit get NetworkElement={} --attribute neType,ossPrefix --table'.format(node)
        response = session.command().execute(command)
        for line in response.get_output().groups()[0]:
            nodeName = line[0]
            nodeType = line[1]
            ossPrefix = line[2]
            ossPrefix = re.sub(r',MeContext=.*', '', str(ossPrefix))
            getNodeIp(nodeName, nodeType, ossPrefix)
    enmscripting.close(session)
    with open(unsyncResultFile, '+r') as f:
        lines = f.readlines()
        lines.sort()
        f.seek(0)
        f.write('{0} {1} {2} {3}\n'.format('NODE_NAME', 'NODE_TYPE', 'NODE_IP', 'OSS_PREFIX'))
        for line in lines:
            f.write(line)


# RUNNING TIME
getUnsyncList()
getNodeInfo()
