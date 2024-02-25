# Importing required libraries
import os
import threading
import pandas as pd
import requests
from bs4 import BeautifulSoup

# Creating a data frame for the rounds, Grands Prix, and number of laps
grand_prix_df = pd.DataFrame({
    "round_num": [1, 2, 3, 4, 5],
    "grand_prix": ["Bahrain", "Saudi Arabia", "Australia", "Japan", "China"],
    "laps": [57, 50, 58, 53, 56]
})

# Setting the round number as the data frame index
grand_prix_df.set_index("round_num", inplace=True)
print(f"Grand prix data frame: \n----- \n{grand_prix_df.head()}")

# Checking if 'lap_times.csv' exists
file_check = False
file_rounds = set()

if os.path.exists("lap_times.csv"):
    file_rounds = set(pd.read_csv("lap_times.csv")["round"])
    file_check = True

# Returning the rounds in round_list that are not on file
set_diff = list(set(grand_prix_df.index.values).difference(file_rounds))
print(f"\nFile: {file_check, set_diff[:5]}")

# Creating a dictionary with each constructor's drivers
constructor_driver_dict = {
    "Alpine": ["GAS", "OCO"], "Aston Martin": ["ALO", "STR"],
    "Ferrari": ["LEC", "SAI"], "Haas": ["HUL", "MAG"],
    "Kick Sauber": ["BOT", "ZHO"], "McLaren": ["NOR", "PIA"],
    "Mercedes": ["HAM", "RUS"], "Racing Bulls": ["RIC", "TSU"],
    "Red Bull": ["PER", "VER"], "Williams": ["ALB", "SAR"]
}

pair = []

for constructor, drivers in constructor_driver_dict.items():
    pair.append([constructor, drivers[0]])
    pair.append([constructor, drivers[1]])

# Converting the dictionary to a data frame
constructor_df = pd.DataFrame(pair, columns=["constructor", "driver"])
print(f"\n Constructor data frame: \n----- \n{constructor_df.head()}")

# Creating a data frame to store observations
lap_time_df = pd.DataFrame(columns=["round", "grand_prix", "driver",
                                    "lap", "position", "time"])

df_list = []


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


def grand_prix_loop(round_num, grand_prix, lap) -> None:
    url = f"https://ergast.com/api/f1/2024/{round_num}/laps/{lap}.xml"
    response = requests.get(url).content
    soup = BeautifulSoup(response, features="xml")
    timing_list = soup.findAll("Timing")

    lap_time_loop(round_num, grand_prix, timing_list)


def multithread() -> None:
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


def transform_export(dataframe) -> None:
    if not set_diff == []:
        # Merging data frames
        new_df = dataframe
        new_df = pd.concat(df_list, ignore_index=True)
        new_df = new_df.merge(constructor_df, how="left")

        # Transforming columns
        cols = new_df.columns.tolist()
        new_df = new_df[cols[:2] + cols[-1:] + cols[2:-1]]
        new_df["time"] = new_df["time"].round(3)

        # Export data frame based on CSV file existence
        if file_check:
            new_df.to_csv("lap_time.csv", mode="a", index=False, header=False)
        else:
            new_df.to_csv("lap_time.csv", index=False)


if __name__ == "__main__":
    multithread()
    transform_export(lap_time_df)
