<%@ page language="java"
	import="nds.rest.*,org.json.*,java.net.*,java.io.*,java.security.MessageDigest"
	pageEncoding="utf-8"%>
<%@ include file="/html/nds/common/init.jsp"%>
<%@page errorPage="/html/nds/error.jsp"%>
<%!
private String MD5(String s){
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
private String getCmdparam(String type,String c_store_id){
	String cmdparam="";
	if(type.equals("summary")){
			cmdparam="{\r\n" + 
				" \"table\":APP_YJANS01,\r\n" + 
				" \"columns\":[\"RANGES\",\"TODAYS\",\"YESTERDAYS\",\"WEEKS\",\"MONTHS\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"}\r\n" + 
				"}";                         
			return cmdparam;
	}else if(type.equals("hour")){
			cmdparam="{\r\n" + 
			" \"table\":APP_YJANS_HH,\r\n" + 
			" \"columns\":[\"HOURS\",\"AMTYJ\"],\r\n" + 
			" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"\r\n" + 
			" },\r\n" + 
			"\"orderby\":[{\"column\":\"HOURS\",\"asc\":true}]\r\n" + 
			"}";
			return cmdparam;
	}
	return cmdparam;
}
%>
<%
	try{
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
		if(m==null||m.equals("")){
			JSONObject err_6=new JSONObject();
				err_6.put("status",6);
				err_6.put("message","请求账号或者密码为空");
				out.print(err_6);
				return;
		}

		String command="Query";                        //Query指令
		JSONObject performance=new JSONObject();
		JSONObject performance_data = new JSONObject();
		List<JSONObject> data=new ArrayList<JSONObject>();
		List<JSONObject> chart = new ArrayList<JSONObject>();
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
			tra.put("params",new JSONObject(getCmdparam("summary",c_store_id)));
			ja=new JSONArray();
			ja.put(tra);
			params.put("transactions", ja.toString());
			vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
			//------------------------------------------------
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
						performance.put("status",0);
					    performance_data.put("infos",data);
					    performance_data.put("chart",chart);
				        performance.put("data",performance_data);
				        out.print(performance);
						return;
					}
					String datas_3=vh.get("message").toString();
					int index_4=datas_3.indexOf("{");
					datas_3=datas_3.substring(index_4,datas_3.length()-1);
					JSONObject jesonRows_4=new JSONObject(datas_3);
					JSONArray rows_4=jesonRows_4.getJSONArray("rows");
					JSONArray jsonArray;
					data=new ArrayList<JSONObject>();
					for(int i=0;i<rows_4.length();i++){
						jsonArray=(JSONArray) rows_4.get(i);
						JSONObject data_item=new JSONObject();
							String c1=jsonArray.get(0).toString();
							data_item.put("c1",c1);

							double c2=new Double(jsonArray.get(1).toString());
							data_item.put("c2",c2);

							double c3=new Double(jsonArray.get(2).toString());
							data_item.put("c3",c3);

							double c4=new Double(jsonArray.get(3).toString());
							data_item.put("c4",c4);

							double c5=new Double(jsonArray.get(4).toString());
							data_item.put("c5",c5);
							
						data.add(data_item);
					}
					performance.put("status",0);
					performance_data.put("infos",data);
					
				}
			}else{
				JSONObject err_3=new JSONObject();
				err_3.put("status",3);
				err_3.put("message","请求异常");
				out.print(err_3);
			}
			//-----------------------------------------------查询按照每小时增长统计店铺信息
			tra.put("params",  new JSONObject(getCmdparam("hour",c_store_id)));
			ja.put(tra);
			params.put("transactions", ja.toString());
			vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
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
				String datas_2=vh.get("message").toString();
				int index_3=datas_2.indexOf("{");
				datas_2=datas_2.substring(index_3,datas_2.length()-1);
				JSONObject jesonRows_3=new JSONObject(datas_2);
				JSONArray rows_2=jesonRows_3.getJSONArray("rows");
				JSONArray jsonArray_1;
				JSONObject chart_json=null;
				chart = new ArrayList<JSONObject>();
				for(int b=0;b<rows_2.length();b++){
					jsonArray_1=(JSONArray)rows_2.get(b);
					chart_json=new JSONObject();

					int x=new Integer(jsonArray_1.get(0).toString());
					chart_json.put("x",x);
					
					double y=new Double(jsonArray_1.get(1).toString());
					chart_json.put("y",y);
					
					chart.add(chart_json);
				}
				performance_data.put("chart",chart);
				performance.put("data",performance_data);
				out.print(performance);
			}
		}else{
					JSONObject err_3=new JSONObject();
					err_3.put("status",3);
					err_3.put("message","请求异常");
					out.print(err_3);
		}
		//--------------------------------------------------------	
		} catch (JSONException e) {
			
			JSONObject err_5=new JSONObject();
				err_5.put("status",5);
				err_5.put("message","程序异常");
				out.print(err_5);
				out.print(e.toString());
				return;
		}
		
%>
