import sys
import rgbprint
import subprocess
import requests

#janky checker that i think literally doesnt work
try:
    subprocess.run(['nim', '--version'], check=True)
    print("Nim is in your PATH :3 :3 :3")
except FileNotFoundError:
    user_input = input("nim is not in PATH. Would you like to install it? (y/n)")
    if user_input.lower() == "y":
        url = "https://github.com/dom96/choosenim/releases/download/v0.8.4/choosenim-0.8.4_windows_amd64.exe"
        response = requests.get(url)
        if response.status_code == 200:
            with open("choosenim-0.8.4_windows_amd64.exe", "wb") as file:
                file.write(response.content)
            subprocess.run(["choosenim-0.8.4_windows_amd64.exe"], check=True)
            print("Please follow the prompts.")
        else:
            print("Failed to download... probalby GitHub crying, try again later")
    else:
        print("Continuing without installing Nim (almost everything will be broken).")


# ugly skidded multitool bs, 
        

