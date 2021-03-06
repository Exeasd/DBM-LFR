<div align="center">

# Fork of DBM-Warmane (3.3.5a) created by Zidras, modified to be used on LFR Server


</div>

Core addon backport from retail by Barsoomx: (https://github.com/Barsoomx/DBM-wowcircle).

This repository aims to configure Zidras dbm to be able to be used on LFR server.

# What's new?
- Boss modules now have dedicated fields for type of bar and associated voice speech (countdown for bars, and sound on Special Warnings)
![image](https://user-images.githubusercontent.com/10605951/120121605-44e74c00-c19c-11eb-809b-7ceaee2336c8.png)
- Support for Voice Packs:
![image](https://user-images.githubusercontent.com/10605951/120121681-bf17d080-c19c-11eb-9c5c-77e131e92c14.png)
- Integration with Bunny's Weakauras backport:
![image](https://user-images.githubusercontent.com/10605951/130357929-c8cb1cb7-e5ff-40bf-a36f-2587d966bca5.png)
- And more!


# HOW TO INSTALL FOR THE FIRST TIME
**Disclaimer: If you have used DBM before and you wish to save old DBM profiles, backup your WTF folder, because we will be performing a clean install as this is a retail backport and therefore it is not compatible with 2010's version of DBM. To proceed with the clean installation process, do the following steps:**

1. On your addons folder (Interface/Addons), select every DBM folder (everything that starts with DBM-) and **delete** them.
2. On your SavedVariables folder (WTF/Account/[AccountName]/SavedVariables), select every DBM file (everything that starts with DBM-) and **delete** them. **THIS STEP WILL REMOVE YOUR DBM CONFIGURATIONS/PROFILES!**
3. On **each** of your Characters SavedVariables folder (WTF/Account/[AccountName]/[ServerName]/[CharacterName]/SavedVariables). Select every DBM file (everything that starts with DBM-) and **delete** them. **THIS STEP WILL REMOVE YOUR DBM CONFIGURATIONS/PROFILES!**

**With no remnants of old DBM files we are now ready to start the installation process.**

1. Download the addon from the **main** repository (https://github.com/Exeasd/DBM-LFR/archive/refs/heads/main.zip).
2. Inside the zip file, open DBM-LFR-main. Copy/Paste all those folders (DBM-Core, DBM-GUI, etc) into your addons folder (Interface/Addons). DO NOT put the DBM-LFR-main folder directly into the addon folder, it will not work.
3. Load your game client into your character selection screen. On the bottom left corner, click AddOns and enable all the DBM entries like so:
![image](https://user-images.githubusercontent.com/10605951/127546459-1dd1eb99-8360-40c2-9ffa-093e365cd01b.png)
![image](https://user-images.githubusercontent.com/10605951/127546757-e086103a-34bd-48c5-8555-a734031e1ecc.png)

# HOW TO KEEP THE ADDON UPDATED
Updating DBM follows the standard procedure that applies to any addon installation. Everytime there are new changes*, do these steps:
1. Download the addon from the **main** repository (https://github.com/Exeasd/DBM-LFR/archive/refs/heads/main.zip).
2. Inside the zip file, open DBM-LFR-main. Select all the folders (DBM-Core, DBM-GUI, etc) and press Copy (Ctrl+C).
3. (**Advisable**) On your addons folder (Interface/Addons), before pasting, select the DBM folders that are there and delete them (you will not lose your profiles doing this, don't worry - those are on WTF folder and there is no need to touch that anymore). This ensures that there is no remnant file that could potentially conflict with latest releases.
4. On your addons folder (Interface/Addons), Paste (Ctrl+V) the previously copied folders here. DO NOT put the DBM-LFR-main folder directly into the addon folder, it will not work.

# QUICK START
To open the options window, type `/dbm` into your chat and hit enter or use the minimap icon. For more commands, type `/dbm help`.

