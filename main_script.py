# Importing required libraries
import datetime as dt
import fastf1
import pandas as pd

# Setting up cache
fastf1.Cache.enable_cache('cache/')


def load_data():
    # Obtaining the 2026 race schedule and keeping only past events
    schedule = (
        fastf1.get_event_schedule(2026, include_testing=False)
        .reset_index()
    )
    schedule = schedule.query("EventDate <= @pd.to_datetime(@dt.date.today())")

    # Selecting and renaming columns for the schedule
    cols = {
        "RoundNumber": "round_num",
        "EventName": "grand_prix"
    }
    schedule = schedule[cols.keys()]
    schedule = schedule.rename(columns=cols)

    # Loading lap times and other data
    laps_list = []

    for row in schedule.itertuples(index=False):
        # Loading session data
        session = fastf1.get_session(2026, row.grand_prix, "race")
        session.load()

        # Selecting and renaming columns for lap data
        cols = {
            "Team": "constructor",
            "Driver": "driver",
            "LapNumber": "lap",
            "Position": "position",
            "Compound": "tyre_compound",
            "TyreLife": "tyre_life",
            "Sector1Time": "sector_1_time",
            "Sector2Time": "sector_2_time",
            "Sector3Time": "sector_3_time",
            "LapTime": "lap_time"
        }
        gp_laps = (
            session.laps[cols.keys()]
            .rename(columns=cols)
            .assign(round_num=row.round_num, grand_prix=row.grand_prix)
        )

        laps_list.append(gp_laps)

    return pd.concat(laps_list, ignore_index=True)


def clean_and_export():
    df = load_data()

    int_cols = ["lap", "position", "tyre_life"]
    float_cols = ["sector_1_time", "sector_2_time", "sector_3_time", "lap_time"]

    # Converting column data types
    df[int_cols] = df[int_cols].astype("Int64")
    df[float_cols] = (
        df[float_cols]
        .apply(lambda s: s.dt.total_seconds())
    )

    # Rearranging columns
    df = df[list(df.columns[-2:]) + list(df.columns[:-2])]

    # Exporting data
    df.to_csv("data/lap_times_2026.csv", index=False)


if __name__ == "__main__":
    clean_and_export()
