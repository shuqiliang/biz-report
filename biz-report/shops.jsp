<%@ page language="java"
	import="nds.rest.*,org.json.*,java.net.*,java.io.*,java.security.MessageDigest,java.math.BigDecimal"
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
private String getCmdparam(int type,int size,int start){
	String cmdparam="";
	if(type==0){
			cmdparam="{\r\n" + 
				" \"table\":APP_STOREDAY,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"C_STORE_ID\",\"STORENAME\",\"LS_AMT\",\"LS_DIS\",\"KC_AMT\",\"STOREKIND\"],\r\n" + 
				" \"orderby\":[{\"column\":\"LS_AMT\",\"asc\":false}]\r\n" + 
				"}";
			return cmdparam;
	}else if(type==1){
			cmdparam="{\r\n" + 
				" \"table\":APP_STOREWEEK,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"C_STORE_ID\",\"STORENAME\",\"LS_AMT\",\"LS_DIS\",\"KC_AMT\",\"STOREKIND\"],\r\n" + 
				" \"orderby\":[{\"column\":\"LS_AMT\",\"asc\":false}]\r\n" + 
				"}";
			return cmdparam;
	}else if(type==2){
			cmdparam="{\r\n" + 
				" \"table\":APP_STOREMONTH,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"C_STORE_ID\",\"STORENAME\",\"LS_AMT\",\"LS_DIS\",\"KC_AMT\",\"STOREKIND\"],\r\n" + 
				" \"orderby\":[{\"column\":\"LS_AMT\",\"asc\":false}]\r\n" + 
				"}";
			return cmdparam;
	}else if(type==3){
			cmdparam="{\r\n" + 
				" \"table\":APP_STOREYEAR,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"C_STORE_ID\",\"STORENAME\",\"LS_AMT\",\"LS_DIS\",\"KC_AMT\",\"STOREKIND\"],\r\n" + 
				" \"orderby\":[{\"column\":\"LS_AMT\",\"asc\":false}]\r\n" + 
				"}";
			return cmdparam;
	}
	return cmdparam;
}
%>
<%!
	private static double getZeroDecimal(double num) {  
          DecimalFormat dFormat=new DecimalFormat("#");  
          String yearString=dFormat.format(num);  
          Double temp= Double.valueOf(yearString);  
          return temp;  
    }  
%>
<%
	try {
			JSONObject gl=new JSONObject();
			
			List<JSONObject> gl_data=new ArrayList<JSONObject>();
			
			JSONObject data_json=new JSONObject();
			
			int type=0;
			String type_key=request.getParameter("type");
			if(type_key==null||type_key.equals("")){
				JSONObject err_4=new JSONObject();
					err_4.put("status",4);
					err_4.put("message","type为空");
					out.print(err_4);
					return;
			}else{
				type=new Integer(type_key.toString());
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
			
			//查询页数
			String page_num1=request.getParameter("page");
			if(page_num1==null||page_num1.equals("")){
				page_num1="0";
			}
			int page_num=Integer.parseInt(page_num1);
			if(page_num<=0){
				page_num=1;
			}
			//查询行数
			String size1=request.getParameter("size");
			if(size1==null||size1.equals("")){
				size1="30";
			}
			int size=Integer.parseInt(size1);
			
			//模糊查询参数
			String keyword1=request.getParameter("keyword");
			if(keyword1==null||keyword1.equals("")){
				keyword1="";
			}
			
			//开始行数
			int start = size*(page_num-1);
			if(start<0){
				start=0;
			}
			
			//-----------------------------------------------查询APP概览
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
			tra.put("params",new JSONObject(getCmdparam(type,size,start)));
			ja=new JSONArray();
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
							gl.put("status",0);
							gl.put("data",gl_data);
							out.print(gl);
							return;
						}
						String datas=vh.get("message").toString();
						int index=datas.indexOf("{");
						datas=datas.substring(index,datas.length()-1);
						JSONArray rows;
						JSONObject jesonObjectRows;
						jesonObjectRows = new JSONObject(datas);
						rows=jesonObjectRows.getJSONArray("rows");
						JSONArray jsonArray;
						for(int b=0;b<rows.length();b++){
							data_json=new JSONObject();
							jsonArray=(JSONArray)rows.get(b);
							
							int c_store_id=new Integer(jsonArray.get(0).toString());
							data_json.put("c1",c_store_id);
							
							String c2=jsonArray.get(1).toString();
							data_json.put("c2",c2);
							
							double c3=new Double(jsonArray.get(2).toString());
							data_json.put("c3",getZeroDecimal(c3));
							
							double c4=new Double(jsonArray.get(3).toString());
							data_json.put("c4",c4);
							
							//库存
							double c5=new Double(jsonArray.get(4).toString());
							data_json.put("c5",getZeroDecimal(c5)); 
							
							String identify=jsonArray.get(5).toString();
							data_json.put("c6",identify); 
							
							gl_data.add(data_json);
						}
						gl.put("status",0);
						gl.put("data",gl_data);
						out.print(gl);
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
