
import requests
import json
from pymongo import MongoClient


url_template = "https://api.lufthansa.com/v1/operations/flightstatus/departures/{airportCode}/{fromDateTime}"
headers = {
    "Authorization": "Bearer nbajm4mezr2y7qtbezjw9fp9"
}


airport_codes = ['SBA', 'SBN', 'SBP', 'SBW', 'SBY', 'SBZ', 'SCC', 'SCE', 'SCL', 'SCN', 'SCO', 'SCQ', 'SCW', 'SCY', 'SDA', 'SDF', 'SDJ', 'SDK', 'SDL', 'SDQ', 'SDU', 'SEA', 'SEN', 'SEZ', 'SFN', 'SFO', 'SFT', 'SGF', 'SGN', 'SGU', 'SHA', 'SHB', 'SHC', 'SHE', 'SHJ', 'SHL', 'SHR', 'SHV', 'SIA', 'SID', 'SIN', 'SIR', 'SIS', 'SIT', 'SJC', 'SJD', 'SJJ', 'SJO', 'SJP', 'SJU', 'SJW', 'SKB', 'SKG', 'SKP', 'SLA', 'SLC', 'SLP', 'SLW', 'SLZ', 'SMF', 'SMI', 'SMR', 'SMX', 'SNA', 'SNN', 'SNU', 'SOC', 'SOF', 'SPC', 'SPI', 'SPN', 'SPU', 'SRG', 'SRQ', 'SSA', 'SSG', 'SSH', 'STI', 'STL', 'STN', 'STR', 'STS', 'STT', 'STV', 'STW', 'SUB', 'SUF', 'SUN', 'SVG', 'SVO', 'SVQ', 'SVX', 'SVZ', 'SWA', 'SXB', 'SXF', 'SXM', 'SXR', 'SYD', 'SYO', 'SYR', 'SYX', 'SYZ', 'SZF', 'SZG', 'SZK', 'SZX', 'SZZ', 'TAB', 'TAE', 'TAK', 'TAM', 'TAO', 'TAS', 'TBS', 'TBU', 'TBZ', 'TCZ', 'TDX', 'TER', 'TET', 'TEZ', 'TFS', 'TGD', 'TGG', 'TGO', 'TGU', 'TGZ', 'THE', 'THS', 'TIA', 'TIJ', 'TIR', 'TIV', 'TKK', 'TKS', 'TKU', 'TLH', 'TLL', 'TLN', 'TLS', 'TLV', 'TMP', 'TMS', 'TNA', 'TNG', 'TNH', 'TNR', 'TOF', 'TOP', 'TOS', 'TOY', 'TPA', 'TPE', 'TRC', 'TRD', 'TRG', 'TRI', 'TRN', 'TRS', 'TRU', 'TRV', 'TRZ', 'TSA', 'TSE', 'TSJ', 'TSN', 'TSR', 'TTJ', 'TUC', 'TUL', 'TUN', 'TUO', 'TUS', 'TVC', 'TWU', 'TXG', 'TXL', 'TXN', 'TYN', 'TYR', 'TYS', 'TZX', 'UBJ', 'UBP', 'UDI', 'UDR', 'UFA', 'UIO', 'UKB', 'ULN', 'ULY', 'UME', 'UPG', 'URC', 'URT', 'USH', 'USK', 'USM', 'USN', 'UTH', 'UTN', 'UTT', 'UUS', 'UVF', 'VAA', 'VAN', 'VAR', 'VAS', 'VBY', 'VCE', 'VCP', 'VCT', 'VDA', 'VEL', 'VER', 'VFA', 'VGA', 'VGO', 'VIE', 'VIX', 'VKO', 'VLC', 'VLN', 'VNO', 'VNS', 'VNX', 'VOG', 'VOL', 'VOZ', 'VPS', 'VRA', 'VRN', 'VSA', 'VTE', 'VTZ', 'VVI', 'VVO', 'VXE', 'WAG', 'WAW', 'WDH', 'WDS', 'WEH', 'WKJ', 'WLG', 'WNZ', 'WRE', 'WRG', 'WRL', 'WRO', 'WUH', 'WUX', 'WVB', 'WXN', 'XAP', 'XER', 'XFN', 'XIC', 'XIL', 'XIY', 'XMN', 'XNA', 'XNN', 'XRY', 'XUZ', 'YAK', 'YAM', 'YAO', 'YAP', 'YBC', 'YBG', 'YBL', 'YCD', 'YCG', 'YCU', 'YDF', 'YEG', 'YFB', 'YFC', 'YGJ', 'YGK', 'YGP', 'YGR', 'YHM', 'YHZ', 'YIH', 'YIN', 'YIW', 'YKA', 'YKM', 'YLW', 'YMM', 'YNB', 'YNJ', 'YNT', 'YNZ', 'YOW', 'YPR', 'YQB', 'YQG', 'YQL', 'YQM', 'YQQ', 'YQR', 'YQT', 'YQU', 'YQX', 'YQY', 'YQZ', 'YSB', 'YSJ', 'YTS', 'YTY', 'YTZ', 'YUL', 'YUY', 'YVO', 'YVR', 'YWG', 'YWK', 'YWL', 'YXC', 'YXE', 'YXH', 'YXJ', 'YXS', 'YXT', 'YXU', 'YXX', 'YXY', 'YYB', 'YYC', 'YYD', 'YYF', 'YYG', 'YYJ', 'YYR', 'YYT', 'YYY', 'YYZ', 'YZF', 'YZP', 'YZR', 'YZV', 'ZAD', 'ZAG', 'ZAL', 'ZAQ', 'ZBF', 'ZCL', 'ZCO', 'ZDH', 'ZFV', 'ZHA', 'ZIH', 'ZLO', 'ZNZ', 'ZOS', 'ZQN', 'ZRH', 'ZSB', 'ZTH', 'ZUH', 'ZWS', 'ZYI', 'kzo']


client = MongoClient('mongodb://localhost:27017/')
db = client['airline_project']
collection = db['airline']

results = []
errors = []


for code in airport_codes:
    url = url_template.format(airportCode=code, fromDateTime="2024-06-22T00:00")
    
    try:
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            data = response.json()
            
          #insérer les données dans MongoDB 
            result = collection.insert_one({
                "airport_code": code,
                "data": data
            })
            
            print(f"Document inséré avec l'_id: {result.inserted_id}")
        else:
            errors.append({
                "airport_code": code,
                "status_code": response.status_code,
                "reason": response.reason
            })
    except requests.exceptions.RequestException as e:
        errors.append({
            "airport_code": code,
            "error": str(e)
        })

# Enregistrer les erreurs dans des fichiers JSON
with open("/Users/Chams/Desktop/airline_project/api_errors.json", "w") as json_file:
    json.dump(errors, json_file, indent=4)
