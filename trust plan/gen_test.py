#!/usr/bin/env python3
import uuid, random
from datetime import datetime, timedelta

random.seed(42)

def ng(s):
    return uuid.uuid5(uuid.NAMESPACE_DNS, "am." + s)

def fd(d):
    return "'" + d.strftime("%Y-%m-%d") + "'"

def ss(s):
    if s is None:
        return "NULL"
    return "N'" + str(s).replace("'", "''") + "'"

VG = ng("ot.VEHICLE")
RG = ng("ot.REAL_ESTATE")
PG = ng("ot.PERSON")
TG = ng("ot.THING")
AG = ng("ot.ACTIVITY")
LG = ng("ot.LOAN")

OT_GUIDS = {"VEHICLE": VG, "REAL_ESTATE": RG, "PERSON": PG, "THING": TG, "ACTIVITY": AG, "LOAN": LG}

CITIES = [
    ("2800","Mechelen"),("1000","Brussel"),("9000","Gent"),
    ("2000","Antwerpen"),("3000","Leuven"),("3500","Hasselt"),
    ("8000","Brugge"),("5000","Namen"),("4000","Luik"),
    ("8500","Kortrijk"),("8400","Oostende"),("9100","Sint-Niklaas"),
    ("3600","Genk"),("2300","Turnhout"),("2500","Lier"),
    ("9300","Aalst"),("1800","Vilvoorde"),("2200","Herentals"),
    ("2400","Mol"),("3200","Aarschot"),("3300","Tienen"),
    ("3800","Sint-Truiden"),("3700","Tongeren"),
    ("1600","Sint-Pieters-Leeuw"),("1700","Dilbeek"),
    ("1500","Halle"),("2600","Berchem"),("""


The file keeps getting corrupted at the same point. I'll try a different approach—using the IPython environment to build the data structure in memory and then generate the SQL file directly without relying on external files.


I'll generate the complete test data SQL file using Python's ipython tool directly in memory, creating the data structures and SQL statements programmatically rather than trying to write a generator script to disk.
