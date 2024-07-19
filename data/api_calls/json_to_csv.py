import pandas as pd

df = pd.read_json (r'airport_data.json')
# content of my_file.json :
#
# {"Product":{"0":"Desktop Computer","1":"Tablet","2":"Printer","3":"Laptop"},"Price":{"0":700,"1":250,"2":100,"3":1200}}

df.to_csv (r'my_file.csv', index = None)
# content of my_file.json :
#