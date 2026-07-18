#!/usr/bin/env python3
"""
CSV verilerini import.Legacy* staging tablolarına yükler.
Kullanım: python load_staging.py --conn "Server=...;Database=YafesPars;..."
"""
import argparse
import csv
import os
import pyodbc

DATA_DIR = os.path.dirname(__file__)

DOMAIN_MAP = {
    "01": "AUTO", "02": "BRAND", "03": "AANSPRAKELIJKHEID",
    "04": "LEVEN", "05": "GEZONDHEID", "06": "RECHTSBIJSTAND",
    "07": "REIZEN", "08": "LANDBOUW", "09": "DIVERS", "99": "DIVERS",
}

STATUS_MAP = {"1": "ACTIVE", "2": "SUSPENDED", "3": "CANCELLED",
              "4": "EXPIRED", "5": "DRAFT"}

LANG_MAP = {"0": "NL", "1": "FR", "2": "EN"}


def safe_date(val):
    if not val or val in ("0000-00-00", "0000-00-00 00:00:00"):
        return None
    return val.split(" ")[0]


def safe_str(val):
    v = val.strip() if val else ""
    return v if v else None


def safe_decimal(val):
    try:
        return float(val) if val and val.strip() else None
    except ValueError:
        return None


def load_persons(conn):
    cur = conn.cursor()
    cur.execute("TRUNCATE TABLE import.LegacyPerson")

    algemeen = {}
    with open(os.path.join(DATA_DIR, "betrokken_algemeen.csv"), encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            algemeen[row["bet_id"]] = row

    inserted = 0
    with open(os.path.join(DATA_DIR, "betrokkenen.csv"), encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            bid = row["bet_id"]
            alg = algemeen.get(bid, {})
            gender = alg.get("geslacht", "").strip().upper()
            gender = gender if gender in ("M", "V") else None
            if gender == "V":
                gender = "F"
            cur.execute(
                """INSERT INTO import.LegacyPerson
                   (legacy_bet_id, nat_of_rechtspersoon, last_name, first_name,
                    gender_code, date_of_birth, national_id, id_card_number,
                    language_code, nationality, risk_level)
                   VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
                int(bid),
                int(alg["nat_of_rechtspersoon"]) if alg.get("nat_of_rechtspersoon") else None,
                safe_str(alg.get("naam")),
                safe_str(alg.get("voornaam")),
                gender,
                safe_date(alg.get("geboorte_datum")),
                safe_str(alg.get("nummer_rijksregister")),
                safe_str(alg.get("nummer_identiteitskaart")),
                LANG_MAP.get(alg.get("taal", "").strip(), "NL"),
                safe_str(alg.get("nationaliteit")),
                int(alg["risk_level"]) if alg.get("risk_level") else None,
            )
            inserted += 1
    conn.commit()
    print(f"LegacyPerson: {inserted} rijen geladen")


def load_contracts(conn):
    cur = conn.cursor()
    cur.execute("TRUNCATE TABLE import.LegacyContract")

    # premie per contract
    premie = {}
    premie_file = os.path.join(DATA_DIR, "contract_jaarpremie.csv")
    if os.path.exists(premie_file):
        with open(premie_file, encoding="utf-8-sig") as f:
            for row in csv.DictReader(f):
                premie[row["contract_id"]] = row

    inserted = 0
    with open(os.path.join(DATA_DIR, "contracten.csv"), encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            cid = row["contract_id"]
            p = premie.get(cid, {})
            domain = row.get("domein", "").strip().zfill(2)
            status = row.get("status", "").strip()
            cur.execute(
                """INSERT INTO import.LegacyContract
                   (legacy_contract_id, legacy_bet_id, policy_number,
                    legacy_domain, contract_domain_code,
                    legacy_status, contract_status_code,
                    payment_frequency, gross_premium, net_premium, commission, created_at)
                   VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
                int(cid),
                int(row["bet_id"]) if row.get("bet_id") else None,
                safe_str(row.get("polisnummer")),
                domain,
                DOMAIN_MAP.get(domain, "DIVERS"),
                int(status) if status.isdigit() else None,
                STATUS_MAP.get(status, "EXPIRED"),
                int(row["periodiciteit"]) if row.get("periodiciteit") and row["periodiciteit"].isdigit() else None,
                safe_decimal(p.get("bruto_premie")),
                safe_decimal(p.get("netto_premie")),
                safe_decimal(p.get("commissie")),
                safe_date(row.get("added_time")),
            )
            inserted += 1
    conn.commit()
    print(f"LegacyContract: {inserted} rijen geladen")


def load_claims(conn):
    cur = conn.cursor()
    cur.execute("TRUNCATE TABLE import.LegacyClaim")

    # contract per schade via schadecontract.csv
    schadecontract = {}
    sc_file = os.path.join(DATA_DIR, "schadecontract.csv")
    if os.path.exists(sc_file):
        with open(sc_file, encoding="utf-8-sig") as f:
            for row in csv.DictReader(f):
                schadecontract[row.get("schade_id", "")] = row.get("contract_id")

    algemeen = {}
    alg_file = os.path.join(DATA_DIR, "schadegeval_algemeen.csv")
    if os.path.exists(alg_file):
        with open(alg_file, encoding="utf-8-sig") as f:
            for row in csv.DictReader(f):
                algemeen[row.get("schade_id", "")] = row

    inserted = 0
    with open(os.path.join(DATA_DIR, "schadegeval.csv"), encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            sid = row["schade_id"]
            alg = algemeen.get(sid, {})
            cur.execute(
                """INSERT INTO import.LegacyClaim
                   (legacy_schade_id, legacy_contract_id, incident_date,
                    description, liability_flag, material_damage_amt, bodily_injury_amt)
                   VALUES (?,?,?,?,?,?,?)""",
                int(sid),
                int(schadecontract[sid]) if schadecontract.get(sid) else None,
                safe_date(alg.get("datum") or row.get("datum")),
                safe_str(row.get("omstandigheden")),
                1 if row.get("aansprakelijkheid") == "1" else 0,
                safe_decimal(row.get("materiele_schade")),
                safe_decimal(row.get("lichamelijke_schade")),
            )
            inserted += 1
    conn.commit()
    print(f"LegacyClaim: {inserted} rijen geladen")


def main():
    parser = argparse.ArgumentParser(description="CSV → import.Legacy* staging loader")
    parser.add_argument("--conn", required=True, help="ODBC connection string")
    parser.add_argument("--table", default="all", help="persons|contracts|claims|all")
    args = parser.parse_args()

    conn = pyodbc.connect(args.conn)
    conn.autocommit = False

    if args.table in ("all", "persons"):
        load_persons(conn)
    if args.table in ("all", "contracts"):
        load_contracts(conn)
    if args.table in ("all", "claims"):
        load_claims(conn)

    conn.close()
    print("Klaar.")


if __name__ == "__main__":
    main()
