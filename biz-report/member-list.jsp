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
private String getCmdparam(String c_store_id,int orderBy,int size,int start){
	String cmdparam="";
	cmdparam=orderBy(c_store_id,orderBy,size,start);
	return cmdparam;
}
%>
<%!
public String orderBy(String c_store_id,int orderBy,int size,int start){
	String cmdparam="";
	switch(orderBy){
        case 0://全部会员
            cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS02,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"CARDNO\",\"C_VIPTYPE_ID;NAME\",\"VIPNAME\",\"BIRTHDAY\",\"BUY_AMT\",\"C_VIP_ID\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" \"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
		break;
        case 1://今天生日
            cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS02,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"CARDNO\",\"C_VIPTYPE_ID;NAME\",\"VIPNAME\",\"BIRTHDAY\",\"BUY_AMT\",\"C_VIP_ID\"],\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" expr2:{\"column\":\"ISDAY\",\"condition\":Y}\r\n" + 
				" },\r\n" + 
				" \"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
	    break;
        case 2://本周生日
            cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS02,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"CARDNO\",\"C_VIPTYPE_ID;NAME\",\"VIPNAME\",\"BIRTHDAY\",\"BUY_AMT\",\"C_VIP_ID\"],\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" expr2:{\"column\":\"ISWEEK\",\"condition\":Y}\r\n" + 
				" },\r\n" + 
				" \"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
		break;
		case 3://本月生日
            cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS02,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"CARDNO\",\"C_VIPTYPE_ID;NAME\",\"VIPNAME\",\"BIRTHDAY\",\"BUY_AMT\",\"C_VIP_ID\"],\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" expr2:{\"column\":\"ISMONTH\",\"condition\":Y}\r\n" + 
				" },\r\n" + 
				" \"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
		break;	
		case 4://活跃会员
            cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS02,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"CARDNO\",\"C_VIPTYPE_ID;NAME\",\"VIPNAME\",\"BIRTHDAY\",\"BUY_AMT\",\"C_VIP_ID\"],\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" expr2:{\"column\":\"ISACTIVE\",\"condition\":Y}\r\n" + 
				" },\r\n" + 
				" \"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
		break;
		case 5://休眠会员
            cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS02,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"CARDNO\",\"C_VIPTYPE_ID;NAME\",\"VIPNAME\",\"BIRTHDAY\",\"BUY_AMT\",\"C_VIP_ID\"],\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" expr2:{\"column\":\"ISACTIVE\",\"condition\":N}\r\n" + 
				" },\r\n" + 
				" \"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
		break;
        default:
            cmdparam="{\r\n" + 
				" \"table\":APP_VIPANS02,\r\n" + 
				" \"range\":"+size+",\r\n" + 
			 	" \"start\":"+start+",\r\n" + 
				" \"columns\":[\"CARDNO\",\"C_VIPTYPE_ID;NAME\",\"VIPNAME\",\"BIRTHDAY\",\"BUY_AMT\",\"C_VIP_ID\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"},\r\n" + 
				" \"orderby\":[{\"column\":\"BUY_AMT\",\"asc\":false}]\r\n" + 
				"}";
		break;
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

	//--------会员data下面的data里面的JSONObject
	JSONObject data_data_json=new JSONObject();

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
		//排序关键字
		String order=request.getParameter("key");
		int orderKey=0;
		if(order!=null){
			orderKey=new Integer(order);
		}else{
			JSONObject err_6=new JSONObject();
				err_6.put("status",6);
				err_6.put("message","缺失关键字key");
				out.print(err_6);
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

		//-----------------------------------------------查询所有会员
		
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
		tra.put("params",  new JSONObject(getCmdparam(c_store_id,orderKey,size,start)));
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
				String rel_1=vh.get("message").toString();
				int index_2=rel_1.indexOf("{");
				rel_1=rel_1.substring(index_2,rel_1.length()-1);
				JSONObject jesonRows_2=new JSONObject(rel_1);
				JSONArray rows_1=jesonRows_2.getJSONArray("rows");
				if(rows_1.length()==0){
					hy.put("status",0);
					hy.put("data",data_data);
					out.print(hy);
					return;
				}
				String datas_2=vh.get("message").toString();
				int index_3=datas_2.indexOf("{");
				datas_2=datas_2.substring(index_3,datas_2.length()-1);
				JSONObject jesonRows_3=new JSONObject(datas_2);
				JSONArray rows_2=jesonRows_3.getJSONArray("rows");
				JSONArray jsonArray_1;
				for(int b=0;b<rows_2.length();b++){
					jsonArray_1=(JSONArray)rows_2.get(b);
					data_data_json=new JSONObject();

						int num=((page_num-1)*size)+b+1;
						data_data_json.put("c2",num);
						
						String cardno=jsonArray_1.get(0).toString();
						data_data_json.put("c3",cardno);
						
						String cardtype=jsonArray_1.get(1).toString();
						data_data_json.put("c4",cardtype);
						
						String vipname=jsonArray_1.get(2).toString();
						data_data_json.put("c5",vipname);
						
						int birthday=new Integer(jsonArray_1.get(3).toString());
						data_data_json.put("c6",birthday);
						
						double buy_amt=new Double(jsonArray_1.get(4).toString());
						data_data_json.put("c7",buy_amt);
						
						int c_vip_id=new Integer(jsonArray_1.get(5).toString());
						data_data_json.put("c1",c_vip_id);
					
					data_data.add(data_data_json);
				}
				//data_hy.put(data_data);
			}
		}else{
			JSONObject err_3=new JSONObject();
			err_3.put("status",3);
			err_3.put("message","请求异常");
			out.print(err_3);
		}
		//-------------拼接结果------------
		hy.put("status",0);
		hy.put("data",data_data);
		out.print(hy);
		} catch (Exception e) {
			JSONObject err_5=new JSONObject();
			err_5.put("status",5);
			err_5.put("message","程序异常");
			out.print(err_5);
			return;
		}
%>
