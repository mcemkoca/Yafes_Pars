#!/usr/bin/env python3
"""Generate comprehensive test data SQL for AssureManager Belgian insurance system."""

import uuid
import random
from datetime import datetime, timedelta

random.seed(42)

def ng(seed_str):
    """Generate deterministic GUID."""
    return uuid.uuid5(uuid.NAMESPACE_DNS, f"assuremanager.{seed_str}")

def fd(d):
    """Format date for SQL."""
    return f"'{d.strftime('%Y-%m-%d')}'"

def sql_str(s):
    """Format string for SQL."""
    if s is None:
        return "NULL"
    escaped = str(s).replace("'", "''")
    return f"N'{escaped}'"

# ========================================
# CONSTANTS
# ========================================
VEHICLE_GUID = ng("objecttype.VEHICLE")
REAL_ESTATE_GUID = ng("objecttype.REAL_ESTATE")
PERSON_GUID = ng("objecttype.PERSON")
THING_GUID = ng("objecttype.THING")
ACTIVITY_GUID = ng("objecttype.ACTIVITY")
LOAN_GUID = ng("objecttype.LOAN")

BELGIAN_CITIES = [
    ("2800", "Mechelen"), ("1000", "Brussel"), ("9000", "Gent"),
    ("2000", "Antwerpen"), ("3000", "Leuven"), ("3500", "Hasselt"),
    ("8000", "Brugge"), ("5000", "Namen"), ("4000", "Luik"),
    ("8500", "Kortrijk"), ("8400", "Oostende"), ("9100", "Sint-Niklaas"),
    ("3600", "Genk"), ("2300", "Turnhout"), ("2500", "Lier"),
    ("9300", "Aalst"), ("1800", "Vilvoorde"), ("""


The file seems to be getting corrupted or truncated when I try to write it. Let me try a different approach - I'll generate the SQL directly by building strings in smaller chunks within the IPython environment, or use the shell to create the file via a here-document. Actually, let me try using Python to write the file in smaller increments using the write_file tool with append mode.


The issue appears to be with how the string is being constructed. I notice the BELGIAN_CITIES list is getting cut off mid-tuple with an escaped quote character that's not being properly closed. I need to complete this list and make sure all the city data is properly formatted before the script can work correctly.
