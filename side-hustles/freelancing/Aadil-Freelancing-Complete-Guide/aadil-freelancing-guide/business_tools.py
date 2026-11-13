#!/usr/bin/env python3
"""Offline freelance arithmetic and due-action review. Python 3.10+ standard library.

No networking, email sending, account creation, or file mutation.
Amounts use decimal arithmetic. Results exclude tax and unallocated overhead.
"""
import argparse
import csv
import io
import json
import unittest
from datetime import date
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from pathlib import Path


def nonnegative(value):
    try:
        result = Decimal(str(value))
    except InvalidOperation as error:
        raise ValueError("Use a finite nonnegative number") from error
    if not result.is_finite() or result < 0:
        raise ValueError("Use a finite nonnegative number")
    return result


def positive(value):
    result = nonnegative(value)
    if result == 0:
        raise ValueError("Hours must be greater than zero")
    return result


def money(value):
    return str(value.quantize(Decimal("0.01"), rounding=ROUND_HALF_UP))


def quote(hours, rate, costs=0, contingency=0):
    total = (positive(hours) * nonnegative(rate)
             + nonnegative(costs) + nonnegative(contingency))
    return {"currency": "USD", "internal_quote_floor": money(total),
            "note": "Planning arithmetic, not a market rate or willingness to pay."}


def project(revenue, costs, hours):
    contribution = nonnegative(revenue) - nonnegative(costs)
    total_hours = positive(hours)
    return {"currency": "USD", "contribution_before_tax_and_overhead": money(contribution),
            "contribution_per_total_hour": money(contribution / total_hours),
            "note": "Include acquisition, calls, revisions, handover, and support in hours."}


def due_actions(stream, as_of):
    reader = csv.DictReader(stream)
    required = {"account", "next_action", "next_action_date", "opted_out", "status"}
    if not reader.fieldnames or not required.issubset(reader.fieldnames):
        raise ValueError("CSV missing required fields: " + ", ".join(sorted(required)))
    due, warnings = [], []
    for row_number, row in enumerate(reader, 2):
        if None in row or any(v is None for v in row.values()):
            warnings.append(f"Row {row_number}: malformed row; skipped")
            continue
        flag = row["opted_out"].strip().lower()
        # Fail closed when the flag is absent or invalid; never assume contact is OK.
        if flag not in {"true", "false"}:
            warnings.append(f"Row {row_number}: opted_out must be true or false; skipped")
            continue
        if flag == "true" or row["status"].strip().lower() in {"closed", "lost", "won"}:
            continue
        if not row["account"].strip() or not row["next_action"].strip():
            warnings.append(f"Row {row_number}: missing account/action; skipped")
            continue
        try:
            deadline = date.fromisoformat(row["next_action_date"].strip())
        except ValueError:
            warnings.append(f"Row {row_number}: invalid next_action_date; skipped")
            continue
        if deadline <= as_of:
            due.append({"account": row["account"], "next_action": row["next_action"],
                        "due": deadline.isoformat()})
    return {"as_of": as_of.isoformat(), "due_actions": due, "warnings": warnings,
            "note": "Local reminders only. This does not authorize or send outreach."}


class BusinessChecks(unittest.TestCase):
    def test_quote(self):
        self.assertEqual(quote(30, 70, 100, 300)["internal_quote_floor"], "2500.00")

    def test_total_effort(self):
        self.assertEqual(project(2400, 120, 32)["contribution_per_total_hour"], "71.25")
        self.assertEqual(project(2400, 120, 40)["contribution_per_total_hour"], "57.00")

    def test_loss_and_rounding(self):
        self.assertEqual(project(10, 20, 3)["contribution_per_total_hour"], "-3.33")
        self.assertEqual(quote(1, "0.105")["internal_quote_floor"], "0.11")

    def test_bad_values(self):
        for value in [0, -1, "NaN", "Infinity", "abc"]:
            with self.assertRaises(ValueError):
                project(100, 10, value)
        with self.assertRaises(ValueError):
            quote(1, -1)

    def test_suppression_and_dates(self):
        data = ("account,next_action,next_action_date,opted_out,status\n"
                "Due,Review,2026-11-13,false,research\n"
                "Suppressed,Review,2026-11-12,true,research\n"
                "Future,Review,2026-11-16,false,research\n"
                "BadFlag,Review,2026-11-12,,research\n"
                "BadDate,Review,wrong,false,research\n"
                "Closed,Review,2026-11-12,false,closed\n")
        result = due_actions(io.StringIO(data), date(2026, 11, 13))
        self.assertEqual([x["account"] for x in result["due_actions"]], ["Due"])
        self.assertEqual(len(result["warnings"]), 2)

    def test_csv_shape(self):
        with self.assertRaises(ValueError):
            due_actions(io.StringIO("account\nA\n"), date(2026, 11, 13))
        data = "account,next_action,next_action_date,opted_out,status\nA,Do,2026-11-13,false\n"
        self.assertEqual(len(due_actions(io.StringIO(data), date(2026, 11, 13))["warnings"]), 1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    q = commands.add_parser("quote", help="Compute an internal planning floor")
    for option in ["hours", "rate"]:
        q.add_argument("--" + option, required=True)
    for option in ["costs", "contingency"]:
        q.add_argument("--" + option, default="0")
    p = commands.add_parser("project", help="Compute contribution per total hour")
    for option in ["revenue", "costs", "hours"]:
        p.add_argument("--" + option, required=True)
    r = commands.add_parser("review", help="Read a local prospect CSV for due actions")
    r.add_argument("csv_path", type=Path)
    r.add_argument("--as-of", required=True, help="ISO date, e.g. 2026-11-13")
    commands.add_parser("self-test", help="Run local arithmetic and suppression checks")
    args = parser.parse_args()
    if args.command == "self-test":
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(BusinessChecks)
        result = unittest.TextTestRunner(verbosity=2).run(suite)
        raise SystemExit(0 if result.wasSuccessful() else 1)
    try:
        if args.command == "quote":
            result = quote(args.hours, args.rate, args.costs, args.contingency)
        elif args.command == "project":
            result = project(args.revenue, args.costs, args.hours)
        else:
            with args.csv_path.open(newline="", encoding="utf-8-sig") as stream:
                result = due_actions(stream, date.fromisoformat(args.as_of))
    except (ValueError, OSError, csv.Error) as error:
        parser.error(str(error))
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
