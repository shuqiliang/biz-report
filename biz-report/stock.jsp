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
private String getCmdparam(String type,String c_store_id){
	String cmdparam="";
	if(type.equals("summary")){
			cmdparam="{\r\n" + 
				" \"table\":APP_STOCK01,\r\n" + 
				" \"columns\":[\"QTY\",\"SAFEQTY\",\"LWQTY\",\"AMTLIST\",\"SAFELIST\",\"NWQTY\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"}\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("category")){
			cmdparam="{\r\n" + 
				" \"table\":APP_STOCK_DIM01,\r\n" + 
				" \"columns\":\r\n" + 
				" [\"M_DIM_ID\",\"M_DIM_ID;ATTRIBNAME\",\"QTY\",\"LWQTY\",\"QTYRATE\",\"PQTYRATE\",\"SALERATE\",\"PSALERATE\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"}\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("season")){
			cmdparam="{\r\n" + 
				" \"table\":APP_STOCK_DIM02,\r\n" + 
				" \"columns\":\r\n" + 
				" [\"M_DIM_ID\",\"M_DIM_ID;ATTRIBNAME\",\"QTY\",\"LWQTY\",\"QTYRATE\",\"PQTYRATE\",\"SALERATE\",\"PSALERATE\"],\r\n" + 
				" \"params\":{\"column\":\"C_STORE_ID\",\"condition\":"+c_store_id+"}\r\n" + 
				"}";
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
	//-------------库存--kc  JSONObject
JSONObject kc=new JSONObject();

//-------------库存下面的data  JSONObject
JSONObject data_json=new JSONObject();

//-------------库存下面的data下面的summary  JSONObject
JSONObject summary_json=new JSONObject();

//-------------库存下面的data下面的dataWithCategory List
List<JSONObject> category_list=new ArrayList<JSONObject>();

//-------------库存下面的data下面的dataWithCategory JSONObject
JSONObject category_json=new JSONObject();

//-------------库存下面的data下面的dataWithCategory List
List<JSONObject> season_list=new ArrayList<JSONObject>();

//-------------库存下面的data下面的dataWithSeason
JSONObject season_json=new JSONObject();

//-------------库存下面的data下面的total
JSONObject total_json=new JSONObject();

	//-------------------------------------------------------查询库存总览信息
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
	//String m_md5=MD5(m);                              //账号密码
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
				kc.put("status",0);
				data_json.put("total",total_json);
				data_json.put("summary",summary_json);
				data_json.put("dataWithCategory",category_list);
				data_json.put("dataWithSeason",season_list);
			    kc.put("data",data_json);
			    out.print(kc);
				return;
			}
			String datas_1=vh.get("message").toString();
			int index=datas_1.indexOf("{");
			datas_1=datas_1.substring(index,datas_1.length()-1);
			JSONObject jesonObjectRows=new JSONObject(datas_1);
			JSONArray rows=jesonObjectRows.getJSONArray("rows");
			JSONArray result=(JSONArray)rows.get(0);
			int qty=new Integer(result.get(0).toString());
			summary_json.put("c1",qty);	
			total_json.put("c2",qty);
			
			int safeqty=new Integer(result.get(1).toString());
			summary_json.put("c2",safeqty);
			
			int lwqty=new Integer(result.get(2).toString());
			summary_json.put("c3",lwqty);
			total_json.put("c3",lwqty);

			double amtlist=new Double(result.get(3).toString());
			summary_json.put("c4",getZeroDecimal(amtlist));
			
			double safelist=new Double(result.get(4).toString());
			summary_json.put("c5",getZeroDecimal(safelist));
			
			int nwqty=new Integer(result.get(5).toString());
			summary_json.put("c6",nwqty);
			
			data_json.put("summary",summary_json);
			kc.put("data",data_json);
		}
	}else{
				JSONObject err_3=new JSONObject();
				err_3.put("status",3);
				err_3.put("message","请求异常");
				out.print(err_3);
				return;
	}
	//-----------------------------------------------查询库存类别分析
	tra.put("params",  new JSONObject(getCmdparam("category",c_store_id)));
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
			for(int b=0;b<rows_2.length();b++){
				jsonArray_1=(JSONArray)rows_2.get(b);
				category_json=new JSONObject();
					int number=new Integer(jsonArray_1.get(0).toString());
					
					String name=jsonArray_1.get(1).toString();
					if(number==0){
						category_json.put("c1","无分类");
					}else{
						category_json.put("c1",name);
					}
					
					int qty=new Integer(jsonArray_1.get(2).toString());
					category_json.put("c2",qty);
					
					int lwqty=new Integer(jsonArray_1.get(3).toString());
					category_json.put("c3",lwqty);
					
					double qtyrate=new Double(jsonArray_1.get(4).toString());
					category_json.put("c4",getZeroDecimal(qtyrate*100));
					
					double pqtyrate=new Double(jsonArray_1.get(5).toString());
					category_json.put("c5",getZeroDecimal(pqtyrate*100));
					
					double salerate=new Double(jsonArray_1.get(6).toString());
					category_json.put("c6",getZeroDecimal(salerate*100));
					
					double psalerate=new Double(jsonArray_1.get(7).toString());
					category_json.put("c7",getZeroDecimal(psalerate*100));
					
					category_list.add(category_json);
					
			}
			data_json.put("dataWithCategory",category_list);
		}
	}else{
				JSONObject err_3=new JSONObject();
				err_3.put("status",3);
				err_3.put("message","请求异常");
				out.print(err_3);
	}
	//--------------------------------------------------库存季节分析
	
	tra.put("params",new JSONObject(getCmdparam("season",c_store_id)));
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
			String datas_3=vh.get("message").toString();
			int index_4=datas_3.indexOf("{");
			datas_3=datas_3.substring(index_4,datas_3.length()-1);
			JSONObject jesonRows_4=new JSONObject(datas_3);
			JSONArray rows_4=jesonRows_4.getJSONArray("rows");
			JSONArray jsonArray_1;
			for(int b=0;b<rows_4.length();b++){
				jsonArray_1=(JSONArray)rows_4.get(b);
				season_json=new JSONObject();
					int number=new Integer(jsonArray_1.get(0).toString());
					
					String name=jsonArray_1.get(1).toString();
					if(number==0){
						season_json.put("c1","未定义");
					}else{
						season_json.put("c1",name);
					}
					
					int qty=new Integer(jsonArray_1.get(2).toString());
					season_json.put("c2",qty);
					
					int lwqty=new Integer(jsonArray_1.get(3).toString());
					season_json.put("c3",lwqty);
					
					double qtyrate=new Double(jsonArray_1.get(4).toString());
					season_json.put("c4",getZeroDecimal(qtyrate*100));
					
					double pqtyrate=new Double(jsonArray_1.get(5).toString());
					season_json.put("c5",getZeroDecimal(pqtyrate*100));
					
					double salerate=new Double(jsonArray_1.get(6).toString());
					season_json.put("c6",getZeroDecimal(salerate*100));
					
					double psalerate=new Double(jsonArray_1.get(7).toString());
					season_json.put("c7",getZeroDecimal(psalerate*100));
					
					season_list.add(season_json);
			}
			data_json.put("dataWithSeason",season_list);
			total_json.put("c1","合计");
			total_json.put("c4",100);
			total_json.put("c5",100);
			total_json.put("c6",100);
			total_json.put("c7",100);
			data_json.put("total",total_json);
			kc.put("status",0);
			kc.put("data",data_json);
			out.print(kc);
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
		out.print(e.toString());
		return;
	}
%>
