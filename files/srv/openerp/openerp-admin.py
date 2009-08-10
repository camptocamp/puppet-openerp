#!/usr/bin/env python
# -*- coding: iso-8859-1 -*-
# -*- mode: python; indent-tabs-mode: nil; tab-width: 4 -*-
# vim: set tabstop=2 shiftwidth=2 expandtab:
#

__version__ = '0.1.1'
__author__    = 'Mathieu Bornoz', 'mathieu.bornoz@camptocamp.com'
__date__        = "2008-12-10"

import os
import sys
import glob
import getopt
import ConfigParser
from string import Template
from commands import getstatusoutput

_INSTANCE_ROOT="/srv/openerp/instances"
_BRANCH_FOLDER=['addons','extra-addons','server','webclient']
def error(msg):
    print "[error] %s" % msg
    sys.exit(1)

def execCmd(cmd, msg):
    status, output = getstatusoutput(cmd)
    if status:
        print "%s failed !" % msg
        print output
        sys.exit(1)
    return output

def createDb(name):
    dbname = "%s" % name
    
    if os.system("psql -l |grep -wq %s" % dbname):
        execCmd("createdb --encoding utf8 --owner %s %s" % (dbname, dbname), "create postgres database %s" % dbname)
    else:
        error("%s database already exists" % dbname)
    
def createUserDb(name):
    dbuser = "%s" % name
    password = execCmd("pwgen 8 1", "generate password")
    output = execCmd("psql -c '\du %s' template1" % dbuser, "check if %s user exists" % dbuser)
        
    if "(1 " in output:
        error("%s user already exists" % dbuser)

    if "(0 " in output:
        execCmd("createuser -S -D -l -R %s" % dbuser, "create postgres user %s" % dbuser)
        execCmd("psql -c \"ALTER USER %s WITH PASSWORD '%s';\" template1"    %(dbuser, password), "set password for user %s" % dbuser)
        return password
    
def createInstance(name, branch):
    if not branch:
        error('no argument branch was set')
    port, net_port = getNextTwoFreePort()
    instDir = os.path.join(_INSTANCE_ROOT, name)
    
    if os.path.isdir(instDir):
        error("an instance already exists with name %s" % name)
    
    os.mkdir(instDir)
    os.mkdir(os.path.join(instDir, "log"))
    os.mkdir(os.path.join(instDir, "src"))
    os.mkdir(os.path.join(instDir, "run"))
    os.mkdir(os.path.join(instDir, "database"))

    password = createUserDb(name)
    createDb(name)

    # temporary
    for branchfolder in _BRANCH_FOLDER :
        cmd  = "bzr co %s %s" %(os.path.join(branch,branchfolder),os.path.join(instDir, "src", branchfolder))
        print cmd
        os.system(cmd)

    writeConfig(name, port, net_port, password)

def deleteInstance(name):
    print "dropdb %s" % name
    print "dropuser %s" % name
    print "rm -fR %s/%s" % (_INSTANCE_ROOT, name)

def getLogFilePath(name):
    return "%s/%s/log/server.log" % (_INSTANCE_ROOT, name)

def getConfigPath(name):
    return "%s/%s/instance.ini" % (_INSTANCE_ROOT, name)

def getPidFilePath(name):
    return "%s/%s/run/server.pid" % (_INSTANCE_ROOT, name)

def getServerScript(name):
    return "%s/%s/src/server/bin/openerp-server.py" % (_INSTANCE_ROOT, name)

def writeConfig(name, port, net_port, db_password):
    config = ConfigParser.RawConfigParser()
    config.add_section('Main')
    config.set('Main', 'options', ' --without-demo=all')
    config.set('Main', 'logfile', getLogFilePath(name))
    config.set('Main', 'db_host', 'localhost')
    config.set('Main', 'db_port', '5432')
    config.set('Main', 'db_password', db_password)
    config.set('Main', 'db_user', "%s" % name)
    config.set('Main', 'database', "%s" % name)
    config.set('Main', 'smtp', '')
    config.set('Main', 'net_port', net_port)
    config.set('Main', 'port', port)
    config.set('Main', 'startonboot', 0)

    f = open(getConfigPath(name), 'wb')
    config.write(f)

def getConfig(name):
    config = ConfigParser.ConfigParser()
    config.read(getConfigPath(name))
    return config

def getConfigOption(name, section, option):

    cfg = getConfig(name)
    return cfg.get(section, option)

def getDictConfig(name, section):
    tmpDict = {}
    conf = getConfig(name)
    items = conf.items(section)
    for i in items:
        tmpDict[i[0]] = i[1]
    return tmpDict

def getNextTwoFreePort():
    portList = []
    instances = glob.glob("%s/*" % _INSTANCE_ROOT)
    instances.sort()
    for inst in instances :
        config = ConfigParser.ConfigParser()
        config.read("%s/instances.ini" % instances)
        try :   
            portList.append(config.get('Main', 'port'))
            portList.append(config.get('Main', 'net_port'))
        except :
            config.add_section('Main')
            config.set('Main', 'net_port', 8070)
            config.set('Main', 'port', 8069)
            f = open("%s/instances.ini" % inst, 'wb')
            config.write(f)
        

    if portList == []:
        return 8069, 8070 
    else:
        portList.sort()
        return int(portList[-1])+1, int(portList[-1])+2    

def startInstance(name):
    cfg = getDictConfig(name, 'Main')
    print cfg

    cmdDaemon = "/sbin/start-stop-daemon --start --pidfile %s --background --make-pidfile --exec %s  -- %s"
    cmdDaemonRoot = "/sbin/start-stop-daemon --start --pidfile %s --chuid openerp --background --make-pidfile --exec %s  -- %s"

    openerpArgs = "%(options)s --port=%(port)s "

    if cfg['db_host']:
        openerpArgs += "--db_host=%(db_host)s "

    if cfg['db_password']:
        openerpArgs += "--db_password=%(db_password)s "

    if cfg['db_port']:
        openerpArgs += "--db_port=%(db_port)s "

    openerpArgs += "--logfile=%(logfile)s "
    openerpArgs += "--db_user=%(db_user)s "
    openerpArgs += "--net_port=%(net_port)s --smtp=%(smtp)s"


    if os.getuid() == 0 :
        print '--------------------UID 0----------------------'
        print cmdDaemonRoot %(getPidFilePath(name), getServerScript(name), openerpArgs % cfg)
        os.system(cmdDaemonRoot %(getPidFilePath(name), getServerScript(name), openerpArgs % cfg))
       
    else:
        print '---------------UID other--------------'
        print cmdDaemon %(getPidFilePath(name), getServerScript(name), openerpArgs % cfg)
        os.system(cmdDaemon %(getPidFilePath(name), getServerScript(name), openerpArgs % cfg)),  
        print '------------------------'
    os.system("chown openerp: %s" % getPidFilePath(name))

def stopInstance(name):
    execCmd("/sbin/start-stop-daemon -q --stop --pidfile %s --oknodo" % getPidFilePath(name), "stop instance")
    if os.path.exists(getPidFilePath(name)):
        os.remove(getPidFilePath(name))
    # have to check if there's another fork... strange behaviour we detected.
    output = execCmd('''ps fax | awk '$6 ~ /%s.+openerp/ {print $1}' ''' % name, 'get pid')
    if output:
      execCmd('kill -6 %s'%output, 'really kill %s'%name)

def listInstance():
    print " ", 
    print "NAME".ljust(12), 
    print "PID".ljust(12), 
    print "STATUS".ljust(12), 
    print "BOOTSTART".ljust(12),
    print "PORT".ljust(12),
    print "NETPORT".ljust(12)
    instances = glob.glob("%s/*" % _INSTANCE_ROOT)
    instances.sort()

    for instance in instances:
        name = os.path.basename(instance)

        pid = execCmd('''ps fax | awk '$6 ~ /%s.+openerp/ {print $1}' ''' % name, 'get pid')

        if pid :
            print " ", 
            print name.ljust(12), 
            print str(pid).ljust(12), 
            print "running".ljust(12), 
            print getConfigOption(name, 'Main', 'startonboot').ljust(12),
            print getConfigOption(name, 'Main', 'port').ljust(12),
            print getConfigOption(name, 'Main', 'net_port').ljust(12)
        else:
            print " ", 
            print name.ljust(12), 
            print "---".ljust(12), 
            print "stopped".ljust(12), 
            print getConfigOption(name, 'Main', 'startonboot').ljust(12),
            print getConfigOption(name, 'Main', 'port').ljust(12),
            print getConfigOption(name, 'Main', 'net_port').ljust(12)

def usage(name):
    print "Usage: %s [options]\n" % name
    print "Options:"
    print "     --list"
    print "            List all OpenERP instances"
    print "     --start INSTANCE"
    print "            Start an OpenERP instance "
    print "     --stop INSTANCE"
    print "            Stop an OpenERP instance"
    print "     --create INSTANCE"
    print "            Create the file layout for an OpenERP instance !! the --branch option has to be set before this one"
    print "     --delete INSTANCE"
    print "            Only print out commands"
    print "     -h, --help"
    print "            Display this help and exit"
    print "     --version"
    print "            Print out %s version" % name
    print "     --branch"
    print "            Specifie the checkout branch"
    print 
    sys.exit()

def version(name):
    print "%s v%s"%(name,__version__)
    print "Write by %s, %s\n"%(__author__[0],__author__[1])

def handleOpts(optlist,args, name):
    branch = False
    createname = False
    for output, arg in optlist:
        if output == '--list': listInstance()
        elif output == '--start': startInstance(arg)
        elif output == '--branch': branch = arg
        elif output == '--stop': stopInstance(arg)
        elif output == '--restart': restartInstance(arg)
        elif output == '--create' : createname = arg 
        elif output == '--delete': deleteInstance(arg)
        elif output == '--version': version(name)
        elif output == '--help' : usage(name)
    if createname and not branch :
        error('no argument branch was set')
    if createname and branch :
        createInstance(createname, branch)
    sys.exit()

def checkArgs(argv):
        larg = ['list','start=','stop=', 'restart=', 'create=', 'delete=', 'branch=','help','version']
        sarg = None
        try:
                optlist, args = getopt.getopt(argv[1:], sarg, larg)
        except getopt.GetoptError:
                print "%s: missing argument" % argv[0]
                print "Try %s --help for more information" % argv[0]
                exit(1)

        handleOpts(optlist, args, argv[0])

if __name__=="__main__":
    if len(sys.argv) > 1 : 
        checkArgs(sys.argv)
    else: 
        usage(sys.argv[0])
