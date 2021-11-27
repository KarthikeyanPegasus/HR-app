from logging import debug

from flask import Flask,jsonify,request
import pymssql
import json
from bson import json_util
import decimal
import base64
from base64 import * 
import binascii
import re

def getQuery(query):
	def create_server_connection(server,user,pw,db):
		connection = None
		try:
			connection = pymssql.connect(host=server,
			user=user,
			password=pw,
			database=db)
			print("Mysql db connection successful")
		except pymssql.Error as err:
			print(f"Error: {err}")
		return connection

	def decimal_default(obj):
		if isinstance(obj, decimal.Decimal):
			return float(obj)
		raise TypeError


	server = "148.72.232.166"
	user = "flexi"
	pw = "Admin@123"
	db = "Learabia"
	connection = create_server_connection(server,user,pw,db)

	

	cursor = connection.cursor()
	cursor.execute(query)
	json_docs = []
	for doc in cursor:
		json_doc = json.dumps(doc,default=decimal_default)
		json_docs.append(json_doc)
		

	connection.close()
	return json_docs
	
def getQuerywithoutdecimal(query):
	def create_server_connection(server,user,pw,db):
		connection = None
		try:
			connection = pymssql.connect(host=server,
			user=user,
			password=pw,
			database=db)
			print("Mysql db connection successful")
		except pymssql.Error as err:
			print(f"Error: {err}")
		return connection

	def decimal_default(obj):
		print(type(obj))
		if isinstance(obj, decimal.Decimal):
			return float(obj)
		if isinstance(obj,bytes):
			# return obj.decode("utf8",'ignore')
			print(len(obj) % 4)
			k = str(obj)
			return  k
		
		


	server = "148.72.232.166"
	user = "flexi"
	pw = "Admin@123"
	db = "Learabia"
	connection = create_server_connection(server,user,pw,db)

	

	cursor = connection.cursor()
	cursor.execute(query)
	cursor = cursor.fetchall()
	json_docs = []
	for doc in cursor:
		json_doc = json.dumps(doc,default=decimal_default)
		json_docs.append(json_doc)
		

	connection.close()
	return json_docs

app = Flask(__name__)

@app.route('/',methods=['POST'])
def query():
	fromd = request.json['fromdate']
	tod = request.json['todate']
	comp = request.json['company']
	companylist = request.json['c_list']
	allcompany = request.json['allcompany']
	print(type(companylist))
	c = list(companylist.split(","))
	allc = list(allcompany.split(","))
	
	alllist = ",".join(c)
	compid=""
	if comp == "All":
		for b in c:
			if(b != "All"):
				compid += str(allc.index(b))+","
				print(compid)
		compid+=str(5)
	else:
		for b in allc:
			if b == comp:
				compid = str(allc.index(b))	
	# elif comp ==alllist[1]:
	# 	compid = "1"
	# else:
	# 	compid = "2"
	return  jsonify({"result":getQuery(query="""select *,onroll-(prsn+leav) as absn,case when onroll>0 then cast(round(100.0*prsn/onroll,2) as numeric(15,2)) else 0.00 end as pr_per,case when onroll>0 then 
				cast(round(100.0*(onroll-(prsn+leav))/onroll,2) as numeric(15,2)) else 0 end as ab_per,case when onroll>0 then cast(round(100.0*leav/onroll,2) as numeric(15,2)) else 0 end as lv_per 
				from(select CONVERT(varchar,(convert(date,P_Dt,103)),103) as Dt,count(E_ID) as Onroll,sum(Prsn) as Prsn,sum(leav) as Leav,sum(late) as Late,sum(early) as Early,sum(ot) as Ot from (select b.E_ID,b.e_name,stat,convert(date,P_Dt,103) as P_Dt,c.e_comp_shortname,e.E_unit_Desc,g.E_Cat_Name,E_Dept_Name,E_Divi_Name,'' as descr,E_Desig_Name,'' 
				as Des_Gr,cast(floor(in_ti/60)+((in_ti%60)/100.) as numeric(5,2)) as in_ti,cast(floor(out_ti/60)+((out_ti%60)/100.) as numeric(5,2)) as out_ti,
				(out_ti-in_ti) as Dur,case when in_ti > 0 then 1 else 0 end as Prsn,case when isnull(In_Ti,0)=0 and isnull(ot_cal,0)=0 and lv_desc=Stat then 1 else 0 end as leav,
				shft,a.late as Lt,case when a.late >= 0 or (lt_lv is not null and lt_lv != 'Deduct') or (isnull(f.late_flag,0) = 0 and 
				isnull(g.late,0) = 0) then 0 else 1 end as late,a.early as Erl,case when a.early>=0 or (er_lv is not null and er_lv !='Deduct') or (isnull(f.Early_flag,0)=0 and isnull(g.early,0)=0) then 
				0 else 1 end as early,case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then case when (E_ot_appr is not null and 
				isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else 1 end else 1 end as ot,
				case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else m_ot end + case when (E_ot_appr is not null 
				and isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else e_ot end as OT_hrs,convert(varchar,convert(date,b.e_dt_of_join,103),103) as Doj 
				from Pay_Emp_Master b INNER JOIN At_Psum a ON b.E_ID = a.E_ID and 
				isnull(a.active,0)=1  INNER JOIN Pay_company_master c ON c.e_company_ID = b.E_comp_ID INNER JOIN Pay_Emp_Actul d ON b.E_ID = d.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN 
				Convert(datetime,d.e_FromDate,103) AND Convert(datetime,d.e_ToDate,103)) or (d.e_FromDate <= Convert(datetime,a.P_dt,103) AND d.e_ToDate is null)) INNER JOIN Pay_unit_master e ON e.e_unit_id = d.e_unit inner join Pay_Cat_Master g on g.E_Cat_ID=d.E_Catg left join Pay_Divi_Master on Pay_Divi_Master.E_Divi_ID = d.E_Division 
				INNER JOIN At_Emp f ON b.E_ID = f.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,f.Fr_Date,103) AND Convert(datetime,F.To_Date,103)) or (F.Fr_Date <= 
				Convert(datetime,a.P_dt,103) AND F.To_Date is null)) 
				left JOIN Pay_Dept_Master ON Pay_Dept_Master.E_Dept_ID = d.E_Dept Left JOIN Pay_Desig_Master ON Pay_Desig_Master.E_Desig_ID = d.E_Desg 
				left join At_Lev_typ on isnull(At_Lev_typ.active,0)=1 and At_Lev_typ.lv_desc=a.stat and At_Lev_typ.lv_desc !='AB'
				where (b.e_dt_of_leav is null or convert(datetime, b.e_dt_of_leav, 103)  >= Convert(datetime, a.P_dt, 103)) AND (convert(datetime, b.e_dt_of_join, 103)  <= 
				Convert(datetime,a.P_dt, 103)) and Convert(date,a.P_dt,103) >= Convert(date,'"""+str(fromd)+"""',103) and Convert(date,a.P_dt,103) <= Convert(date,'"""+str(tod)+"""',103)
				and e_company_id in("""+compid+""")  ) as t group by convert(date,P_Dt,103)) as st  
				order by convert(date,Dt,103)""")})
@app.route('/getdropdown',methods=['POST'])
def getdropdown():
    return  jsonify({"result":getQuery(query="""select 0 as comp_id,'All' as Comp_name union
	select E_Company_ID as comp_id,E_Comp_Shortname as Comp_name from Pay_Company_Master""")})

@app.route('/login',methods=['POST'])
def login():
	username = request.json['username']
	password = request.json['password']
	return  jsonify({"result":getQuery(query="""SELECT isnull(a.e_id,'No Master') as Emp_Id,isnull(e.unit,'0') as Gr_head from thams 
left join UserMaster e on e.username='"""+username+"""' and isnull(e.active,0)=1
left join upw1 f on e.userid=f.Id and f.pwd='"""+password+"""' 
left join pay_emp_master a on E_dt_of_leav is null and (a.e_id ='"""+username+"""' or (f.Id is not null and a.e_Id=e.emp_id))
left join Pay_Emp_Mast_Add b on a.e_id = b.e_id and b.e_pwd ='"""+password+"""'
where case when b.e_id is not null or f.id is not null then 1 else 0 end>0""")})

@app.route('/employerdashboard',methods=['POST'])
def employerdashboard():
	companylist = request.json['c_list']
	allcompany = request.json['allcompany']
	comp = request.json['company']
	print(type(companylist))
	c = list(companylist.split(","))
	if len(c)==0:
		c.append(companylist)
	allc = list(allcompany.split(","))
	
	alllist = ",".join(c)
	print(allc)
	print(c)
	compid=""
	if comp == "All":
		for b in c:
			if(b != "All"):
				compid += str(allc.index(b))+","
				print(compid)
		compid+=str(5)
	else:
		for b in allc:
			if b == comp:
				compid = str(allc.index(b))	
	return  jsonify({"result":getQuery(query="""select Dt as Dy,Onroll,Prsn,Leav,onroll-(prsn+leav) as absn,Late,Early,Ot,case when onroll>0 then cast(round(100.0*prsn/onroll,2) as numeric(15,2)) else 0.00 end as pr_per,
case when onroll>0 then cast(round(100.0*leav/onroll,2) as numeric(15,2)) else 0 end as lv_per,case when onroll>0 then cast(round(100.0*(onroll-(prsn+leav))/onroll,2) as numeric(15,2)) else 0 end as ab_per 
from(select CONVERT(varchar,(convert(date,P_Dt,103)),103) as Dt,count(E_ID) as Onroll,sum(Prsn) as Prsn,sum(leav) as Leav,sum(late) as Late,sum(early) as Early,sum(ot) as Ot from 
(select b.E_ID,convert(date,P_Dt,103) as P_Dt,case when in_ti > 0 then 1 else 0 end as Prsn,case when isnull(In_Ti,0)=0 and isnull(ot_cal,0)=0 and lv_desc=Stat then 1 else 0 end as leav,
a.late as Lt,case when a.late >= 0 or (lt_lv is not null and lt_lv != 'Deduct') or (isnull(f.late_flag,0) = 0 and 
isnull(g.late,0) = 0) then 0 else 1 end as late,a.early as Erl,case when a.early>=0 or (er_lv is not null and er_lv !='Deduct') or (isnull(f.Early_flag,0)=0 and isnull(g.early,0)=0) then 
0 else 1 end as early,case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then case when (E_ot_appr is not null and 
isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else 1 end else 1 end as ot,
case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else m_ot end + case when (E_ot_appr is not null 
and isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else e_ot end as OT_hrs 
from Pay_Emp_Master b INNER JOIN At_Psum a ON b.E_ID = a.E_ID and isnull(a.active,0)=1  INNER JOIN Pay_company_master c ON c.e_company_ID = b.E_comp_ID 
INNER JOIN Pay_Emp_Actul d ON b.E_ID = d.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,d.e_FromDate,103) AND Convert(datetime,d.e_ToDate,103)) or 
(d.e_FromDate <= Convert(datetime,a.P_dt,103) AND d.e_ToDate is null)) inner join Pay_Cat_Master g on g.E_Cat_ID=d.E_Catg INNER JOIN At_Emp f ON b.E_ID = f.E_ID and 
((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,f.Fr_Date,103) AND Convert(datetime,F.To_Date,103)) or (F.Fr_Date <= Convert(datetime,a.P_dt,103) AND F.To_Date is null)) 
left join At_Lev_typ on isnull(At_Lev_typ.active,0)=1 and At_Lev_typ.lv_desc=a.stat and At_Lev_typ.lv_desc !='AB'
where (b.e_dt_of_leav is null or convert(datetime, b.e_dt_of_leav, 103)  >= Convert(datetime, a.P_dt, 103)) AND (convert(datetime, b.e_dt_of_join, 103)  <= 
Convert(datetime,a.P_dt, 103)) and Convert(date,a.P_dt,103) >= DATEADD(dd,-11,getdate()) and Convert(date,a.P_dt,103) <= GETDATE()
and e_company_id in("""+compid+""") ) as t group by convert(date,P_Dt,103)) as st order by convert(date,Dt,103) desc""")})

@app.route('/employerdashboardchart',methods=['POST'])
def employerdashboardchart():
	fromd = request.json['fromdate']
	companylist = request.json['c_list']
	allcompany = request.json['allcompany']
	comp = request.json['company']
	print(type(companylist))
	c = list(companylist.split(","))
	if len(c)==0:
		c.append(companylist)
	allc = list(allcompany.split(","))
	
	alllist = ",".join(c)
	print(allc)
	print(c)
	compid=""
	if comp == "All":
		for b in c:
			if(b != "All"):
				compid += str(allc.index(b))+","
				print(compid)
		compid+=str(5)
	else:
		for b in allc:
			if b == comp:
				compid = str(allc.index(b))	
	return  jsonify({"result":getQuery(query="""select Dt as Dy,Onroll,Prsn,Leav,onroll-(prsn+leav) as absn,Late,Early,Ot,case when onroll>0 then cast(round(100.0*prsn/onroll,2) as numeric(15,2)) else 0.00 end as pr_per,
case when onroll>0 then cast(round(100.0*leav/onroll,2) as numeric(15,2)) else 0 end as lv_per,case when onroll>0 then cast(round(100.0*(onroll-(prsn+leav))/onroll,2) as numeric(15,2)) else 0 end as ab_per 
from(select CONVERT(varchar,(convert(date,P_Dt,103)),103) as Dt,count(E_ID) as Onroll,sum(Prsn) as Prsn,sum(leav) as Leav,sum(late) as Late,sum(early) as Early,sum(ot) as Ot from 
(select b.E_ID,convert(date,P_Dt,103) as P_Dt,case when in_ti > 0 then 1 else 0 end as Prsn,case when isnull(In_Ti,0)=0 and isnull(ot_cal,0)=0 and lv_desc=Stat then 1 else 0 end as leav,
a.late as Lt,case when a.late >= 0 or (lt_lv is not null and lt_lv != 'Deduct') or (isnull(f.late_flag,0) = 0 and 
isnull(g.late,0) = 0) then 0 else 1 end as late,a.early as Erl,case when a.early>=0 or (er_lv is not null and er_lv !='Deduct') or (isnull(f.Early_flag,0)=0 and isnull(g.early,0)=0) then 
0 else 1 end as early,case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then case when (E_ot_appr is not null and 
isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else 1 end else 1 end as ot,
case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else m_ot end + case when (E_ot_appr is not null 
and isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else e_ot end as OT_hrs 
from Pay_Emp_Master b INNER JOIN At_Psum a ON b.E_ID = a.E_ID and isnull(a.active,0)=1  INNER JOIN Pay_company_master c ON c.e_company_ID = b.E_comp_ID 
INNER JOIN Pay_Emp_Actul d ON b.E_ID = d.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,d.e_FromDate,103) AND Convert(datetime,d.e_ToDate,103)) or 
(d.e_FromDate <= Convert(datetime,a.P_dt,103) AND d.e_ToDate is null)) inner join Pay_Cat_Master g on g.E_Cat_ID=d.E_Catg INNER JOIN At_Emp f ON b.E_ID = f.E_ID and 
((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,f.Fr_Date,103) AND Convert(datetime,F.To_Date,103)) or (F.Fr_Date <= Convert(datetime,a.P_dt,103) AND F.To_Date is null)) 
left join At_Lev_typ on isnull(At_Lev_typ.active,0)=1 and At_Lev_typ.lv_desc=a.stat and At_Lev_typ.lv_desc !='AB'
where (b.e_dt_of_leav is null or convert(datetime, b.e_dt_of_leav, 103)  >= Convert(datetime, a.P_dt, 103)) AND (convert(datetime, b.e_dt_of_join, 103)  <= 
Convert(datetime,a.P_dt, 103)) and Convert(date,a.P_dt,103) >= DATEADD(dd,-11,CONVERT(date,'"""+fromd+"""',103)) and Convert(date,a.P_dt,103) <= CONVERT(date,'"""+fromd+"""',103)
and e_company_id in("""+compid+""") ) as t group by convert(date,P_Dt,103)) as st order by convert(date,Dt,103) desc""")})


@app.route('/employee',methods=['POST'])
def employee():
	emp_id = request.json['emp_id']
	print(emp_id)
	return  jsonify({"result":getQuerywithoutdecimal(query="""select E_id,E_Name,Desg,Ab,Spun,Leav,Dur,Late,cast(floor(CASE WHEN DATEADD(MM,DATEDIFF(MONTH,doj,getdate())*-1,getdate()) >= Convert(date,doj,103) THEN 
DATEDIFF(MONTH,doj,getdate()) ELSE DATEDIFF(MONTH,doj,getdate())-1 END /12) as varchar(2))+ ' Yr '+ cast(floor(CASE WHEN DATEADD(MM,DATEDIFF(MONTH,doj,
getdate())*-1,getdate())>=Convert(date,doj,103) THEN DATEDIFF(MONTH,doj,getdate()) ELSE DATEDIFF(MONTH,doj,getdate())-1 END % 12) as varchar(2)) + ' Mon ' as Expr,
CONCAT('', CAST('' as XML).value('xs:base64Binary(sql:column("Photo"))', 'VARCHAR(MAX)')) AS Photo from(select b.E_ID,Max(b.e_name) as E_Name,Max(E_Desig_Name) as Desg,sum(case when stat = 'AB' then 1 else case when stat='AB/P' or stat='P/AB' then .5 
else 0 end end) as Ab,sum(case when stat = 'SP' or (in_ti>0 and in_ti=out_ti) then 1 else 0 end) as SPun,sum(case when isnull(In_Ti,0)= 0 and 
isnull(ot_cal,0)=0 and lv_desc=Stat then 1 else 0 end) as Leav,cast(((floor(sum(out_ti-in_ti)/60)*1.00)+((sum(out_ti-in_ti)%60)/100.)) as numeric(5,2)) as Dur,
cast(((floor(sum(case when a.late >=0 then 0 else a.late end*-1)/60)*1.00)+((sum(case when a.late>=0 then 0 else a.late end*-1)%60)/100.)) as numeric(5,2)) as Late,
max(E_DT_OF_JOIN) as doj from Pay_Emp_Master b INNER JOIN At_Psum a ON b.E_ID = a.E_ID and isnull(a.active,0)=1  
INNER JOIN Pay_Emp_Actul d ON b.E_ID = d.E_ID and d.e_ToDate is null Left JOIN Pay_Desig_Master ON Pay_Desig_Master.E_Desig_ID = d.E_Desg 
left join At_Lev_typ on isnull(At_Lev_typ.active,0)=1 and At_Lev_typ.lv_desc=a.stat and At_Lev_typ.lv_desc !='AB'where b.e_id='"""+emp_id+"""' and 
Convert(date,a.P_dt,103) >= DATEADD(dd,-15,getdate()) and Convert(date,a.P_dt,103) <= GETDATE() group by b.e_id) as st
left join Pay_Emp_Image a on a.emp_id='"""+emp_id+"""'""")})

@app.route('/emp',methods=['POST'])
def currentdt():
	currentdate = request.json['currentdate']
	companylist = request.json['c_list']
	allcompany = request.json['allcompany']
	comp = request.json['company']
	print(type(companylist))
	c = list(companylist.split(","))
	if len(c)==0:
		c.append(companylist)
	allc = list(allcompany.split(","))
	
	alllist = ",".join(c)
	print(allc)
	print(c)
	compid=""
	if comp == "All":
		for b in c:
			if(b != "All"):
				compid += str(allc.index(b))+","
				print(compid)
		compid+=str(5)
	else:
		for b in allc:
			if b == comp:
				compid = str(allc.index(b))
	return  jsonify({"result":getQuery(query="""select ROW_NUMBER() OVER(ORDER BY right('000000000'+e_id,10)) AS Sr_no,e_comp_shortname As Branch,E_ID,E_Name,E_Desig_Name as Desg,convert(varchar,P_Dt,103) as Dt,
case when Stat='' and in_ti>0 then 'P' else stat end as Stat,In_ti,Out_ti,case when dur is null or dur<=0 then 0 else cast(floor(dur/60)+((dur%60)/100.) as numeric(5,2)) end as Dur 
from (select b.E_ID,b.e_name,stat,convert(date,P_Dt,103) as P_Dt,c.e_comp_shortname,e.E_unit_Desc,g.E_Cat_Name,E_Dept_Name,E_Divi_Name,'' as descr,E_Desig_Name,'' 
	as Des_Gr,cast(floor(in_ti/60)+((in_ti%60)/100.) as numeric(5,2)) as in_ti,cast(floor(out_ti/60)+((out_ti%60)/100.) as numeric(5,2)) as out_ti,
	(out_ti-in_ti) as Dur,case when in_ti > 0 then 1 else 0 end as Prsn,case when isnull(In_Ti,0)=0 and isnull(ot_cal,0)=0 and lv_desc=Stat then 1 else 0 end as leav,
	shft,a.late as Lt,case when a.late >= 0 or (lt_lv is not null and lt_lv != 'Deduct') or (isnull(f.late_flag,0) = 0 and 
	isnull(g.late,0) = 0) then 0 else 1 end as late,a.early as Erl,case when a.early>=0 or (er_lv is not null and er_lv !='Deduct') or (isnull(f.Early_flag,0)=0 and isnull(g.early,0)=0) then 
	0 else 1 end as early,case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then case when (E_ot_appr is not null and 
	isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else 1 end else 1 end as ot,
	case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else m_ot end + case when (E_ot_appr is not null 
	and isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else e_ot end as OT_hrs,convert(varchar,convert(date,b.e_dt_of_join,103),103) as Doj 
	from Pay_Emp_Master b INNER JOIN At_Psum a ON b.E_ID = a.E_ID and isnull(a.active,0)=1  INNER JOIN Pay_company_master c ON c.e_company_ID = b.E_comp_ID and b.E_comp_ID in("""+compid+""")
	INNER JOIN Pay_Emp_Actul d ON b.E_ID = d.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,d.e_FromDate,103) AND Convert(datetime,d.e_ToDate,103)) or 
	(d.e_FromDate <= Convert(datetime,a.P_dt,103) AND d.e_ToDate is null)) INNER JOIN Pay_unit_master e ON e.e_unit_id = d.e_unit inner join Pay_Cat_Master g on g.E_Cat_ID=d.E_Catg 
	left join Pay_Divi_Master on Pay_Divi_Master.E_Divi_ID = d.E_Division INNER JOIN At_Emp f ON b.E_ID = f.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,f.Fr_Date,103) AND 
	Convert(datetime,F.To_Date,103)) or (F.Fr_Date <= Convert(datetime,a.P_dt,103) AND F.To_Date is null)) 
	left JOIN Pay_Dept_Master ON Pay_Dept_Master.E_Dept_ID = d.E_Dept Left JOIN Pay_Desig_Master ON Pay_Desig_Master.E_Desig_ID = d.E_Desg 
	left join At_Lev_typ on isnull(At_Lev_typ.active,0)=1 and At_Lev_typ.lv_desc=a.stat and At_Lev_typ.lv_desc !='AB'
	where (b.e_dt_of_leav is null or convert(datetime, b.e_dt_of_leav, 103)  >= Convert(datetime, a.P_dt, 103)) AND (convert(datetime, b.e_dt_of_join, 103)  <= 
	Convert(datetime,a.P_dt, 103)) and Convert(date,a.P_dt,103) = Convert(date,'"""+str(currentdate)+"""',103)) as t order by right('000000000'+e_id,10)
	""")})

@app.route('/dt',methods=['POST'])
def emp():
	empid = request.json['empid']
	fromd = request.json['fromdate']
	tod = request.json['todate']
	return  jsonify({"result":getQuery(query="""select ROW_NUMBER() OVER(ORDER BY E_ID) AS Sr_no,e_comp_shortname As Branch,E_ID,E_Name,E_Desig_Name as Desg,convert(varchar,P_Dt,103) as Dt,
	case when Stat='' and in_ti>0 then 'P' else stat end as Stat,In_ti,Out_ti,case when dur is null or dur<=0 then 0 else cast(floor(dur/60)+((dur%60)/100.) as numeric(5,2)) end as Dur 
	from (select b.E_ID,b.e_name,stat,convert(date,P_Dt,103) as P_Dt,c.e_comp_shortname,e.E_unit_Desc,g.E_Cat_Name,E_Dept_Name,E_Divi_Name,'' as descr,E_Desig_Name,'' 
	as Des_Gr,cast(floor(in_ti/60)+((in_ti%60)/100.) as numeric(5,2)) as in_ti,cast(floor(out_ti/60)+((out_ti%60)/100.) as numeric(5,2)) as out_ti,
	(out_ti-in_ti) as Dur,case when in_ti > 0 then 1 else 0 end as Prsn,case when isnull(In_Ti,0)=0 and isnull(ot_cal,0)=0 and lv_desc=Stat then 1 else 0 end as leav,
	shft,a.late as Lt,case when a.late >= 0 or (lt_lv is not null and lt_lv != 'Deduct') or (isnull(f.late_flag,0) = 0 and 
	isnull(g.late,0) = 0) then 0 else 1 end as late,a.early as Erl,case when a.early>=0 or (er_lv is not null and er_lv !='Deduct') or (isnull(f.Early_flag,0)=0 and isnull(g.early,0)=0) then 
	0 else 1 end as early,case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then case when (E_ot_appr is not null and 
	isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else 1 end else 1 end as ot,
	case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else m_ot end + case when (E_ot_appr is not null 
	and isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else e_ot end as OT_hrs,convert(varchar,convert(date,b.e_dt_of_join,103),103) as Doj 
	from Pay_Emp_Master b INNER JOIN At_Psum a ON b.E_ID = a.E_ID and isnull(a.active,0)=1  INNER JOIN Pay_company_master c ON c.e_company_ID = b.E_comp_ID 
	INNER JOIN Pay_Emp_Actul d ON b.E_ID = d.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,d.e_FromDate,103) AND Convert(datetime,d.e_ToDate,103)) or 
	(d.e_FromDate <= Convert(datetime,a.P_dt,103) AND d.e_ToDate is null)) INNER JOIN Pay_unit_master e ON e.e_unit_id = d.e_unit inner join Pay_Cat_Master g on g.E_Cat_ID=d.E_Catg 
	left join Pay_Divi_Master on Pay_Divi_Master.E_Divi_ID = d.E_Division INNER JOIN At_Emp f ON b.E_ID = f.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,f.Fr_Date,103) AND 
	Convert(datetime,F.To_Date,103)) or (F.Fr_Date <= Convert(datetime,a.P_dt,103) AND F.To_Date is null)) 
	left JOIN Pay_Dept_Master ON Pay_Dept_Master.E_Dept_ID = d.E_Dept Left JOIN Pay_Desig_Master ON Pay_Desig_Master.E_Desig_ID = d.E_Desg 
	left join At_Lev_typ on isnull(At_Lev_typ.active,0)=1 and At_Lev_typ.lv_desc=a.stat and At_Lev_typ.lv_desc !='AB'
	where (b.e_dt_of_leav is null or convert(datetime, b.e_dt_of_leav, 103)  >= Convert(datetime, a.P_dt, 103)) AND (convert(datetime, b.e_dt_of_join, 103)  <= 
	Convert(datetime,a.P_dt, 103)) and Convert(date,a.P_dt,103) >= Convert(date,'"""+str(fromd)+"""',103) and Convert(date,a.P_dt,103) <= Convert(date,'"""+str(tod)+"""',103) 
	and b.e_id in('"""+str(empid)+"""')) as t order by convert(date,p_dt,103)""")})

@app.route('/idsearch',methods=['POST'])
def idsearch():
	empid = request.json['empid']
	fromd = request.json['fromdate']
	tod = request.json['todate']
	return  jsonify({"result":getQuery(query="""select ROW_NUMBER() OVER(ORDER BY E_ID) AS Sr_no,e_comp_shortname As Branch,E_ID,E_Name,E_Desig_Name as Desg,convert(varchar,P_Dt,103) as Dt,
	case when Stat='' and in_ti>0 then 'P' else stat end as Stat,In_ti,Out_ti,case when dur is null or dur<=0 then 0 else cast(floor(dur/60)+((dur%60)/100.) as numeric(5,2)) end as Dur 
	from (select b.E_ID,b.e_name,stat,convert(date,P_Dt,103) as P_Dt,c.e_comp_shortname,e.E_unit_Desc,g.E_Cat_Name,E_Dept_Name,E_Divi_Name,'' as descr,E_Desig_Name,'' 
	as Des_Gr,cast(floor(in_ti/60)+((in_ti%60)/100.) as numeric(5,2)) as in_ti,cast(floor(out_ti/60)+((out_ti%60)/100.) as numeric(5,2)) as out_ti,
	(out_ti-in_ti) as Dur,case when in_ti > 0 then 1 else 0 end as Prsn,case when isnull(In_Ti,0)=0 and isnull(ot_cal,0)=0 and lv_desc=Stat then 1 else 0 end as leav,
	shft,a.late as Lt,case when a.late >= 0 or (lt_lv is not null and lt_lv != 'Deduct') or (isnull(f.late_flag,0) = 0 and 
	isnull(g.late,0) = 0) then 0 else 1 end as late,a.early as Erl,case when a.early>=0 or (er_lv is not null and er_lv !='Deduct') or (isnull(f.Early_flag,0)=0 and isnull(g.early,0)=0) then 
	0 else 1 end as early,case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then case when (E_ot_appr is not null and 
	isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else 1 end else 1 end as ot,
	case when (M_ot_appr is not null and isnull(M_ot_appr,0)=0) or m_ot=0 or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else m_ot end + case when (E_ot_appr is not null 
	and isnull(E_ot_appr,0)=0) or e_ot=0  or (isnull(f.ot_flag,0)=0 and isnull(g.ot,0)=0) then 0 else e_ot end as OT_hrs,convert(varchar,convert(date,b.e_dt_of_join,103),103) as Doj 
	from Pay_Emp_Master b INNER JOIN At_Psum a ON b.E_ID = a.E_ID and isnull(a.active,0)=1  INNER JOIN Pay_company_master c ON c.e_company_ID = b.E_comp_ID 
	INNER JOIN Pay_Emp_Actul d ON b.E_ID = d.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,d.e_FromDate,103) AND Convert(datetime,d.e_ToDate,103)) or 
	(d.e_FromDate <= Convert(datetime,a.P_dt,103) AND d.e_ToDate is null)) INNER JOIN Pay_unit_master e ON e.e_unit_id = d.e_unit inner join Pay_Cat_Master g on g.E_Cat_ID=d.E_Catg 
	left join Pay_Divi_Master on Pay_Divi_Master.E_Divi_ID = d.E_Division INNER JOIN At_Emp f ON b.E_ID = f.E_ID and ((Convert(datetime,a.P_dt,103) BETWEEN Convert(datetime,f.Fr_Date,103) AND 
	Convert(datetime,F.To_Date,103)) or (F.Fr_Date <= Convert(datetime,a.P_dt,103) AND F.To_Date is null)) 
	left JOIN Pay_Dept_Master ON Pay_Dept_Master.E_Dept_ID = d.E_Dept Left JOIN Pay_Desig_Master ON Pay_Desig_Master.E_Desig_ID = d.E_Desg 
	left join At_Lev_typ on isnull(At_Lev_typ.active,0)=1 and At_Lev_typ.lv_desc=a.stat and At_Lev_typ.lv_desc !='AB'
	where (b.e_dt_of_leav is null or convert(datetime, b.e_dt_of_leav, 103)  >= Convert(datetime, a.P_dt, 103)) AND (convert(datetime, b.e_dt_of_join, 103)  <= 
	Convert(datetime,a.P_dt, 103)) and Convert(date,a.P_dt,103) >= Convert(date,'"""+str(fromd)+"""',103) and Convert(date,a.P_dt,103) <= Convert(date,'"""+str(tod)+"""',103) 
	and b.e_id in('"""+str(empid)+"""')) as t order by convert(date,p_dt,103)""")})

if __name__ == "__main__":
    app.run(debug=True)