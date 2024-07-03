airports_df_renamed = airports_df.rename(columns={'AirportCode': 'DepartureAirportCode', 
                                                  'Latitude': 'DepartureLatitude', 
                                                  'Longitude': 'DepartureLongitude'})

merged_df = departure_result_df.merge(airports_df_renamed[['DepartureAirportCode', 'DepartureLatitude', 'DepartureLongitude']],
                                      how='left', 
                                      left_on='DepartureAirportCode', 
                                      right_on='DepartureAirportCode')

airports_df_renamed = airports_df.rename(columns={'AirportCode': 'ArrivalAirportCode', 
                                                  'Latitude': 'ArrivalLatitude', 
                                                  'Longitude': 'ArrivalLongitude'})

merged_df = merged_df.merge(airports_df_renamed[['ArrivalAirportCode', 'ArrivalLatitude', 'ArrivalLongitude']],
                            how='left', 
                            left_on='ArrivalAirportCode', 
                            right_on='ArrivalAirportCode')

output_path_complete = '/mnt/data/departure_result_with_all_coordinates.csv'
merged_df.to_csv(output_path_complete, index=False)

import ace_tools as tools; tools.display_dataframe_to_user(name="Merged Departure and Arrival Coordinates", dataframe=merged_df)

output_path_complete
