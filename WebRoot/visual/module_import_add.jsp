<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.*"%>
<%@ page import="cn.js.fan.util.*"%>
<%@ page import="com.redmoon.oa.fileark.*"%>
<%@ page import="com.redmoon.oa.pvg.*"%>
<%@ page import="cn.js.fan.web.*"%>
<%@ page import="com.redmoon.oa.flow.*"%>
<%@ page import="com.redmoon.oa.visual.*"%>
<%@ page import="com.redmoon.oa.ui.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>智能模块设计 - 导入设置</title>
<link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<script src="../inc/common.js"></script>
</head>
<body>
<jsp:useBean id="usergroupmgr" scope="page" class="com.redmoon.oa.pvg.UserGroupMgr"/>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
String code = ParamUtil.get(request, "code");
String formCode = ParamUtil.get(request, "formCode");
FormDb fd = new FormDb(formCode);
if (!fd.isLoaded()) {
	out.print(StrUtil.Alert_Back("该表单不存在！"));
	return;
}
%>
<%@ include file="module_setup_inc_menu_top.jsp"%>
<script>
$("menu6").className="current"; 
</script>
<div class="spacerH"></div>
<table class="tabStyle_1 percent60" cellspacing="0" cellpadding="3" width="50%" align="center">
  <form name="formRole" method="post" action="module_import_add.do" enctype="multipart/form-data">
    <tbody>
      <tr>
        <td align="left" nowrap class="tabStyle_1_title">请选择文件</td>
      </tr>
      <%
RoleMgr roleMgr = new RoleMgr();		
ModulePrivDb lp = new ModulePrivDb();
Vector vrole = lp.getRolesOfModule(code);

String roleCode;
String roleCodes = "";
String descs = "";
Iterator irrole = vrole.iterator();
while (irrole.hasNext()) {
	RoleDb rd = (RoleDb)irrole.next();
	roleCode = rd.getCode();
	if (roleCodes.equals(""))
		roleCodes += roleCode;
	else
		roleCodes += "," + roleCode;
	if (descs.equals(""))
		descs += rd.getDesc();
	else
		descs += "," + rd.getDesc();
}
%>
      <tr class="row" style="BACKGROUND-COLOR: #ffffff">
        <td align="center">
	        <input title="选择文件" type="file" size="20" name="excel" />    
        	<input name="code" value="<%=code%>" type=hidden>
            <input name="formCode" value="<%=formCode%>" type=hidden></td>
      </tr>
      <tr align="center" class="row" style="BACKGROUND-COLOR: #ffffff">
        <td style="PADDING-LEFT: 10px"><input name="Submit3" type="submit" class="btn" value="确定"></td>
      </tr>
    </tbody>
  </form>
</table>
<br>
</body>
</html>