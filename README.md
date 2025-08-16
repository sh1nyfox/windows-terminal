My Windows Terminal color schemes and settings. Now added basic neovim config file (it's nothing fancy)

To use on your Windows Terminal copy the contents of [settings.json](https://github.com/sh1nyfox/windows-terminal/blob/master/settings.json) into your own terminal.

To use the neovim config, make sure you have the "nvim" folder inside ~/.config and paste the file there. 

![image](https://github.com/sh1nyfox/windows-terminal/blob/master/windows-terminal-july-2025.png)

## Automated setup

In trying to teach myself some things, I've been working on a PowerShell script to apply the PowerShell profile, Windows Terminal settings, install Fastfetch and apply its config, install Starship and apply its config, as well as installing WSL 2 with Fedora 42. 

To run it directly (you can see the code above in the file and I always encourage looking at it) enter the below command into an Admin elevated PowerShell window. The script will check for Admin privileges before it executes, and will stop if it isn't applied.  

```
iwr -Uri "https://raw.githubusercontent.com/sh1nyfox/windows-terminal/refs/heads/master/setup.ps1" | iex
```

Note this is very much still a work in progress and only intended for my own personal settings preferences to be applied. But feel free to use parts to help your own configurations. 

The script doesn't actually work properly at the moment (definitely a WIP) so don't use it. I'm still learning my way through all this stuff! 

The individual configs work fine though when applied manually. 