<%@ page contentType="text/html;charset=utf-8" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.*" %>
<%@ page import="cn.js.fan.db.*" %>
<%@ page import="cn.js.fan.util.*" %>
<%@ page import="com.redmoon.oa.pvg.*" %>
<%@ page import="com.redmoon.oa.dept.*" %>
<%@ page import="com.redmoon.oa.flow.*" %>
<%@ page import="com.redmoon.oa.flow.query.*" %>
<%@ page import="com.redmoon.oa.ui.*" %>
<%@ page import="com.cloudwebsoft.framework.db.*" %>
<%@ page import="org.json.*" %>
<%@ page import="com.redmoon.oa.util.FlowPredefineDirUtil" %>
<%@ page import="com.redmoon.oa.kernel.License" %>
<%@ taglib uri="/WEB-INF/tlds/HelpDocTag.tld" prefix="help" %>
<%
    FormDb fd = new FormDb();
    String opera = ParamUtil.get(request, "opera");
    if (opera.equals("getFormColumn")) {
        JSONObject json = new JSONObject();
        String formCode = ParamUtil.get(request, "formCode");
        fd = fd.getFormDb(formCode);
        Iterator field_v = fd.getFields().iterator();
        String str = "";
        while (field_v.hasNext()) {
            FormField ff = (FormField) field_v.next();
            str += "<span id='{" + ff.getName() + "}' name='list_field' onMouseOut='outtable(this)' onMouseOver='overtable(this)' style='width:200px;'>" + ff.getTitle() + "</span><br/>";
        }
        json.put("ret", "1");
        json.put("msg", str);
        out.print(json);
        return;
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>添加流程类型</title>
    <link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/css.css"/>
    <link type="text/css" rel="stylesheet" href="../skin/flow_predefine.css"/>
    <style>
        .unit {
            background-color: #CCC;
        }
    </style>
    <script src="../inc/common.js"></script>
    <script src="../js/jquery.js"></script>
    <script src="../js/jquery-alerts/jquery.alerts.js" type="text/javascript"></script>
    <script src="../js/jquery-alerts/cws.alerts.js" type="text/javascript"></script>
    <link href="../js/jquery-alerts/jquery.alerts.css" rel="stylesheet" type="text/css" media="screen"/>
    <script src="../inc/map.js"></script>
    <script src="../js/jquery.form.js"></script>
    <script src="../js/jquery-ui/jquery-ui.js"></script>
    <script src="../js/jquery.bgiframe.js"></script>
    <link type="text/css" rel="stylesheet" href="<%=SkinMgr.getSkinPath(request)%>/jquery-ui/jquery-ui.css"/>
    <script>
        function form1_onsubmit() {
            o("type").value = o("seltype").value;
            if (o("unitCode").value == "") {
                jAlert("请选择单位！", "提示");
                return false;
            }

            if (o("queryId") != null) {
                var condMap = createCondMap();
                o("queryCondMap").value = condMap;
            }
        }

        function selTemplate(id) {
            if (o("templateId").value != id) {
                o("templateId").value = id;
            }
        }

        function enableSelType() {
            jConfirm("如果该项中已经含有内容，则更改以后会造成问题，您要强制更改吗？", "提示", function (r) {
                if (!r) {
                    return;
                } else {
                    o("seltype").disabled = false;
                }
            })
        }

        function openWinDepts() {
            var ret = showModalDialog('../dept_multi_sel.jsp', window.self, 'dialogWidth:480px;dialogHeight:320px;status:no;help:no;')
            if (ret == null)
                return;
            o("deptNames").value = "";
            o("depts").value = "";
            for (var i = 0; i < ret.length; i++) {
                if (o("deptNames").value == "") {
                    o("depts").value += ret[i][0];
                    o("deptNames").value += ret[i][1];
                } else {
                    o("depts").value += "," + ret[i][0];
                    o("deptNames").value += "," + ret[i][1];
                }
            }
            if (o("depts").value.indexOf("<%=DeptDb.ROOTCODE%>") != -1) {
                o("depts").value = "<%=DeptDb.ROOTCODE%>";
                o("deptNames").value = "全部";
            }
        }
    </script>
</head>
<body>
<jsp:useBean id="privilege" scope="page" class="com.redmoon.oa.pvg.Privilege"/>
<%
    if (!privilege.isUserPrivValid(request, "admin.flow") && !privilege.isUserPrivValid(request, "admin.unit")) {
        out.print(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid")));
        return;
    }

    Directory dir = new Directory();
    String parent_code = ParamUtil.get(request, "parent_code");
    if (parent_code.equals(""))
        parent_code = "root";
    String parent_name = "";

    String code = ParamUtil.get(request, "code");

    String op = ParamUtil.get(request, "op");
    if (op.equals(""))
        op = "AddChild";
    LeafPriv lp;
    if (op.equals("AddChild")) {
        lp = new LeafPriv(parent_code);
        code = RandomSecquenceCreator.getId(20);
    } else {
        lp = new LeafPriv(code);
    }

    String name = ParamUtil.get(request, "name");
    String description = ParamUtil.get(request, "description");
    boolean isHome = false;
    String params = "";
    int type = 0;
    Leaf leaf = null;
    if (op.equals("modify")) {
        leaf = dir.getLeaf(code);
        name = leaf.getName(request);
        description = leaf.getDescription();
        type = leaf.getType();
        isHome = leaf.getIsHome();
        parent_code = leaf.getParentCode();
        params = leaf.getParams();
    }

    Leaf parentLf = null;
    if (!parent_code.equals("") && !parent_code.equals("-1")) {
        parentLf = dir.getLeaf(parent_code);
        parent_name = parentLf.getName(request);
    }

    String myUnitCode = privilege.getUserUnitCode(request);

    // 如果是根目录，则允许单位管理员添加类别
    if (!parent_code.equals(Leaf.CODE_ROOT)) {
        // 单位管理员可以管理本单位的流程
        if (op.equals("modify") && privilege.isUserPrivValid(request, "admin.unit") && leaf.getUnitCode().equals(myUnitCode))
            ;
            // 如果是添加流程
        else if (op.equals("AddChild") && privilege.isUserPrivValid(request, "admin.unit") && parentLf.getUnitCode().equals(myUnitCode))
            ;
        else if (!lp.canUserExamine(privilege.getUser(request))) {
            out.println(cn.js.fan.web.SkinUtil.makeErrMsg(request, cn.js.fan.web.SkinUtil.LoadString(request, "pvg_invalid"), true));
            return;
        }
    }
%>
<%if (op.equals("AddChild")) {%>
<%@ include file="flow_inc_menu_top.jsp" %>
<script>
    o("menu7").className = "current";
</script>
<%} else {%>
<%@ include file="flow_inc_menu_top.jsp" %>
<script>
    o("menu3").className = "current";
</script>
<%}%>
<div class="spacerH"></div>
<%
    String flowTypeCode = "";
    if (op.equals("modify"))
        flowTypeCode = leaf.getParentCode();
    else
        flowTypeCode = parent_code;

    Vector formV = fd.listOfFlow(flowTypeCode);
%>
<form name="form1" id="form1" method="post" action="flow_predefine_left.jsp?op=<%=op%>" target="flowPredefineLeftFrame" onsubmit="return form1_onsubmit()">
    <table width="98%" align="center" class="tabStyle_1 percent80" style="position:relative">
        <tr>
            <td colspan="3" align="center" class="tabStyle_1_title"><%=op.equals("AddChild") ? "添加" : "编辑属性"%>
            </td>
        </tr>
        <tr>
            <td align="left" width="150px;">名称</td>
            <td colspan="2" align="left">
                <input name="name" id="name" maxlength="50" size="50" value="<%=name%>">
                <input type=hidden name=parent_code value="<%=parent_code%>"/>
            </td>
        </tr>
        <%
            boolean isDefaultTitleTrShow = true;
            if (op.equals("modify") && leaf.getType() == Leaf.TYPE_NONE) {
                isDefaultTitleTrShow = false;
            }
            if (op.equals("AddChild") && parent_code.equals("root")) {
                isDefaultTitleTrShow = false;
            }

            if (isDefaultTitleTrShow) {
        %>
        <tr>
            <td align="left">自动生成标题</td>
            <td colspan="2">
                <input name="description" id="description" value="<%=StrUtil.getNullStr(description)%>" size="50" onblur="content_change()"/>
                例如：<span name="description_show" id="description_show" size="50"><%=FlowPredefineDirUtil.titleReplaceSTC(StrUtil.getNullStr(description), code) %></span>&nbsp;&nbsp;&nbsp;
                <help:HelpDocTag id="948" type="content" size="200"></help:HelpDocTag>

            </td>
        </tr>
        <%}%>
        <tr <%=parent_code.equals("root") ? "style='display:none'" : ""%>>
            <td align="left">类型</td>
            <td colspan="2" align="left"><%
                String disabled = "";
                if (op.equals("modify")) // && leaf.getType()>=1)
                    disabled = "true";
            %>
                <select id="seltype" name="seltype" onchange="seltypeOnChange()">
                    <%
                        if ((op.equals("AddChild") && parent_code.equals("root")) || (op.equals("modify") && leaf.getType() == Leaf.TYPE_NONE)) {%>
                    <option value="<%=Leaf.TYPE_NONE%>">分类</option>
                    <%} else {%>
                    <option value="<%=Leaf.TYPE_LIST%>" <%=op.equals("AddChild") ? "selected" : ""%>>固定流程</option>
                    <option value="<%=Leaf.TYPE_FREE%>">自由流程</option>
                    <%}%>
                </select>
                <script>
                    <%if (op.equals("modify")) {%>
                    form1.seltype.value = "<%=type%>"
                    <%}else{
                            if (parent_code.equals("root")) {
                          %>
                    form1.seltype.value = "<%=Leaf.TYPE_NONE%>"
                    <%
                    }
              }%>
                    form1.seltype.disabled = "<%=disabled%>"
                </script>
                <input type="hidden" name="root_code" value="">
                <input type="hidden" id="type" name="type" value="<%=type%>">
            </td>
        </tr>
        <tr style="display: none;">
            <td align="left">父结点</td>
            <td colspan="2" align="left">
                <%if (op.equals("modify")) {%>
                <%if (leaf.getCode().equals(leaf.CODE_ROOT)) {%>
                <input name="parentCode" value="-1" type="hidden">
                <%} else {%>
                <select name="parentCode">
                    <%
                        Leaf rootlf = leaf.getLeaf("root");
                        DirectoryView dv = new DirectoryView(rootlf);
                        dv.ShowDirectoryAsOptionsWithCode(out, rootlf, rootlf.getLayer());
                    %>
                </select>
                <script>
                    o("parentCode").value = "<%=leaf.getParentCode()%>";
                </script>
                <%
                    }
                } else {
                %>
                <%=parent_name%>
                <%}%>
            </td>
        </tr>
        <%
            boolean isFormTrShow = true;
            if (op.equals("AddChild") && parent_code.equals("root")) {
                isFormTrShow = false;
            }
            if (op.equals("modify") && leaf.getType() == Leaf.TYPE_NONE) {
                isFormTrShow = false;
            }

            License lic = License.getInstance();
            String strDisplay = isFormTrShow ? ("isNotDisplay='" + (lic.isPlatformSrc() ? "false" : "true") + "'") : "style='display:none' isNotDisplay='true' ";
        %>
        <tr <%=strDisplay%>>
            <td align="left">表单</td>
            <td colspan="2" align="left"><%
                boolean canEditForm = true;
                if (op.equals("modify")) {
                    WorkflowDb wfd = new WorkflowDb();
                    int count = wfd.getWorkflowCountOfType(leaf.getCode());
                    fd = fd.getFormDb(StrUtil.getNullString(leaf.getFormCode()));
                    if (leaf.getType() == Leaf.TYPE_LIST || leaf.getType() == Leaf.TYPE_FREE) {
                        if (count > 0) {
                            canEditForm = true;
            %>
                <!--流程数量现有<%=count%>个
                <input name="formCode" value="<%=leaf.getFormCode()%>" type="hidden">-->
                <%
                            } else
                                canEditForm = true;
                        } else
                            canEditForm = true;
                    }
                    if (canEditForm) {
                %>
                <select name="formCode" id="formCode">
                    <option value="">请选择</option>
                    <%
                        Iterator ir = formV.iterator();
                        while (ir.hasNext()) {
                            fd = (FormDb) ir.next();
                    %>
                    <option value="<%=fd.getCode()%>"><%=fd.getName()%>
                    </option>
                    <%
                        }
                    %>
                </select>
                <%if (op.equals("modify")) {%>
                <script>
                    o("formCode").value = "<%=leaf.getFormCode()%>";
                </script>
                <%}%>
                <%}%>
                <input type="hidden" name="isHome" value="true">
            </td>
        </tr>
        <tr <%=strDisplay%>>
            <td align="left">手机客户端</td>
            <td colspan="2" align="left">
                <%
                    String strChecked = "", locationChecked = "", cameraChecked = "";
                    if (op.equals("modify")) {
                        strChecked = leaf.isMobileStart() ? "checked" : "";
                        locationChecked = leaf.isMobileLocation() ? "checked" : "";
                        cameraChecked = leaf.isMobileCamera() ? "checked" : "";
                    }
                %>
                <input id="isMobileStart" name="isMobileStart" type="checkbox" <%=strChecked%> value="1"/>
                发起
                <!--  <input id="isMobileLocation" name="isMobileLocation" type="checkbox" <%=locationChecked%> value="1" />
      定位
      <input id="isMobileCamera" name="isMobileCamera" type="checkbox" <%=cameraChecked%> value="1" />
      拍照 -->
            </td>
        </tr>
        <tr>
            <td colspan="3" align="left">
                <div id="afBox" class="af_box">
                    <span><a id="afBtn" href="javascript:;" title="高级选项"><img id="afBtnImg" src="<%=SkinMgr.getSkinPath(request)%>/images/af_arrow_down.png" width="27" height="14"/></a></span>
                    <div class="af_line"></div>
                </div>
                <script>
                    $(function () {
                        $('#afBtn').click(function () {
                            if ($(this).html().indexOf("down") == -1) {
                                $('#afBtnImg')[0].src = "<%=SkinMgr.getSkinPath(request)%>/images/af_arrow_down.png";
                                $('#trQuery').hide();
                                $('#trQueryCond').hide();
                                $('#trQueryRole').hide();
                                $('#trMode').hide();
                                $('#trPluin').hide();
                                $('#trDept').hide();
                                $('#trUnit').hide();
                                $('#trUse').hide();
                                $('#trTemplate').hide();
                                <%
                                    if (op.equals("modify")) {
                                %>
                                $('#trCode').hide();
                                <%
                                    }
                                %>
                                $('#trParams').hide();
                            } else {
                                $('#afBtnImg')[0].src = "<%=SkinMgr.getSkinPath(request)%>/images/af_arrow_up.png";
                                <%if (parentLf!=null && parentLf.getLayer() == 2) {%>
                                $('#trQuery').show();
                                $('#trQueryCond').show();
                                $('#trQueryRole').show();
                                <%}%>
                                if ($('#trMode').attr("isNotDisplay") != "true")
                                    $('#trMode').show();
                                $('#trPluin').show();
                                $('#trDept').show();
                                $('#trUnit').show();
                                $('#trUse').show();
                                $('#trTemplate').show();
                                <%
                                    if (op.equals("modify")) {
                                %>
                                $('#trCode').show();
                                <%
                                    }
                                %>
                                <%if (parentLf!=null && parentLf.getLayer() == 2) {%>
                                $('#trParams').show();
                                <%}%>
                            }
                        });
                    });
                </script>
            </td>
        </tr>
        <tr id="trUse" style="display:none">
            <td align="left" width="25%">启用</td>
            <td colspan="2" align="left">
                <select id="isOpen" name="isOpen">
                    <option value="1">是</option>
                    <option value="0">否</option>
                </select>
                <%if (op.equals("modify")) {%>
                <script>
                    o("isOpen").value = "<%=leaf.isOpen()?1:0%>";
                </script>
                <%}%>
            </td>
        </tr>
        <tr id="trCode" style="display:none">
            <td width="17%" align="left">编码</td>
            <td colspan="2" align="left"><input id="code" maxlength="20" size="50" name="code" style="background-color:#eee;" readonly value="<%=code%>" onfocus="this.select()" <%=op.equals("modify")?"readonly":""%>/></td>
        </tr>
        <tr id="trParams" style="display:none">
            <td width="17%" align="left">参数</td>
            <td colspan="2" align="left"><input id="params" maxlength="20" size="50" name="params" value="<%=params%>"/>
                <div>可用参数：$userName，表示当前用户名，格式：user_name=$userName</div>
            </td>
        </tr>
        <%if (!code.equals(Leaf.CODE_ROOT) && parentLf.getLayer() == 2) {%>
        <tr id="trTemplate" style="display:none">
            <td align="left">公文模板</td>
            <td colspan="2" align="left">
                <select id="templateId" name="templateId" title="用于模板套红">
                    <option value="-1">无</option>
                    <%
                        DocTemplateDb dtd = new DocTemplateDb();
                        Iterator ir2 = dtd.list().iterator();
                        while (ir2.hasNext()) {
                            dtd = (DocTemplateDb) ir2.next();
                    %>
                    <option value="<%=dtd.getId()%>"><%=dtd.getTitle()%>
                    </option>
                    <%
                        }
                    %>
                </select>
                （用于模板套红）
                <%if (op.equals("modify")) {%>
                <script>
                    document.getElementById("templateId").value = "<%=leaf.getTemplateId()%>";
                </script>
                <%} %>
            </td>
        </tr>
        <%}%>
        <tr id="trMode" <%=strDisplay%> style="display:none">
            <td align="left">运行模式</td>
            <td colspan="2" align="left" title="运行于调试模式时，可以直接切换用户，表单的修改立即生效，流转时不会发消息通知，调试完毕后应恢复为正常模式，以便于显示历史表单记录">
                <select id="isDebug" name="isDebug">
                    <option value="0">正常</option>
                    <option value="1">调试</option>
                </select>
                <%if (op.equals("modify")) {%>
                <script>
                    o("isDebug").value = "<%=leaf.isDebug()?1:0%>";
                </script>
                <%}%>
            </td>
        </tr>
        <tr id="trDept" style="display:none">
            <td align="left">能发起流程的部门</td>
            <td width="43%" align="left"><input type="hidden" name="depts" value="<%=op.equals("modify")?leaf.getDept().trim():""%>">
                <textarea name="deptNames" style="width: 100%;" rows="5" readOnly wrap="yes" id="deptNames"><%
                    if (op.equals("modify")) {
                        String[] arydepts = StrUtil.split(leaf.getDept(), ",");
                        int len = 0;
                        String deptNames = "";
                        if (arydepts != null) {
                            len = arydepts.length;
                            DeptDb dd = new DeptDb();
                            for (int i = 0; i < len; i++) {
                                if (deptNames.equals("")) {
                                    dd = dd.getDeptDb(arydepts[i]);
                                    if (!dd.isLoaded()) {
                                        deptNames = arydepts[i] + "(不存在)";
                                    } else {
                                        deptNames = dd.getName();
                                    }
                                } else {
                                    dd = dd.getDeptDb(arydepts[i]);
                                    deptNames += "," + dd.getName();
                                }
                            }
                        }
                        out.print(deptNames);
                    }
                %></textarea>
                <br/>
                (&nbsp;空表示所有部门都可以发起流程&nbsp;)
            </td>
            <td align="left"><p>
                <input class="btn" title="选择部门" onclick="openWinDepts()" type="button" value="添 加" name="button"/>
            </p>
                <p>
                    <input class="btn" title="清空部门" onclick="form1.deptNames.value='';form1.depts.value=''" type="button" value="清 空" name="button"/>
                </p></td>
        </tr>
        <tr id="trUnit" style="display:none">
            <td align="left">单位</td>
            <td colspan="2" align="left">
                <%
                    if (myUnitCode.equals(DeptDb.ROOTCODE)) {%>
                <select id="unitCode" name="unitCode" onchange="if (this.value=='') jAlert('请选择单位！','提示');" style="width:150px;">
                    <option value="<%=Leaf.UNIT_CODE_PUBLIC%>">-公共流程-</option>
                    <%
                        DeptDb rootDept = new DeptDb();
                        rootDept = rootDept.getDeptDb(DeptDb.ROOTCODE);
                    %>
                    <option value="<%=DeptDb.ROOTCODE%>"><%=rootDept.getName()%>
                    </option>
                    <%
                        // Iterator ir = privilege.getUserAdminUnits(request).iterator();
                        Iterator ir = rootDept.getChildren().iterator();
                        while (ir.hasNext()) {
                            DeptDb dd = (DeptDb) ir.next();
                            String cls = "", val = "";
                            if (dd.getType() == DeptDb.TYPE_UNIT) {
                                cls = " class='unit' ";
                                val = dd.getCode();
                    %>
                    <option <%=cls%> value="<%=val%>">&nbsp;&nbsp;&nbsp;&nbsp;<%=dd.getName()%>
                    </option>
                    <%
                        }
                    %>
                    <!--
                <%
                Iterator ir2 = dd.getChildren().iterator();
                while (ir2.hasNext()) {
                    DeptDb dd2 = (DeptDb)ir2.next();
                    String cls2 = "", val2 = "";
                    if (dd2.getType()==DeptDb.TYPE_UNIT) {
                        cls2 = " class='unit' ";
                        val2 = dd2.getCode();
                    }
                    %>
                      <option <%=cls2%> value="<%=val2%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=dd2.getName()%></option>
                      <%
                      Iterator ir3 = dd2.getChildren().iterator();
                      while (ir3.hasNext()) {
                          DeptDb dd3 = (DeptDb)ir3.next();
                          String cls3 = "", val3 = "";
                          if (dd3.getType()==DeptDb.TYPE_UNIT) {
                              cls3 = " class='unit' ";
                              val3 = dd3.getCode();
                          }
                          %>
                            <option <%=cls3%> value="<%=val3%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=dd3.getName()%></option>
                              <%
                              Iterator ir4 = dd3.getChildren().iterator();
                              while (ir4.hasNext()) {
                                  DeptDb dd4 = (DeptDb)ir4.next();
                                  String cls4 = "", val4 = "";
                                  if (dd4.getType()==DeptDb.TYPE_UNIT) {
                                      cls4 = " class='unit' ";
                                      val4 = dd4.getCode();
                                  }
                                  %>
                                    <option <%=cls4%> value="<%=val4%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=dd4.getName()%></option>
                                      <%
                                      Iterator ir5 = dd4.getChildren().iterator();
                                      while (ir5.hasNext()) {
                                          DeptDb dd5 = (DeptDb)ir5.next();
                                          String cls5 = "", val5 = "";
                                          if (dd5.getType()==DeptDb.TYPE_UNIT) {
                                            cls5 = " class='unit' ";
                                            val5 = dd5.getCode();
                                          }
                                          %>
                                            <option <%=cls5%> value="<%=val5%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=dd5.getName()%></option>
                                      <%}                                
                              }
                      }
                }
                %>
                -->
                    <%
                        }
                    %>
                </select>(公共流程为所有子单位可见)
                <%if (op.equals("modify")) {%>
                <script>
                    form1.unitCode.value = "<%=leaf.getUnitCode()%>";
                </script>
                <%}%>
                <%} else {%>
                <input name="unitCode" value="<%=myUnitCode%>" type="hidden"/>
                <%
                        DeptDb dd = new DeptDb();
                        dd = dd.getDeptDb(myUnitCode);
                        out.print(dd.getName());
                    }%>
            </td>
        </tr>
        <%if (op.equals("modify")) {%>
        <tr id="trQuery" style="display:none">
            <td align="left">关联查询</td>
            <td colspan="2" align="left">
      	<span id="queryTitle">
        <%
            if (op.equals("modify")) {
                long queryId = leaf.getQueryId();
                if (queryId != Leaf.QUERY_NONE) {
                    FormQueryDb fqd = new FormQueryDb();
                    fqd = fqd.getFormQueryDb((int) queryId);
        %>
<%=fqd.getQueryName()%>&nbsp;&nbsp;
	            <a href='javascript:;' onClick="clearCondMap();">×</a>                
                <%
                        }
                    }
                %>
        </span>&nbsp;
                <script>
                    function clearCondMap() {
                        $('#queryTitle').html('');
                        $('#queryId').val('');
                        $('#queryCondMap').val('');
                        // $('#divFields').html('');
                        var c = 0;
                        $("[id^=divField]").each(function () {
                            if ($(this).attr("id") == "divFields") {
                                return;
                            }
                            if ($(this).attr("id") == "divField0") {
                                // 跳过第一个
                                if (c == 0) {
                                    c++;
                                    return;
                                }
                                $(this).remove();
                            }
                        });
                        $('#queryField0').html('');
                    }
                </script>
                <input id="queryId" name="queryId" type="hidden" value="<%=op.equals("modify")?leaf.getQueryId():""%>"/>
                <a href="javascript:;" onClick="selQuery()">选择查询</a>
                &nbsp;&nbsp;
                <a href="javascript:" onClick="addFields()">添加映射</a>
                <input id="queryCondMap" name="queryCondMap" type="hidden" value="<%=op.equals("modify")?leaf.getQueryCondMap():""%>"/>
                &nbsp;&nbsp;(注意普通查询的条件中字段值不能为空)
            </td>
        </tr>
        <tr id="trQueryCond" style="display:none">
            <td align="left">条件映射</td>
            <td colspan="2" align="left">
                <div id="divFields">
                    <%
                        int count = 0;
                        String condJson = "{'field1':'sqlfield1'}";
                        if (op.equals("modify") && !leaf.getQueryCondMap().equals("")) {
                            if (!leaf.getQueryCondMap().equals("{}"))
                                condJson = leaf.getQueryCondMap();
                        }

                        JSONObject json = new JSONObject(condJson);
                        Iterator ir3 = json.keys();
                        fd = fd.getFormDb(leaf.getFormCode());
                        while (ir3.hasNext()) {
                            String key = (String) ir3.next();
                    %>
                    <div id="divField<%=count%>">
                        <div>
                            <select id="field<%=count%>" name="field">
                                <option value="">无</option>
                                <!--<option value="<%=FormSQLBuilder.PRIMARY_KEY_ID%>">主键ID</option>-->
                                <%
                                    Iterator ir = fd.getFields().iterator();
                                    while (ir.hasNext()) {
                                        FormField ff = (FormField) ir.next();
                                        if (!ff.isCanQuery())
                                            continue;
                                %>
                                <option value="<%=ff.getName()%>"><%=ff.getTitle()%>
                                </option>
                                <%
                                    }
                                %>
                            </select>
                            <font style="font-family:宋体">-&gt;</font>
                            <span id="spanQueryField<%=count%>">
              <%
                  if (op.equals("modify") && leaf.getQueryId() != Leaf.QUERY_NONE) {
                      FormQueryDb aqd = new FormQueryDb();
                      aqd = aqd.getFormQueryDb((int) leaf.getQueryId());
                      if (aqd.isLoaded()) {
                          if (!aqd.isScript()) {
                              String formCode = aqd.getTableCode();
                              FormDb fdb = new FormDb();
                              fdb = fdb.getFormDb(formCode);
              %>
							<select id="queryField<%=count%>" name="queryField">
							<option value="">无</option>
							<%
                                String querySql = "select distinct condition_field_code from form_query_condition where query_id=" + leaf.getQueryId() + " order by id";
                                // System.out.println(getClass() + " sql=" + sql);
                                JdbcTemplate jt = new JdbcTemplate();
                                ResultIterator ri = jt.executeQuery(querySql);
                                while (ri.hasNext()) {
                                    ResultRecord rr = (ResultRecord) ri.next();
                                    String fieldCode = rr.getString(1);
                                    FormField ff = fdb.getFormField(fieldCode);
                                    if (ff != null) {
                            %>
								  <option value="<%=ff.getName()%>"><%=ff.getTitle()%></option>
								<%
                                        }
                                    }
                                %>
							</select>
							<%
                            } else {
                                QueryScriptUtil qsu = new QueryScriptUtil();
                                HashMap map = qsu.getCondFields(request, aqd);
                                // System.out.println(getClass() + " map=" + map);
                                Iterator irMap = map.keySet().iterator();
                            %>
							<select id="queryField<%=count%>" name="queryField">
							<option value="">无</option>	
							<%
                                while (irMap.hasNext()) {
                                    String keyName = (String) irMap.next();
                            %>
								<option value="<%=keyName%>"><%=map.get(keyName)%></option>
							<%
                                }
                            %>
							</select>
							<%
                                        }
                                    }
                                }

                            %>
			  <script>
              $("#field<%=count%>").val("<%=key%>");
              $("#queryField<%=count%>").val("<%=json.get(key)%>");
              </script>              
              </span>
                            <a href='javascript:;' onClick="if (false && $(this).parent().parent().parent().children().length==1) {jAlert('至少需映射一个条件字段！','提示'); return;} var pNode=this.parentNode; pNode.parentNode.parentNode.removeChild(pNode.parentNode);">×</a>
                        </div>
                    </div>
                    <%
                            count++;
                        }
                    %>
                </div>
            </td>
        </tr>
        <tr id="trQueryRole" style="display:none">
            <td align="left">能看见查询结果的角色</td>
            <td colspan="2" align="left">
                <%
                    String roleCode, desc;
                    String roleCodes = "";
                    String descs = "";
                    if (op.equals("modify")) {
                        RoleMgr roleMgr = new RoleMgr();
                        String[] roles = StrUtil.split(leaf.getQueryRole(), ",");
                        int len = 0;
                        if (roles != null)
                            len = roles.length;

                        for (int i = 0; i < len; i++) {
                            RoleDb rd = roleMgr.getRoleDb(roles[i]);
                            roleCode = rd.getCode();
                            desc = rd.getDesc();
                            if (roleCodes.equals(""))
                                roleCodes += roleCode;
                            else
                                roleCodes += "," + roleCode;
                            if (descs.equals(""))
                                descs += desc;
                            else
                                descs += "," + desc;
                        }
                    }
                %>
                <textarea name="roleDescs" cols="45" rows="5"><%=descs%></textarea>
                <input name="queryRole" value="<%=roleCodes%>" type="hidden"/>
                <%
                    String urlUnitCode = "";
                    com.redmoon.oa.person.UserDb user = new com.redmoon.oa.person.UserDb();
                    user = user.getUserDb(privilege.getUser(request));
                    if (!privilege.isUserPrivValid(request, "admin")) {
                        urlUnitCode = user.getUnitCode();
                    }
                %>
                <input class="btn" type="button" onclick="showModalDialog('../role_multi_sel.jsp?roleCodes=<%=roleCodes%>&unitCode=<%=urlUnitCode%>',window.self,'dialogWidth:526px;dialogHeight:435px;status:no;help:no;')" value="选择"/>
                <br/>
                (空表示所有人员都能看见)
            </td>
        </tr>
        <%}%>
        <tr>
            <td colspan="3" align="center" valign="top"><input class="btn" onclick="check()" type="button" value="确定"/>
                <!--
                &nbsp;&nbsp;&nbsp;
                <input name="button" type="button" onClick="enableSelType()" value="强制类型修改">
                -->
                <%if (op.equals("modify")) {%>
                &nbsp;&nbsp;
                <input class="btn" type="button" onClick="jConfirm('您确定要删除么？相关流程也将会一起被删除！\r\n此操作不可逆，请预先做好数据备份！','提示',function(r){ if(!r){return;}else{window.parent.flowPredefineLeftFrame.location.href='flow_predefine_left.jsp?op=del&root_code=root&delcode=<%=StrUtil.UrlEncode(code)%>'}}) " style="cursor:pointer"
                       value="删除"/>
                &nbsp;&nbsp;
                <input class="btn" type="button" onclick="window.parent.flowPredefineLeftFrame.location.href='flow_predefine_left.jsp?op=move&root_code=root&direction=up&code=<%=StrUtil.UrlEncode(code)%>'" value="上移"/>
                &nbsp;&nbsp;
                <input class="btn" type="button" onclick="window.parent.flowPredefineLeftFrame.location.href='flow_predefine_left.jsp?op=move&root_code=root&direction=down&code=<%=StrUtil.UrlEncode(code)%>'" value="下移"/></td>
            <%}%>
        </tr>
    </table>
    <table class="jcalculator_wrap" id="divTable">
        <tr>
            <td>
                <div>
                    <div id="showTitle" class="jcalculator" style="display:none;width:330px;">
                        <div id="jcalculator" style="float:left;width:160px;">
                            <span id="C" onMouseOut="outtable(this)" onMouseOver="overtable(this)">清除</span>
                            <span id="{dept}" onMouseOut="outtable(this)" onMouseOver="overtable(this)">部门简称</span>
                            <span id="{user}" onMouseOut="outtable(this)" onMouseOver="overtable(this)">发起人</span>
                            <span id="名称" onMouseOut="outtable(this)" onMouseOver="overtable(this)">流程名称</span><br/>
                            <span id="{date:yyyy-MM-dd}" onMouseOut="outtable(this)" onMouseOver="overtable(this)">年-月-日</span>
                            <span id="{date:MM-dd}" onMouseOut="outtable(this)" onMouseOver="overtable(this)">月-日</span>
                            <span id="{date:MM-dd-yyyy}" onMouseOut="outtable(this)" onMouseOver="overtable(this)">月-日-年</span>
                            <span id=":" onMouseOut="outtable(this)" onMouseOver="overtable(this)">：</span>
                        </div>
                        <div class="jcalculator_1" style="overflow-y:auto;overflow-x:hidden;float:right;" id="jcalculator_1">
                            <%
                                Iterator ir = fd.getFields().iterator();
                                while (ir.hasNext()) {
                                    FormField ff = (FormField) ir.next();
                            %>
                            <span id="{<%=ff.getName() %>}" name="list_field" onMouseOut="outtable(this)" onMouseOver="overtable(this)" style="width:200px;"><%=ff.getTitle() %></span><br/>
                            <%}%>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
    </table>
</form>
</body>
<script>
    function content_change() {
        var content = $("#description").val();
        $("span[name='list_field']").each(function () {
            if (content.indexOf($(this).attr("id")) != -1) {
                content = content.replaceAll($(this).attr("id"), $(this).html());
            }
        })
        if (content.indexOf("{dept}") != -1) {
            content = content.replaceAll("{dept}", "行政部");
        }
        if (content.indexOf("{user}") != -1) {
            content = content.replaceAll("{user}", "张三");
        }
        if (content.indexOf("{date:yyyy-MM-dd}") != -1) {
            content = content.replaceAll("{date:yyyy-MM-dd}", "日期：2001-10-01");
        }
        if (content.indexOf("{date:MM-dd}") != -1) {
            content = content.replaceAll("{date:MM-dd}", "日期：10-01");
        }
        if (content.indexOf("{date:MM-dd-yyyy}") != -1) {
            content = content.replaceAll("{date:MM-dd-yyyy}", "日期：10-01-2001");
        } else {

        }
        $("#description_show").html(content);
    }

    function check() {
        var name = $("#name").val();
        var ticontent = $("#description").val();
        var selectOp = $("#formCode").val();
        if (name == "") {
            jAlert("名称未填写", "提示");
            return;
        } else {
            <%
            if (!parent_code.equals("root")) {
            %>
            if (selectOp == "") {
                jAlert("表单未选择", "提示");
                return;
            }
            <%
            }
            %>
        }
        form1_onsubmit();
        o("form1").submit();
    }

    function overtable(this_s) {
        this_s.style.backgroundColor = "#60acec";
    }

    function outtable(this_s) {
        this_s.style.backgroundColor = "white";
    }

    $(function () {
        $("#description").focus(function () {
            if (<%=canEditForm%>) {
                var formCode = $("#formCode").val();
                $.ajax({
                    type: "post",
                    url: "flow_predefine_dir.jsp",
                    data: {
                        opera: "getFormColumn",
                        formCode: formCode,
                        parent_code: "<%=parent_code%>",
                        op: "<%=parent_code%>"
                    },
                    dataType: "html",
                    beforeSend: function (XMLHttpRequest) {
                    },
                    success: function (data, status) {
                        data = $.parseJSON(data);
                        if (data.ret == "1") {
                            $("#jcalculator_1").empty();
                            $("#jcalculator_1").html(data.msg);

                            $("#showTitle").css("display", "block");
                        }
                    },
                    complete: function (XMLHttpRequest, status) {
                    },
                    error: function (XMLHttpRequest, textStatus) {
                        // 请求出错处理
                        //alert(XMLHttpRequest.responseText);
                    }
                });


            } else {
                $("#showTitle").css("display", "block");
            }
        });

        $(document).bind("click", function (e) {
            e = e || window.event;
            var dom = e.srcElement || e.target;
            if (dom.id != "description") {
                if (dom.parentNode.id != "jcalculator_1" && dom.id != 'jcalculator_1' && dom.id != "showTitle" && dom.parentNode.id != "jcalculator" && dom.parentNode.id != "showTitle" && document.getElementById("showTitle").style.display == "block") {
                    document.getElementById("showTitle").style.display = "none";
                }
            }
        });


        var description = $("#description").val();
        $("#jcalculator span").live('click', function () {
            var code = $(this).attr("id");
            if (code == "zidingyi") {  //如果是自定义按钮，则不加上字符内容
                return;
            }
            description = $("#description").val();
            if (code == "C") {
                $("#description").val("");
                $("#description_show").html("");
                return;
            }
            if (code == "名称") {
                code = $("#name").val();
            }

            $("#description").val(description + " " + code);
            content_change();
        });

        $("#jcalculator_1 span").live('click', function () {
            ;
            var code = $(this).attr("id");
            var show = $(this).html();
            description = $("#description").val();
            var description_show = $("#description_show").html();
            $("#description").val(description + " " + code);
            $("#description_show").html(description_show + " " + show);
        });


        if (isIE10) {
            document.getElementById("divTable").style.left = "220px";
        } else if (getOS() == 2) {
            document.getElementById("divTable").style.left = "190px";
        } else if (getOS() == 3) {
            document.getElementById("divTable").style.left = "184px";
        } else {
            document.getElementById("divTable").style.left = "200px";
        }


    });

    function seltypeOnChange() {
        if (form1.seltype.value == "<%=Leaf.TYPE_NONE%>")
            form1.formCode.disabled = true;
        else
            form1.formCode.disabled = false;
    }

    var fieldsMapStr = "";

    function selQuery() {
        openWin("../flow/form_query_list_sel.jsp?type=all", 800, 600);
        fieldsMapStr = "";
    }

    function setRoles(roles, descs) {
        o("queryRole").value = roles;
        o("roleDescs").value = descs;
    }

    function doSelQuery(id, title) {
        if (id == $('#queryId').val())
            return;

        clearCondMap();
        $("#queryId").val(id);
        $("#queryTitle").html(title + "&nbsp;&nbsp;<a href='javascript:;' onClick='clearCondMap();'>×</a>");

        $.ajax({
            type: "POST",
            url: "../visual/module_view_edit.jsp",
            data: "op=getQueryCondField&id=" + id,
            success: function (html) {
                $("#spanQueryField0").html(html);
            },
            error: function (XMLHttpRequest, textStatus) {
                // 请求出错处理
                jAlert(XMLHttpRequest.responseText, "提示");
            }
        });
    }

    $.fn.outerHTML = function () {
        return $("<p></p>").append(this.clone()).html();
    }

    function addFields() {
        if (o("queryId").value == "") {
            jAlert("请先选择查询！", "提示");
            return;
        }

        if (fieldsMapStr == "")
            fieldsMapStr = $("#divField0").outerHTML();
        $("#divFields").append(fieldsMapStr);
    }

    function createCondMap() {
        if (o("queryId").value == "") {
            // alert("请先选择查询！");
            // return;
        }

        var str = "";
        // 查询中的条件字段
        var queryFields = $("select[name='queryField']");

        var map = new Map();
        var queryMap = new Map();
        var isFound = false;
        $("select[name='field']").each(function (i) {
            // 过滤掉为空的字段
            if ($(this).val() != "" && queryFields.eq(i).val() != "") {
                if (!map.containsKey($(this).val()))
                    map.put($(this).val(), $(this).val());
                else {
                    isFound = true;
                    jAlert("表单中的字段 " + $(this).find("option:selected").text() + " 出现重复！", "提示");
                    return "";
                }

                if (!queryMap.containsKey(queryFields.eq(i).val())) {
                    queryMap.put(queryFields.eq(i).val());
                } else {
                    isFound = true;
                    jAlert("查询条件中的字段 " + queryFields.eq(i).find("option:selected").text() + " 出现重复！", "提示");
                    return "";
                }

                if (str == "")
                    str = "\"" + $(this).val() + "\":\"" + queryFields.eq(i).val() + "\"";
                else
                    str += "," + "\"" + $(this).val() + "\":\"" + queryFields.eq(i).val() + "\"";
            }
        })

        if (isFound)
            return "";

        if (str == "") {
            // alert("请选择映射关系！");
            // return "";
        }

        // str += ",\"queryId\":\"" + o("queryId").value + "\"";

        str = "{" + str + "}";

        return str;
    }

</script>
</html>
