#!/usr/bin/env python3
"""Seeds demo transactions + budgets into the macOS dev container of My Expenses.

Store screenshots need a populated app; every repository keeps its data in
SharedPreferences, so we write the same JSON the app writes instead of driving
the UI. Each description carries its own amount range — a random amount taken
from a whole-category range produces things like an 869 internet bill, which a
reader spots instantly in a store screenshot.

    python3 seed_demo.py pt      # or: en
"""
import json, plistlib, random, subprocess, sys, datetime, os

PLIST = os.path.expanduser(
    "~/Library/Containers/com.gambit.meusgastos/Data/Library/Preferences/com.gambit.meusgastos.plist")
LOCALE = sys.argv[1] if len(sys.argv) > 1 else "pt"

# category id -> [(description, min, max)], weight
CATALOG = {
 "pt": [
  ("Shopping",       [("Supermercado", 90, 320), ("Feira da semana", 45, 130),
                      ("Padaria", 12, 38), ("Hortifruti", 25, 85)], 9),
  ("Restaurant",     [("Almoço", 28, 62), ("Jantar fora", 75, 190),
                      ("Café da tarde", 14, 32), ("Delivery", 38, 95)], 8),
  ("Transport",      [("Uber", 14, 46), ("Metrô", 5, 9),
                      ("Estacionamento", 12, 35), ("Ônibus", 4, 8)], 7),
  ("Home",           [("Conta de luz", 120, 260), ("Internet", 99, 139),
                      ("Aluguel", 1650, 1650), ("Condomínio", 480, 520),
                      ("Água", 68, 130)], 4),
  ("GasStation",     [("Gasolina", 150, 300), ("Etanol", 110, 210)], 4),
  ("Drink",          [("Cerveja com os amigos", 45, 110), ("Vinho", 60, 145)], 3),
  ("Hospital",       [("Farmácia", 25, 120), ("Consulta", 180, 350)], 3),
  ("Education",      [("Curso online", 89, 240), ("Livro", 39, 95)], 2),
  ("Movie",          [("Cinema", 32, 68), ("Streaming", 19, 55)], 3),
  ("Phone",          [("Plano do celular", 55, 79)], 2),
  ("ShoppingBasket", [("Compras do mês", 180, 420), ("Limpeza", 45, 110)], 3),
  ("VideoGame",      [("Jogo novo", 99, 249)], 1),
 ],
 "en": [
  ("Shopping",       [("Groceries", 90, 320), ("Farmers market", 45, 130),
                      ("Bakery", 12, 38), ("Produce", 25, 85)], 9),
  ("Restaurant",     [("Lunch", 28, 62), ("Dinner out", 75, 190),
                      ("Coffee", 14, 32), ("Delivery", 38, 95)], 8),
  ("Transport",      [("Rideshare", 14, 46), ("Subway", 5, 9),
                      ("Parking", 12, 35), ("Bus fare", 4, 8)], 7),
  ("Home",           [("Electricity", 120, 260), ("Internet", 99, 139),
                      ("Rent", 1650, 1650), ("Building fee", 480, 520),
                      ("Water", 68, 130)], 4),
  ("GasStation",     [("Gas", 150, 300), ("Fuel", 110, 210)], 4),
  ("Drink",          [("Drinks with friends", 45, 110), ("Wine", 60, 145)], 3),
  ("Hospital",       [("Pharmacy", 25, 120), ("Doctor visit", 180, 350)], 3),
  ("Education",      [("Online course", 89, 240), ("Book", 39, 95)], 2),
  ("Movie",          [("Movie night", 32, 68), ("Streaming", 19, 55)], 3),
  ("Phone",          [("Phone plan", 55, 79)], 2),
  ("ShoppingBasket", [("Monthly shop", 180, 420), ("Cleaning", 45, 110)], 3),
  ("VideoGame",      [("New game", 99, 249)], 1),
 ],
}

BUDGETS = {"Shopping": 1400.0, "Restaurant": 800.0, "Transport": 450.0,
           "Home": 2600.0, "GasStation": 600.0, "Drink": 320.0}


def load_categories():
    with open(PLIST, "rb") as fh:
        data = plistlib.load(fh)
    out = {}
    for entry in data.get("flutter.categories") or []:
        obj = json.loads(entry) if isinstance(entry, str) else entry
        out[obj["id"]] = obj
    return out


def main():
    cats = load_categories()
    rows = CATALOG[LOCALE]
    weights = [r[2] for r in rows]
    random.seed(2609)
    now = datetime.datetime.now()
    cards = []

    def add(day, hour, minute):
        cat_id, descs, _w = random.choices(rows, weights=weights)[0]
        category = cats.get(cat_id)
        if category is None:
            return
        desc, lo, hi = random.choice(descs)
        when = day.replace(hour=hour, minute=minute, second=0, microsecond=0)
        if when > now:                      # never seed a transaction in the future
            when = now - datetime.timedelta(minutes=25)
        cards.append({
            "id": "demo-%03d" % len(cards),
            "amount": round(random.uniform(lo, hi), 2),
            "description": desc,
            "date": when.isoformat(),
            "category": category,
            "idFixoControl": "0",
            "updatedAt": when.isoformat(),
            "deleted": False,
        })

    for offset in range(0, 61):
        day = now - datetime.timedelta(days=offset)
        dense = day.month == now.month and day.year == now.year
        count = random.choices([1, 2, 3, 4] if dense else [0, 1, 2, 3],
                               weights=[2, 4, 3, 1])[0]
        used = set()
        for _ in range(count):
            hour = random.choice([h for h in range(8, 22) if h not in used] or [12])
            used.add(hour)
            add(day, hour, random.choice([0, 15, 30, 45]))

    budgets = [{"categoryId": k, "value": v} for k, v in BUDGETS.items() if k in cats]
    base = PLIST[:-6]                       # `defaults` wants the domain, not the file
    # O RatingGate dispara no aha-moment e o diálogo cobre a tela no meio da
    # captura. Marcar como já respondido desliga o gate durante o shooting.
    subprocess.run(["defaults", "write", base, "flutter.gate.answeredYes",
                    "-bool", "true"], check=True)
    subprocess.run(["defaults", "write", base, "flutter.cardModels", "-string",
                    json.dumps(cards, ensure_ascii=False)], check=True)
    subprocess.run(["defaults", "write", base, "flutter.budgets", "-string",
                    json.dumps(budgets)], check=True)
    month = [c for c in cards if datetime.datetime.fromisoformat(c["date"]).month == now.month]
    print("locale=%s | %d transacoes (%d no mes corrente, R$ %.2f) | %d orcamentos"
          % (LOCALE, len(cards), len(month), sum(c["amount"] for c in month), len(budgets)))


if __name__ == "__main__":
    main()
