# Toralizer
Toralizer is a compact tool written in C that facilitates anonymous web browsing by routing your connections through the Tor network. Designed with simplicity and privacy in mind, it allows you to establish secure tunnels with a single command. It's perfect for privacy-conscious users and developers looking to seamlessly integrate anonymous browsing into their workflows. Upcoming updates will feature hostname support, enhancing its capabilities even more.

## Features
```bash
1. Lightweight C written code
2. Simply written using SOCKS4
3. Secure request using TOR Proxy Server
4. Upcoming: hostname resolution for additional flexibility
```

## Installation
1. Cloning Repository
   ```bash
   git clone github.com/president-xd/toralize.git
   ```
2. Change the directory
   ```bash
    cd toralize
   ```
3. Running the Script
   ```bash
    sudo chmod +x setup.sh
    ./setup.sh
   ```
4. Ready to Go Now!!
   ```bash
    toralize execute-command
   ```
   Example:
   ```bash
    toralize curl google.com
   ```
### Note: 
The TOR service should be turned on before using toralize command, so the toralize carry your request through TOR proxy server.
