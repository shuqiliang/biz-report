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
private String getCmdparam(String type,String m_product_id){
	String cmdparam="";
	if(type.equals("sizes")){
			cmdparam="{\r\n" + 
				" \"table\":APP_KCFB_SIZE,\r\n" + 
				" \"columns\":[\"SIZES\",\"QTYSTOCK\",\"TOT_STOCK\",\"WEEKQTY\"],\r\n" + 
				" \"params\":{\"column\":\"M_PRODUCT_ID;NAME\",\"condition\":"+m_product_id+"},\r\n" + 
				" \"count\":true,\r\n" + 
				" \"orderby\":[{\"column\":\"SIZES\",\"asc\":true}]\r\n" + 
				"}";
			return cmdparam;
	}else if(type.equals("colors")){//所有尺寸，big_total数据
			cmdparam="{\r\n" + 
					" \"table\":APP_KCFB_COLOR,\r\n" + 
					" \"columns\":[\"COLORS\",\"QTYSTOCK\",\"WEEKQTY\"],\r\n" + 
					" \"params\":{\"column\":\"M_PRODUCT_ID;NAME\",\"condition\":"+m_product_id+"},\r\n" + 
					" \"count\":true,\r\n" + 
					" \"orderby\":[{\"column\":\"COLORS\",\"asc\":true}]\r\n" + 
					"}";
			return cmdparam;
	}
	return cmdparam;
}
%>
<%!
private String doMosaic(String m_product_id,String color,String type){
		String cmdparam="";
		if(type.equals("query_1")){//款-色-店
			cmdparam="{\r\n" + 
				" \"table\":APP_KCANS2,\r\n" + 
				" \"columns\":[\"C_STORE_ID;NAME\",\"QTYSTOCK\",\"WEEKQTY\"],\r\n" + 
				" \"range\":20000,\r\n" + 
				" \"count\":true,\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"COLORS\",\"condition\":"+color+"},\r\n" + 
				" expr2:{\"column\":\"M_PRODUCT_ID;NAME\",\"condition\":"+m_product_id+"}\r\n" + 
				" },\r\n" + 
				" \"orderby\":[{\"column\":\"C_STORE_ID;NAME\",\"asc\":true}]\r\n" + 
				"}";	
			return cmdparam;
		}else if(type.equals("query_2")){//库存分布具体某店的某个尺寸的库存
			cmdparam="{\r\n" + 
				" \"table\":APP_KCANS01,\r\n" + 
				" \"columns\":[\"C_STORE_ID;NAME\",\"SIZES\",\"QTYSTOCK\"],\r\n" + 
				" \"range\":400000,\r\n" + 
				" \"count\":true,\r\n" + 
				" \"params\":{\r\n" + 
				" combine:\"and\",\r\n" + 
				" expr1:{\"column\":\"COLORS\",\"condition\":"+color+"},\r\n" + 
				" expr2:{\"column\":\"M_PRODUCT_ID;NAME\",\"condition\":"+m_product_id+"}\r\n" + 
				" },\r\n" + 
				" \"orderby\":[{\"column\":\"C_STORE_ID;NAME\",\"asc\":true},{\"column\":\"SIZES\",\"asc\":true}]\r\n" + 
				"}\r\n" + 
				"";
			return cmdparam;
		}
		return cmdparam;
	}
%>
<%
	try{
		//-------查询的款号--------------
		String m_product_id=request.getParameter("style_number");
		if(m_product_id==null||m_product_id.equals("")){
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
		
		String command="Query";                   //Query指令
		ValueHolder vh= null;
		JSONArray ja=null;
		//-------------------------------库存分布数据结构框架
		//-------库存分布----------------
		JSONObject kcfb=new JSONObject();
		
		//-------状态信息----------------
		int status=0;
		
		//-------data--------------------
		JSONObject data=new JSONObject();
		
		//-------尺寸集合sizes-----------
		List<String> sizeTypes=new ArrayList<String>();
		
		//-------总库存tot_stock---------
		int c1=0;
		
		//-------总周销量weekqty---------
		int c2=0;
		
		//-------总计库存、周销量，各个尺寸库存
		JSONObject dataOfTotal=new JSONObject();
		
		//-------总各个尺寸库存----------
		JSONObject big_size=new JSONObject();
		
		//-------各个尺寸库存------------
		JSONObject mod_size=new JSONObject();
		
		//-------dataByColor集合---------
		List<JSONObject> dataByColor=new ArrayList<JSONObject>();
		
		//-------color、items、total-----
		JSONObject obj_json=null;
		
		//-------total库存、周销量，各个尺寸库存
		JSONObject total=new JSONObject();
		
		//-------items店铺级别库存周销量
		List<JSONObject> items=new ArrayList<JSONObject>();
		
		
		//-------json_store店铺级别JSONObject
		JSONObject json_store=new JSONObject();
		
		//-------kcfb下面的dataByColor下面的items下面的json_store下面的size  JSONObject
		JSONObject small_size=new JSONObject();
		
		
		//-------------------------------查询所有的尺寸，总库存，总周销量，库存
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
		tra.put("params",  new JSONObject(getCmdparam("sizes",m_product_id)));
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
						kcfb.put("status",0);
						dataOfTotal.put("c1",0);
						dataOfTotal.put("c2",0);
						dataOfTotal.put("size",big_size);
						data.put("dataOfTotal",dataOfTotal);
						data.put("dataByColor",dataByColor);
						data.put("sizeTypes",sizeTypes);
						kcfb.put("data",data);
						out.print(kcfb);
						return;
					}
					String datas=vh.get("message").toString();
					int index=datas.indexOf("{");
					datas=datas.substring(index,datas.length()-1);
					JSONObject jesonObjectRows=new JSONObject(datas);
					JSONArray rows=jesonObjectRows.getJSONArray("rows");
					JSONArray jsonArray;
					for(int i=0;i<rows.length();i++){
						jsonArray=(JSONArray)rows.get(i);
							String size_name=(String)jsonArray.get(0).toString();
							if(!sizeTypes.contains(size_name)){
								sizeTypes.add(size_name);
							};
							 int big_total_size_count=new Integer(jsonArray.get(1).toString());
							 big_size.put(size_name,big_total_size_count);
							
							 c1=new Integer(jsonArray.get(2).toString());
							
							 c2=new Integer(jsonArray.get(3).toString());
					}
					dataOfTotal.put("c1",c1);
					dataOfTotal.put("c2",c2);
					dataOfTotal.put("size",big_size);
				}
			}else{
				JSONObject err_3=new JSONObject();
				err_3.put("status",3);
				err_3.put("message","请求异常");
				out.print(err_3);
				return;
			}
			
			//--------------------------------查询所有的颜色,以及对应颜色的库存，周销量
			//------------封装查询条件
			tra.put("params",  new JSONObject(getCmdparam("colors",m_product_id)));
			ja.put(tra);
			params.put("transactions", ja.toString());
			vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
			String datas=vh.get("message").toString();
			int index=datas.indexOf("{");
			datas=datas.substring(index,datas.length()-1);
			JSONObject jesonObjectRows=new JSONObject(datas);
			JSONArray rows1=jesonObjectRows.getJSONArray("rows");
			String color="";
			for(int c=0;c<rows1.length();c++){
				obj_json=new JSONObject();
				total=new JSONObject();
				mod_size=new JSONObject();
				items=new ArrayList<JSONObject>();
				JSONArray jsonArray1=(JSONArray)rows1.get(c);
				
				color=jsonArray1.get(0).toString();
				obj_json.put("color",color);
				
				c1=new Integer(jsonArray1.get(1).toString());
				total.put("c1",c1);
				
				c2=new Integer(jsonArray1.get(2).toString());
				total.put("c2",c2);
				
				//-----------------------------------------------查询店铺、库存、周销量-begin
				tra.put("params",  new JSONObject(doMosaic(m_product_id,color,"query_1")));
				ja.put(tra);
				params.put("transactions", ja.toString());
				vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
				datas=vh.get("message").toString();
				index=datas.indexOf("{");
				datas=datas.substring(index,datas.length()-1);
				jesonObjectRows=new JSONObject(datas);
				JSONArray rows2=jesonObjectRows.getJSONArray("rows");
				for(int e=0;e<rows2.length();e++){
					json_store=new JSONObject();
					JSONArray jsonArray2=(JSONArray)rows2.get(e);
						
						String store=jsonArray2.get(0).toString();
						json_store.put("c1",store);
						
						int qty_stock1=new Integer(jsonArray2.get(1).toString());
						json_store.put("c2",qty_stock1);
						
						int weekqty1=new Integer(jsonArray2.get(2).toString());
						json_store.put("c3",weekqty1);
						
					
					items.add(json_store);
					obj_json.put("items",items);
					//out.print("obj_json="+obj_json+"<br/>");
				}
				//----------------------------------------------查询店铺、库存、周销量-end
				
				//--------------------------------------------查询店铺、尺寸，尺寸库存-begin
				tra.put("params",  new JSONObject(doMosaic(m_product_id,color,"query_2")));
				ja.put(tra);
				params.put("transactions", ja.toString());
				vh=RestUtils.sendRequest("http://localhost:2831/servlets/binserv/Rest", params,"POST");
				datas=vh.get("message").toString();
				index=datas.indexOf("{");
				datas=datas.substring(index,datas.length()-1);
				jesonObjectRows=new JSONObject(datas);
				JSONArray rows3=jesonObjectRows.getJSONArray("rows");
				int store_index=0;
				String size_dis="";
				int size_cou=0;
				//----------------------------------------------------------------------------------------------------
				JSONArray jsonArray3=null;
				if(rows3.length()==1){
				    //当rows只有一行的时候直接处理
					jsonArray3=(JSONArray)rows3.get(0);
					size_dis=jsonArray3.get(1).toString();
						
					size_cou=new Integer(jsonArray3.get(2).toString());
					//往中等统计size放值
					if(mod_size.has(size_dis)){
						int size_cou_total=new Integer(mod_size.get(size_dis).toString());
						size_cou_total=size_cou_total+size_cou;
						mod_size.put(size_dis,size_cou_total);
					}else{
						mod_size.put(size_dis,size_cou);
					}
					//往小的size里面放值
					small_size=new JSONObject();
				    items.get(store_index).put("size",small_size);
				    items.get(store_index).getJSONObject("size").put(size_dis,size_cou);

			    }else{
			    	for(int g=0;g<rows3.length();g++){
					jsonArray3=(JSONArray)rows3.get(g);
					JSONArray jsonArray3_1;
					//中等尺寸根本不受店铺限制
					size_dis=jsonArray3.get(1).toString();
						
					size_cou=new Integer(jsonArray3.get(2).toString());
					
					if(mod_size.has(size_dis)){
						int size_cou_total=new Integer(mod_size.get(size_dis).toString());
						size_cou_total=size_cou_total+size_cou;
						mod_size.put(size_dis,size_cou_total);
					}else{
						mod_size.put(size_dis,size_cou);
					}
					
					if(g==rows3.length()-1){//最后一个子集合
						jsonArray3_1=(JSONArray)rows3.get(g);
					}else{
						jsonArray3_1=(JSONArray)rows3.get(g+1);
					}	
					
					JSONObject items_json=new JSONObject();
					small_size=new JSONObject();
					if(jsonArray3.get(0).toString().equals(jsonArray3_1.get(0).toString())){
						//是同一个店铺,需要分成两种情况处理
						if(g==rows3.length()-1){
							//将最后一个集合的店铺和倒数第二个店铺比较是否相同,
							//当最后一个店仓不等于倒数第二个店仓的时候，需要将他单独写进去，如果是同一个店仓直接continue就可以了
							JSONArray jsonArray_last=(JSONArray)rows3.get(g);
							JSONArray jsonArray_downsecond=(JSONArray)rows3.get(g-1);
							if(!jsonArray_last.get(0).toString().equals(jsonArray_downsecond.get(0).toString())){
								small_size=new JSONObject();
								size_dis=jsonArray3.get(1).toString();
								size_cou=new Integer(jsonArray3.get(2).toString()); 
								small_size.put(size_dis,size_cou);
								items.get(store_index).put("size",small_size);
								continue;
							}else{
								size_dis=jsonArray3.get(1).toString();
								size_cou=new Integer(jsonArray3.get(2).toString()); 
								items_json=items.get(store_index).getJSONObject("size").put(size_dis,size_cou);
								continue;
							}
						}
						
						size_dis=jsonArray3.get(1).toString();
						
						size_cou=new Integer(jsonArray3.get(2).toString()); 
						
						//small_size.put(size_dis,size_cou);
						//out.print("g_="+g+"<br/>");
						//out.print("store_index_="+store_index+"<br/>");
						//out.print("items.size()_="+items.size()+"<br/>");
						//out.print("small_size_2="+small_size+"<br/>");
						if(store_index==0 && g==0){
							small_size=new JSONObject();
						    items.get(store_index).put("size",small_size);
						}
						items_json=items.get(store_index).getJSONObject("size").put(size_dis,size_cou);
						//out.print("items="+items+"<br/>");
						//out.print("items.get(store_index)="+items.get(store_index)+"<br/>");
						
					}else{
						if(store_index==0 && g==0){
							size_dis=jsonArray3.get(1).toString();
							size_cou=new Integer(jsonArray3.get(2).toString()); 
							small_size.put(size_dis,size_cou);
							//out.print("g="+g+"<br/>");
							//out.print("store_index="+store_index+"<br/>");
							//out.print("items.size()="+items.size()+"<br/>");
							//out.print("small_size_3="+small_size+"<br/>");
						    items.get(store_index).put("size",small_size);
							//out.print("items="+items+"<br/>");
							//out.print("items.get(store_index)="+items.get(store_index)+"<br/>");
							++store_index;
							small_size=new JSONObject();
							items.get(store_index).put("size",small_size);
							continue;
						}
						
						//不是同一个店铺
						//small_size=new JSONObject();
						size_dis=jsonArray3.get(1).toString();
						size_cou=new Integer(jsonArray3.get(2).toString()); 
						small_size.put(size_dis,size_cou);
						//out.print("g="+g+"<br/>");
						//out.print("store_index="+store_index+"<br/>");
						//out.print("items.size()="+items.size()+"<br/>");
						//out.print("small_size_4="+small_size+"<br/>");	
						//items.get(store_index).put("size",small_size);
						items_json=items.get(store_index).getJSONObject("size").put(size_dis,size_cou);
						small_size=new JSONObject();
						if (!(store_index+1==items.size())){
							items.get(store_index+1).put("size",small_size);
						}
						//out.print("items="+items+"<br/>");
						//out.print("items.get(store_index-1)="+items.get(store_index)+"<br/>");
						//out.print("items.get(store_index)="+items.get(store_index-1)+"<br/>");
						++store_index;
					}
				}
			    }
				
				total.put("size",mod_size);
				//---------------------------------------------查询店铺、尺寸，尺寸库存-end
					
				//放mod_size位置
				obj_json.put("total",total);
				dataByColor.add(obj_json);
			//----------将dataOfTotal以及sizeTypes放入data里面
			data.put("sizeTypes",sizeTypes);
			data.put("dataOfTotal",dataOfTotal);
			data.put("dataByColor",dataByColor);	
			}
			//----------封装最后的数据--------------
		
			//----------将status以及data放入kcfb里面
			kcfb.put("status",0);
			kcfb.put("data",data);
			out.print(kcfb.toString());
	}catch(Exception e){
		JSONObject err_5=new JSONObject();
		err_5.put("status",5);
		err_5.put("message","程序异常");
		out.print(err_5);
		out.print(e.toString());
		return;
	}
%>