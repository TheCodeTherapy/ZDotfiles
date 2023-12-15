# ZDotfiles

## The **ULTIMATE** Desktop Experience for a Developer / Gamer / Heavy User / Nerd like me on Ubuntu 22.04 LTS 😁
---

<img src="https://mgz.me/publicfiles/images/dotfiles.gif?raw=true" width="800" height="450">

<br>

## **Why**?

After adding a NAS on my home network, reinstalling an operating system without worrying about backing up data became an incredibly easy and fast task (literally about 20 minutes while having a coffee). The only thing missing was a way of restoring all the settings of my favorite operating system for it to be precisely as it was before the clean install in one single step, hence, this repository.

Any questions? Get in touch with me (or send me memes) on Twitter at [@TheCodeTherapy](https://twitter.com/TheCodeTherapy), and in case you found something useful in this repository, please feel free to star it on GitHub 😊

<br>

## **How**?

The **`config.sh`** script in this repo will take care of:

- Installing some [**Elementary Packages**](#elementary_anchor) to allow building stuff from source;
- Installing some [**Extra Software**](#extra-software_anchor) and Packages (see below);
- Configuring some [**Development Tools**](#development-tools_anchor) in a very oppinionated way;
- Providing some [**Visual Studio Code Extensions Recommendations**](#vscode-extensions_anchor);
- Providing some [**Handy Scripts**](#handy-scripts_anchor) to replace bloated software with **KISS**-like solutions;
- Providing [**Secure Hosts and Hosts.deny**](#secure-hosts_anchor) with malicious URL blacklist;
- Installing some awesome Nerd-like **TrueType Fonts**;

The script is also capable of finding the fastest mirrors for the geographic location it is being executed from (based on download speed tests), but to keep the distro using its default installation setting, I decided to prevent it from actually changing the mirrors. To enable it, check the **`choose_fastest_mirror`** function inside the `config.sh` script, and **uncomment its commented line**.

<br>

<a name="elementary_anchor"></a>
## Elementary Packages:

Elementary Packages include some must-have packages, basic build-tools to allow building things from source, and also some useful dependencies required by Extra Software I might install beyond the ones already installed by the `config.sh` script. The Elementary Packages installed are:

```
mlocate build-essential pkg-config autoconf automake cmake cmake-data clang clang-tools ca-certificates curl gnupg lsb-release python-is-python3 ipython3 python3-pip python3-dev unzip lzma tree neofetch git neovim zsh tmux gnome-tweaks inxi most ttfautohint v4l2loopback-dkms ffmpeg
```

<br>

<a name="extra-software_anchor"></a>
## Extra Software:

- **rofi**: An extremely customizable window switcher, application launcher, and menu creator that can be associated with useful bind keys. ([project homepage](https://github.com/davatorium/rofi));

- **liferea**: My favorite RSS News Aggregator. Yes, RSS still exists, and it's awesome! Please consider consuming things aside from all the garbage that Social Media's algorithms choose for you disregarding your true will. ([project homepage](https://github.com/lwindolf/liferea));

- **hexchat**: After more than 20 years of using `irssi` on a Terminal, I decided to migrate to a GUI-based IRC client. Yes, IRC still exists, and it's awesome! You can find me as **`TheCodeTherapy`** at `Libera.Chat IRC Network` on several channels as `#ubuntu`, `#archlinux`, `#mame`, and others. ([project homepage](https://github.com/hexchat));

- **telegram-desktop**: The Desktop client for Telegram, because we all have normie family members and friends, and it is not a piece of garbage like Whatsapp, right? ([project homepage](https://snapcraft.io/telegram-desktop));

- **discord**: The all-in-one voice and text chat that became the sacred temple of Gaming and Memes (and Work for some very rare, smart, and progressive companies) installed from Snapcraft. ([project homepage](https://snapcraft.io/discord));

- **Visual Studio Code**: I'm personally more of a neovim guy, but I have a day job like everybody else, and sometimes shared/common tools and consistency is important. ([project homepage](https://github.com/Microsoft/vscode/));

- **OBS Studio**: The most amazing open-source and cross-platform screencasting and streaming app. ([project homepage](https://github.com/obsproject/obs-studio));

- **screenkey**: A screencast tool to display every one of your key-presses in real-time, very useful for recording or streaming tutorials or live-coding sessions. ([project homepage](https://gitlab.com/screenkey/screenkey));

- **exa**: A modern and feature-rich replacement for the good old `ls` command with `Git` integration written in Rust. ([project homepage](https://github.com/ogham/exa));

- **kdiskmark**: A disk benchmark tool with a graphical user interface. Please remember to benchmark your disk defining a file size that is 1/1000th of your total disk size (if your disk has 1TB, set the benchmark file to 1GiB) to prevent caching from interfering on the results. ([project homepage](https://github.com/JonMagon/KDiskMark));

- **spotify**: Because life would be very sad without music. You can check my **INCREDIBLY AMAZING** playlists at the end of this page. ([project homepage](https://snapcraft.io/spotify));

<br>

<a name="development-tools_anchor"></a>
## Development Tools:

The script `config.sh` will install the following tools:

- **Visual Studio Code** from Microsoft repository;
- **nvm** and the latest LTS versions of **Node.JS** and **npm**;
- **Yarn** on its latest version;
- **Rust** with `RUSTUP_HOME` and `CARGO_HOME` set to `/opt/rust`;
- **python-is-python3** package because having to type python3 makes no sense since the Mesozoic era;

<br>

<a name="vscode-extensions_anchor"></a>
## Visual Studio Code Extensions:

By opening the directory you cloned this repository to with Visual Studio Code, the provided `extensions.json` will make vscode offer you the possibility to install all my recommended extensions automatically with a single click. The recommended extensions so far are:

- Microsoft ESLint;
- Microsoft C/C++ IntelliSense;
- Better TOML;
- Material Theme and Icons for VSCode;
- Rasi (syntax highlighting to edit `rofi` themes);

<br>

<a name="handy-scripts_anchor"></a>
## Handy Scripts:

---
### **emoji.sh**:

This script will use `rofi` combined with a simple `text file` containing a gigantic `list of emojis` and their descriptions (you can search by description, so feel free to translate to your native language if you want), and `xclip` to copy the emoji to your clipboard when you select one and press enter. You can set a bind-key on Gnome-shell to launch it:

1. Go to Gnome **`Settings`**;
2. Go to **`Keyboard Shortcuts`** in the left pane;
3. Press the **`+`** sign at the bottom of the list to create a new bind;
4. `Name` the bind as you want (I used `Emoji Picker`);
5. `Command`: paste the **full** path to the `emoji.js` script;
6. `Shortcut`: Press the combination of keys you want (I use `Super + .`).
<br><br>
- Check the screen-shot below to see my settings:
<br><br>
<img src="https://mgz.me/publicfiles/images/emojish.png?raw=true" width="464" height="191">

<br>

---
### **truecolortest**:

A simple bash script that uses `awk` (it's very powerful, isn't it?) to check if your Terminal Emulator is currently supporting true-color mode. If you're on `Ubuntu 20.04 LTS` using the default `gnome-terminal`, you'll have true-color support. I just wrote this script for cases in which you're using a terminal inside `neovim`, `emacs`, `tmux`, `screen`, and other similar cases, so you can check if you still have true-color mode available inside your terminal application (in case you do, you should see a result similar to the screenshot below):

<img src="https://mgz.me/publicfiles/images/truecolorscript.png?raw=true" width="429" height="50">

<br>

---
### **externalip**:

Let's say you're hosting a game server like Minecraft on your home computer, and you'll need to share your external IP address with a friend, for him to be able to join your game (remember you'll need to take care of port forwarding in case your PC is behind a router or NAT).

I wrote this shell script to work with `rofi` similarly to the `emoji.sh` script. You can create a bind key on Gnome (using the same steps described above for the `emoji.sh` script... I use `Super + -`), and associate it with the `externalip` script, and once you press your bind keys combination, you'll see your external IP in a pop-up window (and it will be copied to your clipboard when you press enter to close the window so you can send it to your friend). Sounds silly, but it's way faster and easier than searching for `my ip` on Google, doesn't need you to open a browser, and I love small hacks and tweaks that make my life easier.

<br>

---
### **readtemps**:

A simple bash script, to be used in the terminal, that I wrote to iterate through all your `hwmon` sys files using the pattern `/sys/class/hwmon/hwmon*/temp*_input` to get all available temperatures for your computer hardware devices.

<br>

---
### **rofitemps**:

This is a simple script that uses `rofi` in a similar way to other handy scripts like `emoji.sj` and `externalip`, combined with the above `readtemps` script for you to be able to see your devices temperatures in a pop-up GUI window, so you can associate it with a bind key for easy of use. You can create a bind key for it in Gnome (I personally use `Super + Shift + t`) using the same method used for the `emoji.sh` script or the `externalip` script.

<br>

<a name="secure-hosts_anchor"></a>
## Secure Hosts and Hosts.deny

The `config.sh` script uses **The Ultimate Hosts Blacklist project** ([project homepage](https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist)) to provide you with a gigantic blacklist of publicly known malicious URLs, to block them and provide some improved level of navigation protection. I also wrote the **`updatehosts`** script, on path, that can be used to update your `hosts` and `hosts.deny` on `/etc` on a constant basis.

<br><br><br>

## My Playlists at Spotify:

- ([Neon Lights](https://open.spotify.com/playlist/0lUpSwnzToQq8n75bACVUs?si=ac3adbefb4714c95)) while Programming;

- ([Coke in a Glass Bottle](https://open.spotify.com/playlist/2scSDGQfoVy7DQPsfxRjUA?si=0421ed0b8df14302)) while Relaxing;

- ([Barefoot in odd days and Christian Holidays](https://open.spotify.com/playlist/560yRQr9tHr9BKLJTHpLeC?si=eceb7b4827a142d5)) to Workout;

