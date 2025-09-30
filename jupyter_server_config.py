# JupyterLab 配置文件
c = get_config()

# 设置默认终端 shell 为 bash
c.ServerApp.terminado_settings = {
    'shell_command': ['/bin/bash', '-i']
}

# 服务访问设置
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = '*'
c.ServerApp.allow_remote_access = True
