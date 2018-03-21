#-*- coding: utf-8 -*-
#version 1.2
from multiprocessing.dummy import Pool as ThreadPool
from multiprocessing import Lock
import os,sys,paramiko
#base var
l_ip=[]
l_arg = sys.argv[1:]
#flag:0(cmd),1(push file),2(push script)
flag = int(l_arg[0])
user = l_arg[1]
code = l_arg[2]
cmd = l_arg[3]
thread_num = int(l_arg[4])
temp_result = l_arg[5]
ip_list = l_arg[6]
remote_path = l_arg[7]
if len(l_arg)==9:
    local_script = l_arg[8]
    script_name = local_script.split('\\')[-1]
    remote_script = remote_path + "/" + script_name
    cmd = "sh " + remote_script
port = 22
#global lock object
def init(locker):
	global lock
	lock = locker
#ssh linux
def winssh(ip):
    try:
        #remote trans file
        if flag == 1:
            trans = paramiko.Transport((ip, port))
            trans.connect(username=user, password=code)
            sftp = paramiko.SFTPClient.from_transport(trans)
            sftp.put(localpath=local_script, remotepath=remote_script)
            lock.acquire()
            f = open(temp_result, 'a')
            f.write(ip + " result:\n")
            f.write("copy " + script_name + " to " + remote_path + " successed.\n")
            f.close()
        #remote execute cmd or script
        else:
            trans = paramiko.Transport((ip, port))
            trans.connect(username=user, password=code)
            if flag == 2:
                sftp = paramiko.SFTPClient.from_transport(trans)
                sftp.put(localpath=local_script, remotepath=remote_script)
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh._transport = trans
            stdin, stdout, stderr = ssh.exec_command(cmd)
            lock.acquire()
            f = open(temp_result, 'a')
            f.write(ip + " result:\n")
            f.write(stdout.read())
            f.close()
    except:
        lock.acquire()
        f = open(temp_result,'a')
        f.write(ip + " result:\n")
        f.write("excute failed\n")
        f.close()
    finally:
        #ssh.close()
        lock.release()
        trans.close()
#script start
if __name__=='__main__':
    lock = Lock()
    pool = ThreadPool(thread_num,initializer=init, initargs=(lock,))
    for ip in open(ip_list):
        if not ip.split():
            continue
        ip = ip.strip('\n')
        l_ip.append(ip)
    result = pool.map_async(winssh,l_ip)
    result.wait()
    #pool.close()
    #pool.join()
    '''for line in open(temp_result):
        print line
    f = open(temp_result, 'w')
    f.close()'''

