# autowork
autowork自动化运维工具是用powershell studio编写的图形化服务器集中管理工具，支持远程操作windows服务器和Linux服务器，其中Linux的ip组功能是用python的paramiko实现。autowork无需任何客户端就能非常方便地对大批量的服务器进行远程操作，文件推送，远程推送执行脚本，网络策略测试，自动化部署web站点，自动化上线回退等功能，用户所有操作记录均会写入日志文件，提供日志审计排障功能。<br>
autowork的使用的权限是windows登陆用户的权限，推荐在域环境下使用。目前工具只能单用户操作，当有人在使用时，其他用户启动程序会提示“已有用户登录”并退出。因为工具绝大部分功能都是用powershell实现，运行本程序的主机需要先开启本机powershell脚本执行策略。被操作的远程windows主机只需要能连通445端口即可，被操作的远程linux主机需要能连通22端口。<br>
autowork操作界面分为三大区域：目标区域、功能区域和结果区域。该工具测试过批量更新600+的服务器zabbix agent，只有10台左右的服务器出现更新失败的情况，在操作大量服务器时非常便利。更多的使用帮助请见resource目录的help文档。<br>

工具操作界面如下：<br>
![](https://github.com/qwsddn/autowork/blob/master/raw/windows.jpg)<br>
![](https://github.com/qwsddn/autowork/blob/master/raw/linux.jpg)<br>
![](https://github.com/qwsddn/autowork/blob/master/raw/netpolicy.jpg)<br>
![](https://github.com/qwsddn/autowork/blob/master/raw/win_website.jpg)<br>
![](https://github.com/qwsddn/autowork/blob/master/raw/win_update.jpg)<br>
![](https://github.com/qwsddn/autowork/blob/master/raw/win_rollback.jpg)

工具版本历程<br>
2017.7.11,autowork 1.0发布<br>
2017.8.31,autowork 1.1发布<br>
建web站点结果写入日志<br>
修复ctrl-c和ctrl-v无法使用的bug<br>
修复回退功能无先删除程序目录的bug<br>
增加ip组多线程建站、更新、回退功能更新功能<br>
增加更新源目录含config配置文件也能够更新<br>
windows运维部分:各种功能都增加ip组和多线程功能（获取服务和查看应用目录不支持）<br>
增加ip组推送执行脚本返回结果功能（在参数1填入result即可实现）<br>
增加服务重启，设置服务自动，手动，禁用功能，并修复操作带空格服务名会出错的bug（如：zabbix agent这种服务名）<br>
增加通过ip获取主机名功能<br>
增加检查本地到远端服务器445连通性检查功能<br>
2017.9.12,autowork 1.2发布<br>
linux改写了功能实现选项<br>
linux增加是否记录账号密码<br>
linux增加传压缩文件包到远程服务器<br>
linux用python的paramiko和multiprocessing.dummy模块实现ip组多线程功能<br>
