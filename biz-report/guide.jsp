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
private String getCmdparam(String type,String c_store_id){
	String cmdparam="";
	if(type.equals("data")){
			cmdparam="{\r\n" + 
				" \"table\":APP_GDANS01,\r\n" + 
				" \"columns\":[\"EMPNAME\",\"AMT\",\"WEEKAMT\",\"MONTHMARK\",\"MONTHAMT\",\"COMPRATE\",\"VIPRATE\",\"NEWVIP\",\"LDRATE\",\"DISCOUNT\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" \"orderby\":[{\"column\":\"AMT\",\"asc\":false}]\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("total")){
			cmdparam="{\r\n" + 
				" \"table\":APP_GDANS02,\r\n" + 
				" \"columns\":[\"AMT\",\"WEEKAMT\",\"MONTHMARK\",\"MONTHAMT\",\"COMPRATE\",\"VIPRATE\",\"NEWVIP\",\"LDRATE\",\"DISCOUNT\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"}\r\n" + 
				"}";
			return cmdparam;
	}
	return cmdparam;
}
%>
<%
try {
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
	//String m_md5=MD5(m);                         //账号密码

	//--------------------导购guide
	JSONObject guide=new JSONObject();

	//------------guide下面的total
	JSONObject total=new JSONObject();

	//------------guide下面的data
	JSONObject data=new JSONObject();
	
	//------------guide下面的date下面的data_list
	List<JSONObject> data_list=new ArrayList<JSONObject>();

	//------------guide下面的date下面的data_list下面的json
	JSONObject data_json=new JSONObject();


	String command="Query";                   //Query指令

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
	tra.put("params",  new JSONObject(getCmdparam("data",c_store_id)));
	ja=new JSONArray();
	ja.put(tra);
	params.put("transactions", ja.toString());
	vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
	//------------------------------------------------------------------各个员工数据查询
	if(vh!=null){
		if(!vh.get("code").toString().equals("0")){
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
				guide.put("status",0);
				data.put("data",data_list);
				data.put("total",total);
				guide.put("data",data);
				out.print(guide);
				return;
			}
			String datas_1=vh.get("message").toString();
			int index=datas_1.indexOf("{");
			datas_1=datas_1.substring(index,datas_1.length()-1);
			JSONObject jesonObjectRows=new JSONObject(datas_1);
			JSONArray rows=jesonObjectRows.getJSONArray("rows");
			JSONArray jsonArray_1;
			for(int b=0;b<rows.length();b++){
				jsonArray_1=(JSONArray)rows.get(b);
				data_json=new JSONObject();
				
					String name=jsonArray_1.get(0).toString();
					data_json.put("c1",name);
					
					double amt=new Double(jsonArray_1.get(1).toString());
					data_json.put("c2",amt);
					
					double weekamt=new Double(jsonArray_1.get(2).toString());
					data_json.put("c3",weekamt);
					
					double monthmark=new Double(jsonArray_1.get(3).toString());
					data_json.put("c4",monthmark);
					
					double monthamt=new Double(jsonArray_1.get(4).toString());
					data_json.put("c5",monthamt);
					
					double comprate=new Double(jsonArray_1.get(5).toString());
					data_json.put("c6",comprate);
					
					double viprate=new Double(jsonArray_1.get(6).toString());
					data_json.put("c7",viprate);
					
					int newvip=new Integer(jsonArray_1.get(7).toString());
					data_json.put("c8",newvip);
					
					double ldrate=new Double(jsonArray_1.get(8).toString());
					data_json.put("c9",ldrate);
					
					double discount=new Double(jsonArray_1.get(9).toString());
					data_json.put("c10",discount);
				
				data_list.add(data_json);
			}
			data.put("data",data_list);
			guide.put("status",0);
			guide.put("data",data);
		}
	}else{
			JSONObject err_3=new JSONObject();
			err_3.put("status",3);
			err_3.put("message","请求异常");
			out.print(err_3);
	}
	
	//-------------------------------------------------------------------------------------
	
    //-------------------------------------------------------------------------合计数据查询
		tra.put("params",new JSONObject(getCmdparam("total",c_store_id)));
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
			String datas_3=vh.get("message").toString();
			int index_4=datas_3.indexOf("{");
			datas_3=datas_3.substring(index_4,datas_3.length()-1);
			JSONObject jesonRows_4=new JSONObject(datas_3);
			JSONArray rows_4=jesonRows_4.getJSONArray("rows");
			JSONArray jsonArray_2;
			for(int b=0;b<rows_4.length();b++){
				jsonArray_2=(JSONArray)rows_4.get(b);
				
					double amt=new Double(jsonArray_2.get(0).toString());
					total.put("c1",amt);
					
					double weekamt=new Double(jsonArray_2.get(1).toString());
					total.put("c2",weekamt);
					
					double monthamark=new Double(jsonArray_2.get(2).toString());
					total.put("c3",monthamark);
					
					double monthamt=new Double(jsonArray_2.get(3).toString());
					total.put("c4",monthamt);
					
					double comprate=new Double(jsonArray_2.get(4).toString());
					total.put("c5",comprate);
					
					double viprate=new Double(jsonArray_2.get(5).toString());
					total.put("c6",viprate);
					
					int newvip=new Integer(jsonArray_2.get(6).toString());
					total.put("c7",newvip);
					
					double ldrate=new Double(jsonArray_2.get(7).toString());
					total.put("c8",ldrate);
					
					double discount=new Double(jsonArray_2.get(7).toString());
					total.put("c9",discount);
				
			}
			data.put("total",total);
			out.print(guide);
		}
	}else{
		JSONObject err_3=new JSONObject();
		err_3.put("status",3);
		err_3.put("message","请求异常");
		out.print(err_3);
		}
	} catch (Exception e) {
		JSONObject err_5=new JSONObject();
		err_5.put("status",5);
		err_5.put("message","程序异常");
		out.print(err_5);
		return;
	}
%>
