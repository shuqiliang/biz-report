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
<%
try {
	String cmdparam="{\r\n" + 
				" \"table\":C_STORE,\r\n" + 
				" \"range\":1,\r\n" + 
				" \"columns\":[\"ID\",\"NAME\"],\r\n" + 
				" \"orderby\":[{\"column\":\"ID\",\"asc\":TRUE}]\r\n" + 
				"}";
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
	//String m_md5=MD5(m);                            //账号密码

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
	tra.put("params",  new JSONObject(cmdparam));
	ja=new JSONArray();
	ja.put(tra);
	params.put("transactions", ja.toString());
	vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
	if(vh!=null){
			if(!vh.get("code").toString().equals("0")){
				JSONObject err_7=new JSONObject();
				err_7.put("status",7);
				err_7.put("message","帐号或者密码错误");
				out.print(err_7);
				return;
			}else{
				String rel_2=vh.get("message").toString();
				int index_3=rel_2.indexOf("{");
				rel_2=rel_2.substring(index_3,rel_2.length()-1);
				JSONObject jesonRows_3=new JSONObject(rel_2);
				JSONArray rows_3=jesonRows_3.getJSONArray("rows");
				if(rows_3.length()!=0){
					JSONObject result=new JSONObject();
					result.put("status",0);
					JSONObject data=new JSONObject();
					data.put("success",0);
					result.put("data",data);
					out.print(result);
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
	} catch (Exception e) {
		JSONObject err_5=new JSONObject();
		err_5.put("status",5);
		err_5.put("message","程序异常");
		out.print(err_5);
		return;
	}
%>
