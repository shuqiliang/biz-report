<%@ page language="java"
	import="nds.rest.*,org.json.*,java.net.*,java.io.*,org.apache.commons.lang3.StringEscapeUtils,java.security.MessageDigest"
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
private static StringBuilder getImageUrl(String s) {
        StringBuilder ip;
        int index1=s.indexOf("?");
        StringBuilder sb=new StringBuilder(s);
        sb.insert(index1,2);
        ip=new StringBuilder("http://101.132.135.103:2831");
        StringBuilder okip=ip.append(sb);
        return okip;
    }
%>
<%
String command="Query";                   //Query指令
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
	if(c_store_id==null){
		JSONObject err_4=new JSONObject();
		err_4.put("status",4);
		err_4.put("message","请求参数为空");
		out.print(err_4);
		return;
	}
	String cmdparam="{\r\n" + 
				" \"table\":APP_ZXANS01,\r\n" + 
				" \"columns\":[\"ORDERNO\",\"PDTCOL\",\"IMGURL\",\"WEEKQTY\",\"WEEKRATE\",\"QTYSTOCK\",\"SALEDDAY\",\"PREDAY\",\"TOT_RATE\",\"M_PRODUCT_ID;NAME\",\"M_SIZEGROUP_ID\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" \"orderby\":[{\"column\":\"ORDERNO\",\"asc\":true}]\r\n" + 
				"}";                          //封装的查询语句
	ValueHolder vh= null;
	JSONArray ja=null;
	SimpleDateFormat a=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	a.setLenient(false);
	//String sipKey="nea@burgeon.com.cn";   //权限账号
	String tt= a.format(new Date());
	//String m=MD5("bos20");                //账号密码
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
	JSONObject result=new JSONObject();
	List<JSONObject> data=new ArrayList<JSONObject>();
	
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
					result.put("status",0);
					result.put("data",data);
					out.print(result);
					return;
				}
			String datas=vh.get("message").toString();
			try {
				int index=datas.indexOf("{");
				datas=datas.substring(index,datas.length()-1);
				JSONArray rows;
				JSONObject jesonObjectRows;
				result=new JSONObject();
				data=new ArrayList<JSONObject>();
				JSONObject data_item=null;
					StringBuilder sb=new StringBuilder();
					jesonObjectRows = new JSONObject(datas);
					rows=jesonObjectRows.getJSONArray("rows");
					JSONArray jsonArray;
					for(int i=0;i<rows.length();i++){
						jsonArray=(JSONArray) rows.get(i);
						data_item=new JSONObject();
						
							int c1=new Integer(jsonArray.get(0).toString());
							data_item.put("c1",c1);
							
							String c2=(String)(jsonArray.get(1).toString());
							data_item.put("c2",c2);
							
							String c3=(String)(jsonArray.get(2).toString());
							if(!c3.equals("-")){
								sb=getImageUrl(c3);
							    data_item.put("c3",sb);
							}else{
								data_item.put("c3","-");
							}
							
							int c4=new Integer(jsonArray.get(3).toString());
							data_item.put("c4",c4);
							
							double c5=new Double(jsonArray.get(4).toString());
							data_item.put("c5",c5);
							
							int c6=new Integer(jsonArray.get(5).toString());
							data_item.put("c6",c6);	

							int c7=new Integer(jsonArray.get(6).toString());
							data_item.put("c7",c7);
							
							int c8= new Integer(jsonArray.get(7).toString());
							data_item.put("c8",c8);
							
							double c9=new Double(jsonArray.get(8).toString());
							data_item.put("c9",c9);
							
							String c10=jsonArray.get(9).toString();
							data_item.put("c10",c10);
						
						data.add(data_item);
					}
					result.put("status",0);
					result.put("data",data);
					String s1=result.toString();
					String s2 = StringEscapeUtils.unescapeJava(s1);
					String result_str = StringEscapeUtils.unescapeJava(s2);
					out.print(result_str);
				} catch (JSONException e) {
					
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
%>
