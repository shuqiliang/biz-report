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
	if(type.equals("summary")){
			cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS01,\r\n" + 
				" \"columns\":[\"NEWCNT\",\"VIPRATE\",\"BACKRATE\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"}\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("liveness")){
			cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS03,\r\n" + 
				" \"columns\":[\"LIVENESS\",\"RATE\",\"COLOR\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"}\r\n" + 
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

	//--------会员下面的data下面的data
	List<JSONObject> data_data=new ArrayList<JSONObject>();

	//--------会员下面的data下面的liveness
	List<JSONObject> liveness=new ArrayList<JSONObject>();

	//--------会员data下面的liveness里面的JSONObject
	JSONObject data_liveness_json=new JSONObject();

	//--------summary 
	JSONObject summary=new JSONObject();

	//-------------------------------------------------------查询会员总信息

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
		tra.put("params",  new JSONObject(getCmdparam("summary",c_store_id)));
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
					data_hy.put("summary",summary);
					data_hy.put("liveness",liveness);
					hy.put("data",data_hy);
					out.print(hy);
					return;
				}
				String datas_1=vh.get("message").toString();
				int index=datas_1.indexOf("{");
				datas_1=datas_1.substring(index,datas_1.length()-1);
				JSONObject jesonObjectRows=new JSONObject(datas_1);
				JSONArray rows=jesonObjectRows.getJSONArray("rows");
				String s=rows.toString();
					String a=s.substring(2, s.length()-2);
					String[] b=a.split(",");
					for(int c=0;c<b.length;c++){
						int c1=new Integer(b[0]);
						summary.put("c1",c1);
				
						double c2=new Double(b[1]);
						summary.put("c2",c2);
				
						double c3=new Double(b[2]);
						summary.put("c3",c3);
					}
					data_hy.put("summary",summary);
			}
		}else{
					JSONObject err_3=new JSONObject();
					err_3.put("status",3);
					err_3.put("message","请求异常");
					out.print(err_3);
		}
		tra.put("params",new JSONObject(getCmdparam("liveness",c_store_id)));
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
						
						String fill=jsonArray_2.get(2).toString();
						data_liveness_json.put("fill",fill);
						
					liveness.add(data_liveness_json);
				}
				data_hy.put("liveness",liveness);
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
