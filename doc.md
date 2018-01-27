1. 用nvm管理nodejs
`curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash`
/usr/local/lib
├── cnpm@5.1.1
├── less@2.7.2
└── tnpm@4.19.9
=> If you wish to uninstall them at a later point (or re-install them under your
=> `nvm` Nodes), you can remove them from the system Node as follows:
'''
     $ nvm use system
     $ npm uninstall -g a_module
'''
=> Close and reopen your terminal to start using nvm or run the following to use it now:

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

2. 安装dva

npm install dva-cli -g
刚开始没有使用-g 全局选项

3. 
