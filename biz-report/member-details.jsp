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
private String getCmdparam(String type,String c_store_id,String c_vip_id){
	String cmdparam="";
	if(type.equals("wardrobe")){
			cmdparam="{\r\n" + 
				" \"table\":APP_VIPFTP,\r\n" + 
				" \"columns\":[\"BILLDATE\",\"C_STORE_ID;NAME\",\"PDTNAME\",\"DIMNAME\",\"TOT_AMT\"],\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" expr2:{\"column\":\"C_VIP_ID\",\"condition\":"+c_vip_id+"}\r\n" + 
				" }\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("data")){
			cmdparam=cmdparam="{\r\n" + 
				"\"table\":APP_VIPANS02,\r\n" + 
				"\"columns\":[\"CARDNO\",\"VIPNAME\",\"LASTVDATE\",\"MOBILE\",\"INTEGRAL\",\"AMOUNT\",\"RFMTYPE\",\"BUY_RATE\",\"BUY_AMT\",\"LASTDATE\",\"DORMANTDAYS\",\"C_VIPTYPE_ID;NAME\",\"HR_EMPLOYEE_ID;NAME\"],\r\n" + 
				"\"params\":{\r\n" + 
				"\"combine\":and,\r\n" + 
				"\"expr1\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				"\"expr2\":{\"column\":\"c_vip_id\",\"condition\":"+c_vip_id+"}\r\n" + 
				"},\r\n" + 
				"\"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("liveness")){
			cmdparam="{\r\n" + 
				" \"table\":APP_MONVIP01,\r\n" + 
				" \"columns\":[\"YEARQ\",\"TOT_AMT\"],\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" expr2:{\"column\":\"C_VIP_ID\",\"condition\":"+c_vip_id+"}\r\n" + 
				" },\r\n" + 
				"\"orderby\":[{\"column\":\"YEARQ\",\"asc\":true}]\r\n" + 
				"}";
	}
	return cmdparam;
}
%>

<%
try {
	//--------会员-----
	JSONObject hy=new JSONObject();

	//--------会员下面的data
	JSONObject data_hy=new JSONObject();

	//--------会员下面的data下面的wardrobe
	List<JSONObject> wardrobe=new ArrayList<JSONObject>();
	
	//--------会员下面的data下面的liveness
	List<JSONObject> liveness=new ArrayList<JSONObject>();

	//--------会员data下面的data里面的JSONObject
	JSONObject data_data_json=new JSONObject();

	//--------会员data下面的wardrobe里面的JSONObject
	JSONObject data_wardrobe_json=new JSONObject();

	//--------会员data下面的wardrobe里面的JSONObject
	JSONObject data_liveness_json=new JSONObject();

	//---------------------------------------------查询会员总信息

		String command="Query";                   //Query指令
		String c_store_id=request.getParameter("shop_id");
		if(c_store_id==null||c_store_id.equals("")){
			JSONObject err_4=new JSONObject();
				err_4.put("status",4);
				err_4.put("message","请求参数为空");
				out.print(err_4);
				return;
		}
		
		String c_vip_id=request.getParameter("member_id");
		if(c_vip_id==null||c_vip_id.equals("")){
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
		if(m==null||m.equals("")){
			JSONObject err_6=new JSONObject();
				err_6.put("status",6);
				err_6.put("message","请求账号或者密码为空");
				out.print(err_6);
				return;
		}
		//String m_md5=MD5(m);                         //账号密码
		ValueHolder vh= null;
		JSONArray ja=null;
		SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
		sdf.setLenient(false);
		String tt= sdf.format(new Date());
		HashMap<String, String> params =new HashMap<String, String>();
		params.put("sip_appkey",sipKey);
		params.put("sip_timestamp", tt);
		params.put("sip_sign",MD5(sipKey+tt+m));
		JSONObject tra=new JSONObject();
		tra.put("id", 112);
		tra.put("command",command);
		tra.put("nds.control.ejb.UserTransaction","Y");
		tra.put("params",  new JSONObject(getCmdparam("wardrobe",c_store_id,c_vip_id)));
		ja=new JSONArray();
		ja.put(tra);
		params.put("transactions", ja.toString());
		vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
		
		if(vh!=null){
			if(new Integer(vh.get("code").toString())!=0){
				JSONObject err_1=new JSONObject();
				err_1.put("status",1);
				err_1.put("message","查询异常");
				out.print(err_1);
				return;
			}else{
				String rel=vh.get("message").toString();
				int index_1=rel.indexOf("{");
				rel=rel.substring(index_1,rel.length()-1);
				JSONObject jesonRows=new JSONObject(rel);
				JSONArray rows_0=jesonRows.getJSONArray("rows");
				if(rows_0.length()==0){
					hy.put("status",0);
					hy.put("data",data_hy);
					out.print(hy);
					return;
				}
				String datas_1=vh.get("message").toString();
				int index=datas_1.indexOf("{");
				datas_1=datas_1.substring(index,datas_1.length()-1);
				JSONObject jesonObjectRows=new JSONObject(datas_1);
				JSONArray rows=jesonObjectRows.getJSONArray("rows");
				JSONArray jsonArray_3;
				for(int c=0;c<rows.length();c++){
					jsonArray_3=(JSONArray)rows.get(c);
					data_wardrobe_json=new JSONObject();
					
						int billdate=new Integer(jsonArray_3.get(0).toString());
						data_wardrobe_json.put("c1",billdate);
						
						String storeName=jsonArray_3.get(1).toString();
						data_wardrobe_json.put("c2",storeName);
						
						String pdtName=jsonArray_3.get(2).toString();
						data_wardrobe_json.put("c3",pdtName);
						
						String dimName=jsonArray_3.get(3).toString();
						data_wardrobe_json.put("c4",dimName);
						
						double totAmt=new Double(jsonArray_3.get(4).toString());
						data_wardrobe_json.put("c5",totAmt);
						
					wardrobe.add(data_wardrobe_json);
				}
				data_hy.put("consumptionList",wardrobe);
			}
		}else{
					JSONObject err_3=new JSONObject();
					err_3.put("status",3);
					err_3.put("message","请求异常");
					out.print(err_3);
		}
		//-----------------------------------------------查询所有会员
		tra.put("params",  new JSONObject(getCmdparam("data",c_store_id,c_vip_id)));
			ja.put(tra);
			params.put("transactions", ja.toString());
			vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
			
		if(vh!=null){
			if(new Integer(vh.get("code").toString())!=0){
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
				String datas_2=vh.get("message").toString();
				int index_3=datas_2.indexOf("{");
				datas_2=datas_2.substring(index_3,datas_2.length()-1);
				JSONObject jesonRows_3=new JSONObject(datas_2);
				JSONArray rows_2=jesonRows_3.getJSONArray("rows");
				JSONArray jsonArray_1;
				for(int b=0;b<rows_2.length();b++){
					jsonArray_1=(JSONArray)rows_2.get(b);
					data_data_json=new JSONObject();

						String cardno=jsonArray_1.get(0).toString();
						data_data_json.put("c1",cardno);
						
						String vipname=jsonArray_1.get(1).toString();
						data_data_json.put("c2",vipname);
						
						Object obj1=(Object)jsonArray_1.get(2);
						if(obj1.equals(null)){
							data_data_json.put("c9","无");
					    }else{
					    	String lastvdate=obj1.toString();
					    	data_data_json.put("c9",lastvdate);
					    }
						
						String mobile=jsonArray_1.get(3).toString();
						data_data_json.put("c4",mobile);
						
						int integral=new Integer(jsonArray_1.get(4).toString());
						data_data_json.put("c10",integral);
						
						double amount=new Double(jsonArray_1.get(5).toString());
						data_data_json.put("c11",amount);
						
						int rfmtype=new Integer(jsonArray_1.get(6).toString());
						data_data_json.put("c4",rfmtype);
						
						double buy_rate=new Double(jsonArray_1.get(7).toString());
						data_data_json.put("c7",buy_rate);
						
						double buy_amt=new Double(jsonArray_1.get(8).toString());
						data_data_json.put("c8",buy_amt);
						
						Object obj=(Object)jsonArray_1.get(9);
						if(obj.equals(null)){
							data_data_json.put("c5",0);
						}else{
							String lastdate=obj.toString();
							data_data_json.put("c5",lastdate);
						}
						
						int dormancyDays=new Integer(jsonArray_1.get(10).toString());
						data_data_json.put("c6",dormancyDays);
						
						String cardtype=jsonArray_1.get(11).toString();
						data_data_json.put("c3",cardtype);
						
						Object obj2=(Object)jsonArray_1.get(12);
						if(obj2.equals(null)){
							data_data_json.put("c12","无");
					    }else{
					    	String hr_employee_name=obj2.toString();
					    	data_data_json.put("c12",hr_employee_name);
					    }
				}
				data_hy.put("info",data_data_json);
			}
		}else{
					JSONObject err_3=new JSONObject();
					err_3.put("status",3);
					err_3.put("message","请求异常");
					out.print(err_3);
		}
		//--------------------------------------------------查询会员饼图
		
		tra.put("params",new JSONObject(getCmdparam("liveness",c_store_id,c_vip_id)));
			ja.put(tra);
			params.put("transactions", ja.toString());
			vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
			
		if(vh!=null){
			if(new Integer(vh.get("code").toString())!=0){
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
				String datas_3=vh.get("message").toString();
				int index_4=datas_3.indexOf("{");
				datas_3=datas_3.substring(index_4,datas_3.length()-1);
				JSONObject jesonRows_4=new JSONObject(datas_3);
				JSONArray rows_4=jesonRows_4.getJSONArray("rows");
				JSONArray jsonArray_2;
				for(int b=0;b<rows_4.length();b++){
					jsonArray_2=(JSONArray)rows_4.get(b);
					data_liveness_json=new JSONObject();
					
						String x=jsonArray_2.get(0).toString();
						data_liveness_json.put("x",x);
						
						double y=new Double(jsonArray_2.get(1).toString());
						data_liveness_json.put("y",y);
						
					liveness.add(data_liveness_json);
				}
				data_hy.put("chart",liveness);
			}
		}else{
			JSONObject err_3=new JSONObject();
			err_3.put("status",3);
			err_3.put("message","请求异常");
			out.print(err_3);
		}
		//-------------拼接结果------------
		hy.put("status",0);
		hy.put("data",data_hy);
		out.print(hy);
	} catch (Exception e) {
		JSONObject err_5=new JSONObject();
		err_5.put("status",5);
		err_5.put("message","程序异常");
		out.print(err_5);
		return;
	}
%>
