import os

# FUNCTIONS
clear = lambda: print("\033c", end="", flush=True)
def pause(): input("Press Enter to continue...")
pause = lambda: input("Press Enter to continue...")


# TEMPORARY VARIABLES
SPOTYdlCurrentVersion = "4.0.0"
total_downloaded_songs_count = 0
bitrate_value_description = "320 kbps"
pending_choice_name = "Pending Choice"
SPOTYdlSetupVersion = "4.0.0"


# MENUS
def MainMenu():
    # Show menu
    clear()
    print("\n                                 -SPOTYdl v{}-".format(SPOTYdlCurrentVersion))
    print("                                {} songs so far\n\n".format(total_downloaded_songs_count))
    print("  Available audio file formats:")
    print("   1) mp3                      4) opus")
    print("   2) m4a                      5) ogg")
    print("   3) flac")
    print("\n  Other options:")
    print("   a) Help                     b) Toggle Bitrate: {}".format(bitrate_value_description))
    print("   c) Manual Audio Matching    d) Settings")
    print("   e) {}     f) Setup v{}".format(pending_choice_name, SPOTYdlSetupVersion))
    print("   g) Version                  h) Export downloaded songs to file")
    print("   i) YouTube only download    j) More options...\n")


def mp3():
    print("mp3")
    pause()



while True:
    MainMenu()
    choice = input("  Input the value that corresponds to your choice: ")
    
    if choice == "1":
        mp3()
        
    if choice == "2":
        print("m4a")
        pause
        
    else:
        print("Invalid Option.")
        
        print()