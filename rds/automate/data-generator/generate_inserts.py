import uuid
from faker import Faker

if __name__ == "__main__":
   
   # We use fake to create mock data
   fake = Faker()
   
   with open("../scripts/2-inserts.sql", "w") as inserts_file:
      for i in range (100000):
         id = str(uuid.uuid4())
         name = fake.name()
         email = fake.email()
         address = fake.address().replace("\n", " ")
         role = fake.paragraph(nb_sentences=5)
         # Write into inserts file
         inserts_file.write(f"INSERT INTO user (id, fullname, email, address) VALUES ('{id}', ' çéãô{name} ', '{email}', '{address}');\n")
         inserts_file.write(f"INSERT INTO role_user (id, user_id, title) VALUES ('{id}', '{id}', '{role}');\n")
         