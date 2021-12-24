#!/usr/bin/python3.5
# -*- coding: utf-8 -*-

'''
run using:  python3 /PATH/TO/unsyncPing.py

purpose:    List and Ping UNSYNCHRONIZED NODES in an Ericsson ENM, valid for
            RBS, ERBS, RadioNode and PICO nodes


Date:       24/12/2021
Author:     MervanA@github
Licesne:    MIT License
'''

# Built-in/Generic Imports
import subprocess
import enmscripting
import time


# Result file time stamp
timestr = time.strftime("%Y%m%d-%H")
unsyncResultFile = 'unsyncNodePing_{}.txt'.format(timestr)


# Ping and output function
def ping(nodeName, nodeType, nodeIp):
    try:
        subprocess.check_output(["ping", "-c", "1", str(nodeIp)])
        result = True
    except subprocess.CalledProcessError:
        result = False
    with open(unsyncResultFile, 'a') as f:
        print('{0:10}{1:11}{2:16}{3}'.format(str(nodeName), str(nodeType), str(nodeIp), str(result)))
        f.write('{0:10}{1:11}{2:16}{3}\n'.format(str(nodeName), str(nodeType), str(nodeIp), str(result)))


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
def pingNodeIp(nodeName, nodeType):
    global nodeIp
    session = enmscripting.open()
    if str(nodeType) == 'RBS' or str(nodeType) == 'ERBS':
        command = 'cmedit get NetworkElement=' + str(nodeName) + ',CppConnectivityInformation=1 --table'
        response = session.command().execute(command)
        for line in response.get_output().groups()[0]:
            nodeIp = str(line[4])
            ping(nodeName, nodeType, nodeIp)
    elif str(nodeType) == 'RadioNode' or str(nodeType) == 'MSRBS_V1':
        command = 'cmedit get NetworkElement=' + str(nodeName) + ',ComConnectivityInformation=1 --table'
        response = session.command().execute(command)
        for line in response.get_output().groups()[0]:
            nodeIp = str(line[4])
            ping(nodeName, nodeType, nodeIp)
    enmscripting.close(session)


# Get UNSYNCHRONIZED node info and run pingNodeIp function
def getNodeInfo():
    session = enmscripting.open()
    for node in nodeList:
        command = 'cmedit get NetworkElement=' + str(node) + ' --attribute neType --table'
        response = session.command().execute(command)
        for line in response.get_output().groups()[0]:
            nodeName = line[0]
            nodeType = line[1]
            pingNodeIp(nodeName, nodeType)
    enmscripting.close(session)


# RUNNING TIME
getUnsyncList()
getNodeInfo()
