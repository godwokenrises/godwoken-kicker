# Running Godwoken-Kicker on Windows 11

## Why you need the article

If you're a Windows-based developer, you might run into trouble trying to run Godwoken-Kicker on Windows, that's why we're bringing you this specific article as a guide. For example, you may encounter this error when Docker Compose is running: `exec /var/lib/layer2/entrypoint.sh: no such file or directory`, which we will get into the details of this error later.

You can follow the steps in the article, to install WSL 2 to our system, and run Godwoken-Kicker on it. Or if you have already installed WSL 2 and know what to do, you can use the article as a troubleshooting guide and visit it if you run into trouble.

## Environment

- Windows -  22000.708
- Docker - 20.10.16
- Docker Compose - 2.6.0
- WSL 2 OS - Ubuntu 22.04 LTS

----

## Install Docker Desktop

First step, install Docker Engine and Docker Compose. We usually just have to install the latest version of [Docker Desktop](https://docs.docker.com/desktop/windows/install/), and then the Docker Engine and the Docker Compose is installed along with it.

After installing the Docker Desktop to the computer, we open it and follow [WSL 2 Setup Instruction](https://docs.docker.com/desktop/windows/wsl/) to set up a WSL 2 running environment. In this process Docker Desktop might need you to restart the computer to set up its VM.

## Install a subsystem

After WSL 2 is installed, let’s go to the **Microsoft Store** to pick and install a Linux subsystem. 

In my case I installed the `Ubuntu 22.04 LTS`, you can go with any subsystem that you preferred, the only difference is that we can have different command-line rules. 

WSL 2 is great, you can view subsystem’s files directly on Windows’ File Explorer, just open `This PC` and then you can find a `Linux` menu on the bottom of the file explorer’s sidebar, click it and all virtual drives of the subsystems are shown.

## Clone Godwoken-Kicker

Now that we have WSL 2 environment ready, we should clone the `godwoken-kicker` tool to our local environment and start running it. You can follow the commands below to do this:

1. `cd /home/<username>` - go to the home folder of the current user
2. `mkdir projects` - create a folder to store your projects
3. `cd projects` - go to the projects folder
4. `git clone https://github.com/RetricSu/godwoken-kicker` - clone the godwoken-kicker tool
5. `cd godwoken-kicker` - go to the godwoken-kicker folder
6. `./kicker start` - start the local network (devnet)

## While Docker Compose is processing

### LF/CRLF Error
    
If docker-compose stopped and logged this error while running the command `./kicker.sh start`:

```
exec /var/lib/layer2/entrypoint.sh: no such file or directory 
```

This is most likely because Git assumes you accept line separator as `CRLF` instead of `LF` since you’re on Windows, but actually the kicker tool is running in a Unix VM, which does not support `CRLF` at all, so the program fails while running, naturally. 

In this case you can just reformat the line separator for each file to `LF` in the project and the problem solved. You can find the setting for line separator in the bottom-right corner of most IDEs.
    
### Godwoken container runs for too long

While running `kicker start` command, the Godwoken container could run for a long time, and this is totally normal if it doesn't throw any fatal error.
 
As an example, it might take `4 minutes` for the whole `kicker start` command to finish (depend on different environment, it could be longer or shorter):
https://github.com/RetricSu/godwoken-kicker/runs/6824210175?check_suite_focus=true#step:6:2

Environment of the example:  
- Ubuntu 20.04.4 LTS  
- 2-core CPU  
- 7 GB of RAM memory  
- 14 GB of SSD disk space  

## What next

Try to deploy your contracts using [Hardhat](https://hardhat.org/): [Deploy a simple contract using Hardhat](./hardhat-simple-project.md)