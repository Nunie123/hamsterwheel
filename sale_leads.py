# sale_leads.py
import csv
from faker import Faker

def generate_file() -> None:
    fake = Faker()
    with open('sale_leads.csv', 'w') as f:
        writer = csv.writer(f, delimiter=',')
        writer.writerow(['name', 'phone_number'])
        for _ in range(500):
            writer.writerow([fake.name(), fake.phone_number()])

if __name__ == '__main__':
    generate_file()