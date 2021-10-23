import uuid
from faker import Faker
fake = Faker()

if __name__ == "__main__":
   
   with open("../inserts.sql", "w") as inserts_file:
      for i in range (1000):
         id = str(uuid.uuid4())
         name = fake.name()
         email = fake.email()
         address = fake.address().replace("\n", " ")
         # Writing data to a file
         inserts_file.write(f"INSERT INTO user (id, fullname, email, address) VALUES ('{id}', '{name}', '{email}', '{address}');\n")