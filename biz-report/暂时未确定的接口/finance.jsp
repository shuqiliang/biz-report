<%@ page language="java"
	import="nds.rest.*,org.json.*,java.net.*,java.io.*,java.security.MessageDigest"
	pageEncoding="utf-8"%>
<%@ include file="/html/nds/common/init.jsp"%>
<%@page errorPage="/html/nds/error.jsp"%>
<%!
public String MD5(String s){
	String r="";
	try{
		MessageDigest md = MessageDigest.getInstance("MD5"); 
		md.update(s.getBytes());
		byte b[]=md.digest();	
		int i;
		StringBuffer buf = new StringBuffer("");
		for (int offset = 0; offset < b.length; offset++) { 
			i = b[offset]; 
			if(i<0) i+= 256; 
			if(i<16) 
			buf.append("0"); 
			buf.append(Integer.toHexString(i)); 
		}
		r=buf.toString();
	}catch(Exception e){	
	}
	return r;
}
%>
<%!
private String getCmdparam(String type,String shop_id){
	String cmdparam="";
	if(type.equals("retail")){
			cmdparam="{\r\n" + 
				" \"table\":22874,\r\n" + 
				" \"columns\":[\"BILLTYPE\",\"AMT\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+shop_id+"}\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("supplier")){
			cmdparam="{\r\n" + 
				" \"table\":22875,\r\n" + 
				" \"columns\":[\"BILLTYPE\",\"AMT\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+shop_id+"}\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("lianying")){
			cmdparam="{\r\n" + 
				" \"table\":22876,\r\n" + 
				" \"columns\":[\"BILLTYPE\",\"AMT\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+shop_id+"}\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("yusuan")){
			cmdparam="{\r\n" + 
				" \"table\":22877,\r\n" + 
				" \"columns\":[\"RETAILAMT\",\"CUSAMT\",\"SUPAMT\",\"LYAMT\",\"AMTCZ\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+shop_id+"}\r\n" + 
				"}";
			return cmdparam;
	}
	return cmdparam;
}
%>
<%
	//-----------财务cx  JSONObject------
	JSONObject cw=new JSONObject();
	
	//-----------财务下面的data  JSONObject------
	JSONObject cw_data=new JSONObject();
	
	//-----------财务下面的data下面的income JSONObject------
	JSONObject income_json=new JSONObject();
	
	//-----------财务下面的data下面的expenses JSONObject
	JSONObject expenses_json=new JSONObject();
	
	//-----------财务下面的data下面的netIncome
	double netIncome=0;
	
	//-----------财务下面的data下面的budget JSONObject
	JSONObject budget_json=new JSONObject();
	
	//-----------财务下面的data下面的deficit
	double deficit=0;
	
	//-----------财务下面的data下面的incomeBar List
	List<JSONObject> data_incomeBar=new ArrayList<JSONObject>();
	
	//-----------财务下面的data下面的incomeBar下面的json JSONObject
	JSONObject incomeBar_json=new JSONObject();
	
	//-----------财务下面的data下面的income下面的合计 double
	double total_income=0;
	
	//-----------财务下面的data下面的expenses
	double total_expenses=0;
	
	//-----------财务下面的data下面的expenses下面的供应商合计 double
	double total_1=0;
	
	//-----------财务下面的data下面的expenses下面的联营商合计 double
	double total_2=0;
	
	String c_store_id=request.getParameter("shop_id");
	if(c_store_id==null||c_store_id.equals("")){
		JSONObject err_4=new JSONObject();
			err_4.put("status",4);
			err_4.put("message","请求参数为空");
			out.print(err_4);
			return;
	}
	String sipKey=request.getParameter("username");   //权限账号
	if(sipKey==null||sipKey.equals("")){
		JSONObject err_6=new JSONObject();
			err_6.put("status",6);
			err_6.put("message","请求账号或者密码为空");
			out.print(err_6);
			return;
	}
	String m=request.getParameter("password");
	if(sipKey==null||sipKey.equals("")){
		JSONObject err_6=new JSONObject();
			err_6.put("status",6);
			err_6.put("message","请求账号或者密码为空");
			out.print(err_6);
			return;
	}
	//String m_md5=MD5(m);                            //账号密码
	//-----------------------APP财务-当日零售
	String command="Query";                         //Query指令    
	ValueHolder vh= null;
	JSONArray ja=null;
	SimpleDateFormat a=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	a.setLenient(false);
	String tt= a.format(new Date());
	HashMap<String, String> params =new HashMap<String, String>();
	params.put("sip_appkey",sipKey);
	params.put("sip_timestamp", tt);
	params.put("sip_sign",MD5(sipKey+tt+m));
	JSONObject tra=new JSONObject();
	tra.put("id", 112);
	tra.put("command",command);
	tra.put("nds.control.ejb.UserTransaction","Y");
	tra.put("params",  new JSONObject(getCmdparam("retail",c_store_id)));
	ja=new JSONArray();
	ja.put(tra);
	params.put("transactions", ja.toString());
	vh=RestUtils.sendRequest("http://localhost:90/servlets/binserv/Rest", params,"POST");
	
	if(vh!=null){
			if(!vh.get("code").toString().equals("0")){
				JSONObject err_1=new JSONObject();
				err_1.put("status",1);
				err_1.put("message","查询异常");
				out.print(err_1);
				return;
			}else{
				String rel_2=vh.get("message").toString();
				int index_3=rel_2.indexOf("{");
				rel_2=rel_2.substring(index_3,rel_2.length()-1);
				JSONObject jesonRows_3=new JSONObject(rel_2);
				JSONArray rows_3=jesonRows_3.getJSONArray("rows");
				if(rows_3.length()==0){
					JSONObject err_2=new JSONObject();
					err_2.put("status",2);
					err_2.put("message","暂无数据");
					out.print(err_2);
					return;
				}
			String datas=vh.get("message").toString();
			try {
				int index=datas.indexOf("{");
				datas=datas.substring(index,datas.length()-1);
				JSONArray rows;
				JSONObject jesonObjectRows;
					jesonObjectRows = new JSONObject(datas);
					rows=jesonObjectRows.getJSONArray("rows");
					JSONArray jsonArray;
					for(int b=0;b<rows.length();b++){
						income_json=new JSONObject();
						jsonArray=(JSONArray)rows.get(b);
						
							String billtype=jsonArray.get(0).toString();
							
							double amt=new Double(jsonArray.get(1).toString());
							total_income=total_income+amt;
							if(billtype.equals("现金")){
								income_json.put("c1",amt);
							}else if(billtype.equals("刷卡")){
								income_json.put("c2",amt);
							}else if(billtype.equals("支付宝")){
								income_json.put("c3",amt);
							}else if(billtype.equals("微信")){
								income_json.put("c4",amt);
							}
					}
					income_json.put("c5",total_income);
					cw_data.put("income",income_json);
				} catch (Exception e) {
					JSONObject err_5=new JSONObject();
					err_5.put("status",5);
					err_5.put("message","程序异常");
					out.print(err_5);
					return;
				}
			}
		}else{
			JSONObject err_3=new JSONObject();
			err_3.put("status",3);
			err_3.put("message","请求异常");
			out.print(err_3);
			return;
		}
		//-----------------------APP财务-当日供应商
	tra.put("params",  new JSONObject(getCmdparam("supplier",c_store_id)));
		ja.put(tra);
		params.put("transactions", ja.toString());
		vh=RestUtils.sendRequest("http://localhost:90/servlets/binserv/Rest", params,"POST");
		if(vh!=null){
		if(!vh.get("code").toString().equals("0")){
			JSONObject err_1=new JSONObject();
			err_1.put("status",1);
			err_1.put("message","查询异常");
			out.print(err_1);
			return;
		}else{
			String rel_1=vh.get("message").toString();
			int index_2=rel_1.indexOf("{");
			rel_1=rel_1.substring(index_2,rel_1.length()-1);
			JSONObject jesonRows_2=new JSONObject(rel_1);
			JSONArray rows_1=jesonRows_2.getJSONArray("rows");
			if(rows_1.length()==0){
				JSONObject err_2=new JSONObject();
				err_2.put("status",2);
				err_2.put("message","暂无数据");
				out.print(err_2);
				return;
			}
			String datas_2=vh.get("message").toString();
			int index_3=datas_2.indexOf("{");
			datas_2=datas_2.substring(index_3,datas_2.length()-1);
			JSONObject jesonRows_3=new JSONObject(datas_2);
			JSONArray rows_2=jesonRows_3.getJSONArray("rows");
			JSONArray jsonArray_1;
			for(int d=0;d<rows_2.length();d++){
				jsonArray_1=(JSONArray)rows_2.get(d);
				
					String billtype=jsonArray_1.get(0).toString();
					
					double amt=new Double(jsonArray_1.get(1).toString());
					total_1=total_1+amt;
					if(billtype.equals("货款")){
						expenses_json.put("c1",amt);
					}else if(billtype.equals("其他")){
						expenses_json.put("c2",amt);
					}else if(billtype.equals("分成结算")){
						expenses_json.put("c3",amt);
					}else if(billtype.equals("其他")){
						expenses_json.put("c4",amt);
					}
				
			}
		}
	}else{
				JSONObject err_3=new JSONObject();
				err_3.put("status",3);
				err_3.put("message","请求异常");
				out.print(err_3);
				return;
	}
	//------------------------APP财务-当日联营商
	tra.put("params",  new JSONObject(getCmdparam("lianying",c_store_id)));
		ja.put(tra);
		params.put("transactions", ja.toString());
		vh=RestUtils.sendRequest("http://localhost:90/servlets/binserv/Rest", params,"POST");
		if(vh!=null){
		if(!vh.get("code").toString().equals("0")){
			JSONObject err_1=new JSONObject();
			err_1.put("status",1);
			err_1.put("message","查询异常");
			out.print(err_1);
			return;
		}else{
			String rel_1=vh.get("message").toString();
			int index_2=rel_1.indexOf("{");
			rel_1=rel_1.substring(index_2,rel_1.length()-1);
			JSONObject jesonRows_2=new JSONObject(rel_1);
			JSONArray rows_1=jesonRows_2.getJSONArray("rows");
			if(rows_1.length()==0){
				JSONObject err_2=new JSONObject();
				err_2.put("status",2);
				err_2.put("message","暂无数据");
				out.print(err_2);
				return;
			}
			String datas_2=vh.get("message").toString();
			int index_3=datas_2.indexOf("{");
			datas_2=datas_2.substring(index_3,datas_2.length()-1);
			JSONObject jesonRows_3=new JSONObject(datas_2);
			JSONArray rows_2=jesonRows_3.getJSONArray("rows");
			JSONArray jsonArray_1;
			for(int d=0;d<rows_2.length();d++){
				jsonArray_1=(JSONArray)rows_2.get(d);
				for(int e=0;e<jsonArray_1.length();e++){
					String billtype=jsonArray_1.get(0).toString();
					
					double amt=new Double(jsonArray_1.get(1).toString());
					total_2=total_2+amt;
					if(billtype.equals("货款")){
						expenses_json.put("c1",amt);
					}else if(billtype.equals("其他")){
						expenses_json.put("c2",amt);
					}else if(billtype.equals("分成结算")){
						expenses_json.put("c3",amt);
					}else if(billtype.equals("其他")){
						expenses_json.put("c4",amt);
					}
				}
			}
			expenses_json.put("c5",total_1+total_2);
			cw_data.put("expenses",expenses_json);
		}
	}else{
			JSONObject err_3=new JSONObject();
			err_3.put("status",3);
			err_3.put("message","请求异常");
			out.print(err_3);
			return;
	}
	
	total_expenses=total_1+total_2;
	netIncome=total_income-total_expenses;
	cw_data.put("netIncome",netIncome);
	
	//---------------------APP财务-本周预算
	tra.put("params",  new JSONObject(getCmdparam("yusuan",c_store_id)));
		ja.put(tra);
		params.put("transactions", ja.toString());
		vh=RestUtils.sendRequest("http://localhost:90/servlets/binserv/Rest", params,"POST");
		if(vh!=null){
		if(!vh.get("code").toString().equals("0")){
			JSONObject err_1=new JSONObject();
			err_1.put("status",1);
			err_1.put("message","查询异常");
			out.print(err_1);
			return;
		}else{
			String rel_1=vh.get("message").toString();
			int index_2=rel_1.indexOf("{");
			rel_1=rel_1.substring(index_2,rel_1.length()-1);
			JSONObject jesonRows_2=new JSONObject(rel_1);
			JSONArray rows_1=jesonRows_2.getJSONArray("rows");
			if(rows_1.length()==0){
				JSONObject err_2=new JSONObject();
				err_2.put("status",2);
				err_2.put("message","暂无数据");
				out.print(err_2);
				return;
			}
			String datas_2=vh.get("message").toString();
			int index_3=datas_2.indexOf("{");
			datas_2=datas_2.substring(index_3,datas_2.length()-1);
			JSONObject jesonRows_3=new JSONObject(datas_2);
			JSONArray rows_2=jesonRows_3.getJSONArray("rows");
			String rows_2_str=rows_2.toString();
			rows_2_str=rows_2_str.substring(2, rows_2_str.length()-2);
			String[] result=rows_2_str.split(",");
			budget_json.put("c1",new Double(result[0]));
			budget_json.put("c2",new Double(result[1]));
			budget_json.put("c3",new Double(result[2]));
			budget_json.put("c4",new Double(result[3]));
			deficit=new Double(result[4]);
			
			incomeBar_json=new JSONObject();
			incomeBar_json.put("x","零售收入");
			incomeBar_json.put("y",new Double(result[0]));
			data_incomeBar.add(incomeBar_json);
				
			incomeBar_json=new JSONObject();
			incomeBar_json.put("x","经销商回款");
			incomeBar_json.put("y",new Double(result[1]));
			data_incomeBar.add(incomeBar_json);
			
			incomeBar_json=new JSONObject();
			incomeBar_json.put("x","供应商付款");
			incomeBar_json.put("y",new Double(result[2]));
			data_incomeBar.add(incomeBar_json);
			
			incomeBar_json=new JSONObject();
			incomeBar_json.put("x","联营分成");
			incomeBar_json.put("y",new Double(result[3]));
			data_incomeBar.add(incomeBar_json);
			
			cw_data.put("budget",budget_json);
			cw_data.put("incomeBar",data_incomeBar);
			cw_data.put("deficit",deficit);
			
			cw.put("status",0);
			cw.put("data",cw_data);
			out.print(cw);
		}
	}else{
			JSONObject err_3=new JSONObject();
			err_3.put("status",3);
			err_3.put("message","请求异常");
			out.print(err_3);
			return;
	}
%>
