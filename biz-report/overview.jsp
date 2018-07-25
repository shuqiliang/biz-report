<%@ page language="java"
	import="nds.rest.*,org.json.*,java.net.*,java.io.*,java.security.MessageDigest,java.math.BigDecimal"
	pageEncoding="utf-8"%>
<%@ include file="/html/nds/common/init.jsp"%>
<%@page errorPage="/html/nds/error.jsp"%>
<%!
    static String excute(String postUrl) throws Exception {
		//OutputStreamWriter outputStreamWriter = null;
		BufferedReader inReader = null;
		String result = "";
		HttpURLConnection conn = null;
		try {
			URL realUrl = new URL(postUrl);
			conn = (HttpURLConnection) realUrl.openConnection();
			conn.setRequestProperty("accept", "*/*");
			conn.setRequestProperty("connection", "Keep-Alive");
			conn.setRequestProperty("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
			conn.setRequestProperty("Content-type", "application/json;charset=utf-8");
			conn.setConnectTimeout(3000);
			conn.setRequestMethod("GET");
			conn.setDoOutput(true);
			conn.setDoInput(true);
			//outputStreamWriter = new OutputStreamWriter(conn.getOutputStream(), "UTF-8");
			//outputStreamWriter.write(reqeustJsonData);
			//outputStreamWriter.flush();
			//outputStreamWriter.close();
			InputStream inputStream = conn.getInputStream();
			String resMsg = ChangeInputStream(inputStream,"utf-8");
			result = resMsg;
			return result;
		} catch (IOException ex) {
			String str1;
			if (conn != null) {
				int statusCode = conn.getResponseCode();
				String errorMsg = ChangeInputStream(conn.getErrorStream(),"utf-8");
				result = errorMsg;
				return result;
			}
			throw ex;
		} finally {
			try {
				if (conn != null) {
					conn.disconnect();
				}
				//if (outputStreamWriter != null) {
					//outputStreamWriter.close();
				//}
				if (inReader != null) {
					inReader.close();
				}
			} catch (IOException ex) {
				ex.printStackTrace();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
%>
<%!
    private static String ChangeInputStream(InputStream inputStream,String ecode) {
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		byte[] data = new byte[512];
		int len = 0;
		String result = "";
		if (inputStream != null) {
			try {
				while ((len = inputStream.read(data)) != -1) {
					outputStream.write(data, 0, len);
				}
				result = new String(outputStream.toByteArray(),ecode);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return result;
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
		//---------接口返回的数据
		String url="";
		JSONArray mJsonArray=null;
		JSONObject mObject=null;
		JSONObject mJsonObject=null;
		JSONObject gl=new JSONObject();
		//gl下面的data
		List<JSONObject> gl_data=new ArrayList<JSONObject>();
		//gl下面的data下面的json   JSONObject
		JSONObject data_json=new JSONObject();
		JSONObject sales_amount=new JSONObject();
		JSONObject stock_amount=new JSONObject();
		for(int s=0;s<4;s++){
			//变量
			String storeKing="";
			double xs_amt=0;
			double kc_amt=0;
			double lianying_xs=0;
			double lianying_kc=0;
			double jiameng_xs=0;
			double jiameng_kc=0;
			double zhiying_xs=0;
			double zhiying_kc=0;
			double tot_xs=0;
			int type=s;
			url="http://localhost:2831/biz-report/shops.jsp?username="+sipKey+"&password="+m+"&page=1&size=8000&type="+type;
			mJsonObject=new JSONObject(excute(url)); 
			data_json=new JSONObject();
			if(null!=mJsonObject){
				int status=mJsonObject.getInt("status");
				if(status==0){
					mJsonArray=mJsonObject.getJSONArray("data");
					sales_amount=new JSONObject();
					stock_amount=new JSONObject();
					for(int a=0;a<mJsonArray.length();a++){
						mObject=(JSONObject)mJsonArray.get(a);
						storeKing=mObject.getString("c6");
						xs_amt=mObject.getDouble("c3");
						kc_amt=mObject.getDouble("c5");
						
						if(storeKing.equals("自营")){
							zhiying_xs=xs_amt+zhiying_xs;
							zhiying_kc=kc_amt=zhiying_kc;
						}else if(storeKing.equals("加盟")){
							jiameng_xs=xs_amt+jiameng_xs;
							jiameng_kc=kc_amt+jiameng_kc;
						}else if(storeKing.equals("联营")){
							lianying_xs=xs_amt+lianying_xs;
							lianying_kc=kc_amt+lianying_kc;
						}
						//零售金额
						sales_amount.put("c2", getZeroDecimal(zhiying_xs));
						sales_amount.put("c3", getZeroDecimal(lianying_xs));
						sales_amount.put("c4", getZeroDecimal(jiameng_xs));
						//库存金额
						stock_amount.put("c1", getZeroDecimal(zhiying_kc));
						stock_amount.put("c2", getZeroDecimal(lianying_kc));
						stock_amount.put("c3", getZeroDecimal(jiameng_kc));
						//总零售额
						tot_xs=zhiying_xs+jiameng_xs+lianying_kc;
						sales_amount.put("c1", getZeroDecimal(tot_xs));
						
						data_json.put("sales_amount", sales_amount);
						data_json.put("stock_amount", stock_amount);

					}
					gl_data.add(s,data_json);
				}else{
					out.print(mJsonObject);
					return;
				}
			}
		}
		gl.put("status", 0);
		gl.put("data", gl_data);
		out.print(gl.toString());
		} catch (Exception e) {
			JSONObject err_5=new JSONObject();
			err_5.put("status",5);
			err_5.put("message","程序异常");
			out.print(err_5);
			return;
		}
%>
