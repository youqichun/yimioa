<%@ page contentType="text/html; charset=utf-8"%>
<%@ page import="java.util.*"%>
<%@ page import="cn.js.fan.util.*"%>
<%@ page import="cn.js.fan.db.*"%>
<%@ page import="com.redmoon.oa.person.*"%>
<%@ page import="com.redmoon.oa.flow.*"%>
<%@ page import="com.redmoon.oa.dept.*"%>
<%@ page import="com.redmoon.oa.basic.*"%>
<%@ page import="com.redmoon.oa.ui.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>基础数据选择</title>
<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css" />
<script type="text/javascript" src="../js/jquery1.7.2.min.js"></script>
<link href="../js/select2/select2.css" rel="stylesheet" />
<script src="../js/select2/select2.js"></script>    
</head>
<body>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
// 当从模式对话框打开本窗口时，因为分属于不同的IE进程，SESSION会丢失，可以用cookie中置sessionId来解决这个问题
String priv="read";
if (!privilege.isUserPrivValid(request,priv))
{
	// out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
	// return;
}
%>
<table class="tabStyle_1" style="padding:0px; margin:0px;" width="100%" cellPadding="0" cellSpacing="0">
  <tbody>
    <tr>
      <td height="28" class="tabStyle_1_title">基础数据选择</td>
    </tr>
    <tr>
      <td height="42" align="center"><%
SelectMgr sm = new SelectMgr();
java.util.Iterator ir = sm.getAllSelect().iterator();
String opts = "";
while (ir.hasNext()) {
	SelectDb sd = (SelectDb)ir.next();
	opts += "<option value='" + sd.getCode() + "'>" + sd.getName() + "</option>";
}
%>
<select id="sel" name="sel" style="width:200px">
<%=opts%>
</select>
&nbsp;&nbsp;<input type="button" value="确定" onClick="doSel()"></td>
    </tr>
  </tbody>
</table>
</body>
<script language="javascript">
<!--
$(function() {
	$('#sel').select2();
});
function doSel() {
	window.opener.setSequence(sel.options[sel.selectedIndex].value, sel.options[sel.selectedIndex].text);
	window.close();
}
//-->
</script>
</html>