#%% md
# ### Importing Libraries
#%%
# Uncomment the below line to install libraries
# !pip -q install pandas requests bs4 threading
#%%
import os
import threading

import pandas as pd
import requests
from bs4 import BeautifulSoup
#%% md
# ### Grand Prix Data Frame
#%%
# Creating a data frame for the rounds, Grands Prix, and number of laps
grand_prix_df = pd.DataFrame({
    "round_num": [1, 2, 3, 4, 5],
    "grand_prix": ["Bahrain", "Saudi Arabia", "Australia", "Japan", "China"],
    "laps": [57, 50, 58, 53, 56]
})

# Setting the round number as the data frame index
grand_prix_df.set_index("round_num", inplace=True)
grand_prix_df.head()
#%%
file_check = False
file_rounds = set()

if os.path.exists("lap_times.csv"):
    file_rounds = set(pd.read_csv("lap_times.csv")["round"])
    file_check = True

# Returning the rounds in round_list that are not on file
set_diff = list(set(grand_prix_df.index.values).difference(file_rounds))
file_check, set_diff[:5]
#%% md
# ### Constructor Data Frame
#%%
# Creating a dictionary with each constructor's drivers
constructor_driver_dict = {
    "Alpine": ["GAS", "OCO"], "Aston Martin": ["ALO", "STR"], "Ferrari": ["LEC", "SAI"],
    "Haas": ["HUL", "MAG"], "Kick Sauber": ["BOT", "ZHO"], "McLaren": ["NOR", "PIA"],
    "Mercedes": ["HAM", "RUS"], "Racing Bulls": ["RIC", "TSU"], "Red Bull": ["PER", "VER"],
    "Williams": ["ALB", "SAR"]
}

pair = []

for constructor, drivers in constructor_driver_dict.items():
    pair.append([constructor, drivers[0]])
    pair.append([constructor, drivers[1]])

# Converting the dictionary to a data frame
constructor_df = pd.DataFrame(pair, columns=["constructor", "driver"])
constructor_df.head()
#%% md
# ### Lap Time Data Frame
#%%
lap_time_df = pd.DataFrame(columns=["round", "grand_prix", "driver",
                                    "lap", "position", "time"])

df_list = []
#%%
def lap_time_loop(round_num, grand_prix, timing_list) -> None:
    data = []

    for timing in timing_list:
        minutes, seconds = map(float, timing["time"].split(":"))
        lap_time_sec = minutes * 60 + seconds

        driver = timing["driverId"][:3].upper()
        if driver == "MAX":
            driver = "VER"
        elif driver == "KEV":
            driver = "MAG"

        lap = int(timing["lap"])
        position = int(timing["position"])

        data.append([round_num, grand_prix, driver, lap, position, lap_time_sec])

    columns = ["round", "grand_prix", "driver", "lap", "position", "time"]
    temp_df = pd.DataFrame(data, columns=columns)
    df_list.append(temp_df)
#%%
def grand_prix_loop(round_num, grand_prix, lap) -> None:
    url = f"https://ergast.com/api/f1/2024/{round_num}/laps/{lap}.xml"
    response = requests.get(url).content
    soup = BeautifulSoup(response, features="xml")
    timing_list = soup.findAll("Timing")

    lap_time_loop(round_num, grand_prix, timing_list)
#%% md
# ### Multithreading
#%%
def multithread():
    functions = [
        (i, grand_prix_df.loc[i]["grand_prix"], j + 1)
        for i in set_diff
        for j in range(grand_prix_df.loc[i]["laps"])
    ]

    threads = []
    for args in functions:
        thread = threading.Thread(target=grand_prix_loop, args=args)
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()
#%% md
# ### Transform and Export
#%%
if not set_diff == []:
    # Merging data frames
    lap_time_df = pd.concat(df_list, ignore_index=True)
    lap_time_df = lap_time_df.merge(constructor_df, how="left")

    # Transforming columns
    cols = lap_time_df.columns.tolist()
    lap_time_df = lap_time_df[cols[:2] + cols[-1:] + cols[2:-1]]
    lap_time_df["time"] = lap_time_df["time"].round(3)

    # Export data frame based on CSV file existence
    if file_check:
        lap_time_df.to_csv("lap_time.csv", mode="a", index=False, header=False)
    else:
        lap_time_df.to_csv("lap_time.csv", index=False)