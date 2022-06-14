# Running Godwoken-Kicker on Windows 11

## Environment

- Windows -  22000.708
- Docker - 20.10.16
- Docker Compose - 2.6.0
- WSL 2 OS - Ubuntu 22.04 LTS

## Install Docker Desktop

First step, install Docker Engine and Docker Compose. We usually just have to install the latest version of [Docker Desktop](https://docs.docker.com/desktop/windows/install/), and then the Docker Engine and the Docker Compose is installed along with it.

After installing the Docker Desktop to the computer, we open it and follow [WSL 2 Setup Instruction](https://docs.docker.com/desktop/windows/wsl/) to set up a WSL 2 running environment. In this process Docker Desktop might need you to restart the computer to set up its VM.

## Install a subsystem

After WSL 2 is installed, let’s go to the **Microsoft Store** to pick and install a Linux subsystem. 

In my case I installed the `Ubuntu 22.04 LTS`, you can go with any subsystem that you preferred, the only difference is that we can have different command-line rules. 

WSL 2 is great, you can view subsystem’s files directly on Windows’ File Explorer, just open `This PC` and then you can find a `Linux` menu on the bottom of the file explorer’s sidebar, click it and all virtual drives of the subsystems are shown.

## Clone Godwoken-Kicker

Now that we have our WSL 2 environment ready, we should clone the `godwoken-kicker` tool to our local environment, and in this part we also have two options to go:

- Clone kicker into Windows’ File System - Good for Windows based developers, but has a few adjustment works to do, otherwise the kicker tool is non-usable
- Clone kicker into WSL 2 subsystem - Good for the kicker tool to execute since maintainers are mostly using macOS or Linux, Windows based developers will need to adapt for a while

## Clone Godwoken-Kicker in Windows’ File System

1. Go to a folder where you store projects, for example `D:/projects`
2. Open a terminal, and then clone the kicker tool into the projects folder
3. Go into the kicker tool’s root folder (for example `D:/projects/godwoken-kicker`), make sure all files in the folder are in `LF` format, if not then: 
   1. run `git config --local core.autocrlf input` to change the git configuration for the project
   2. run `git reset --hard head` to rebuild files so now all files are well-formatted
4. In root folder of the kicker tool, there’s a file called `kicker`, change its filename to `kicker.sh` so Windows Terminal can execute it
5. Open a terminal, run command `./kicker.sh start` to start building a Godwoken Devnet

More friendly tips:

- You might want to go to Windows Terminal’s setting page, then go to Profiles → Defaults → Advanced, find `Profile termination behavior` and set it to `Never close automatically`, this will prevent the kicker tool from closing itself automatically, after its task ends

## Clone Godwoken-Kicker in WSL 2 Subsystem

In this path, the most important task is to connect to Git in the subsystem, and for that we need to set up an SSH key. So we basically have 2 options, pick one you like:

- Use `ssh-keygen` to generate SSH key in subsystem, then add it on GitHub
    
    [How to Use SSH with GitHub (Instead of HTTPS) on Windows WSL](https://simplernerd.com/git-ssh-keys/)
    
- Copy SSH key from Windows to Linux subsystem
    
    [Sharing SSH keys between Windows and WSL 2](https://devblogs.microsoft.com/commandline/sharing-ssh-keys-between-windows-and-wsl-2/)

After that, we can begin to run the kicker tool in our subsystem:

1. Go to the home folder of the current user, for example `/home/<username>`
2. Create a folder to store your projects, for example `~/projects`
3. Go into projects folder, and then clone the kicker tool into the folder
4. Get into the `~/projects/godwoken-kicker` folder, run `./kicker start` command
5. Wait for relevant containers to turn into `Running` status

## While Docker Compose is processing

### LF/CRLF Error
    
If your kicker project is cloned in Windows’ File System, and docker-compose stopped and logged an error while running the command `./kicker.sh start`:

```
exec /var/lib/layer2/entrypoint.sh: no such file or directory 
```

This is most likely because Git assumes that you accept `CRLF` and not `LF` because you’re using Windows.

But actually the kicker tool is running in Unix VM, which does not support `CRLF` at all, so it fails while running the project, naturally. 

In this case you can just reformat all files to `LF` and the problem solved.
    
### Godwoken container runs for too long

While running `kicker start` command, the Godwoken container could run for a long time, and this is totally normal if it doesn't throw any fatal error.
 
As an example, it might take `4 minutes` for the whole `kicker start` command to finish: https://github.com/RetricSu/godwoken-kicker/runs/6824210175?check_suite_focus=true#step:6:2

Depend on different environment, it could be longer or shorter.

Environment of the example:  
- Ubuntu 20.04.4 LTS  
- 2-core CPU  
- 7 GB of RAM memory  
- 14 GB of SSD disk space  

## What next

Try to deploy your contracts using [Hardhat](https://hardhat.org/): [Deploy a simple contract using Hardhat](./hardhat-simple-project.md)