#This python program is to read the file having json data and load into PostGreSQL database, calulate customer LTV values
import json
try:
    import psycopg2
except:
    print ("Install psycopg2 to connect postgres")
    exit(123)


class my_parser:
    
    def __init__(self):

        self.conn = psycopg2.connect(database='postgres', user='postgres', password='postgres', host='localhost')
        self.cur = self.conn.cursor()
        self.schema_name='Shutterfly'

    # CustomerLTV function to calculate LTV values for customers.
    def CustomerLTV(self,X):
        LTVsql = 'select * from  '+ self.schema_name +'.CUSTOMER_LTV limit ' + str(X)
        self.cur.execute(LTVsql)
        output = self.cur.fetchall()
        
        # generate output file for top X customer LTV values.
        with open("/Users/nkumar/Downloads/Shutterfly/output.txt",'w') as file:
            for row in output:
                file.write("%s\n" % str(row))
        file.close()   

    # function to ingest the data into PostgreSQL.
    def ingest(self,tab_name,action,col_list,value_list):
        tab_name = tab_name.lower() 
        pri_key ={'customer':'customer_id','image':'image_id','order':'order_id','site_visit':'visit_id'} 
        #pri key will hold the primarykey of the table.
        p_key = pri_key[tab_name]
        col_list[0]=p_key

                
        # code for update based on primary_key
        if action.lower() in ['update']:
                    update_col=''    
                    for k in range(len(col_list)-1):
                        update_col = update_col + col_list[k+1]+"="+value_list[k+1] + ","
                    usql = 'UPDATE '+self.schema_name+'.'+str(tab_name)+' SET '+update_col[:-1] + ' where '+ p_key + '= ' +value_list[0]+ ';' 
                    # print("update query ", usql)
                    self.cur.execute(usql)
                    self.conn.commit()
                    print("Record has been updated")
                        
                        
        # code to insert into tables
        if action.lower() in ['new','upload']:
                isql = 'insert into '+self.schema_name+'.'+str(tab_name)+' ('+','.join(col_list)+') values ('+','.join(value_list)+');'  
                # print("my query : ", isql)
                self.cur.execute(isql)
                self.conn.commit()
                print("Record has been inserted")


# Main program 

#Open input file, here using event.txt  
with open("/Users/nkumar/Downloads/Shutterfly/event.txt",'r') as f:	
    parser = my_parser() # create an object of class.
    file_data=json.load(f)

#ignore this keys from dict
ignore_list=['type', 'verb']

#get the records at row level
for line in file_data:
    print ("line : " , line)
    col_list=[]
    value_list=[]
    tab_name=line['type']
    action=line['verb']

    #get all the required columns and values that needs to be inserted/updated
    for key in line:
        if key not in ignore_list:
            col_list.append(key)
            value_list.append("'"+line[key]+"'")


    # print ("col_list : " , col_list)
    # print ("value_list : " , value_list)

    #call to perform the insert/update
    parser.ingest(tab_name,action,col_list,value_list)


X = 3 # top X LTV values
#Calculate TOP X LTV values
parser.CustomerLTV(X) 
#Closing DB connection.
parser.conn.close()


