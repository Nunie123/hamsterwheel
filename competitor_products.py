# competitor_products.py
import json
import random
from faker import Faker

def generate_file() -> None:
    fake = Faker()
    data = []
    for _ in range(500):
        product = dict(
            company=fake.company(),
            product_name=' '.join(fake.words(2)),
            in_stock=fake.boolean(),
            sku=fake.ean(),
            price=random.randrange(500,20000)/100,
            product_groups=[[random.randrange(1,500), random.randrange(1,500)], [random.randrange(1,500), random.randrange(1,500)]]
        )
        data.append(product)
    with open('competitor_products.json', 'w') as f:
        json.dump(data, f)

if __name__ == '__main__':
    generate_file()