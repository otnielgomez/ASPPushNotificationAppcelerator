<%@language="JScript" Codepage="65001"%>
<%
var url = "<URL DONDE SE ENCUENTRA>";
var appKey = "<APP KEY>";
var userPush = "<USER>";
var passwordPush = "<PASSWORD>";
var titulo = String(Request.Form("titulo"));
var mensaje = String(Request.Form("mensaje"));
var programado = Request.Form("schedule");
var fecha = Request.Form("date");
var hora = Request.Form("time");
var arrayFecha = String(fecha).split("-");
var arrayHora = String(hora).split(":");
var fechaEnvio = new Date(arrayFecha[0],arrayFecha[1]-1,arrayFecha[2],arrayHora[0],arrayHora[1],00,00);
var mesUTC = fechaEnvio.getUTCMonth()+1;
var fechaEnvio = String(fechaEnvio.getUTCFullYear()+"-"+mesUTC+"-"+fechaEnvio.getUTCDate()+"T"+fechaEnvio.getUTCHours()+":"+fechaEnvio.getUTCMinutes());
//RECIBIMOS JSON DE SESION
var objSrvHTTP, objPOSTDocument, session1;
objSrvHTTP = Server.CreateObject ("Msxml2.ServerXMLHTTP.6.0");
objPOSTDocument = "login="+userPush+"&password="+passwordPush;
objSrvHTTP.open ("POST","https://api.cloud.appcelerator.com/v1/users/login.json?key="+appKey,false);
objSrvHTTP.send (objPOSTDocument);
//Response.ContentType = "text/plain";
session1 = objSrvHTTP.responseText;
var arraySessionId, sessionTokenId;
arraySessionId = String(session1).split('"session_id":"');
arraySessionId = String(arraySessionId[1]).split('"},"');
sessionTokenId = arraySessionId[0];
if (programado == "false") {     
   //INMEDIATAMENTE
   var objSrvHTTPPushNow, objPOSTDocumentPushNow, sessionPush, urlInmediato;
   urlInmediato = "https://api.cloud.appcelerator.com/v1/push_notification/notify.json?key="+appKey+"&_session_id="+String(sessionTokenId);
   objSrvHTTPPushNow = Server.CreateObject ("Msxml2.ServerXMLHTTP.6.0");
   var jsonPayload = '{"title":"'+titulo+'","alert":"'+mensaje+'","icon":"appicon","badge":"","vibrate":true,"sound":"default"}';
   objPOSTDocumentPushNow = "payload="+jsonPayload+"&channel=news_alerts&to_ids=everyone";
   objSrvHTTPPushNow.open ("POST",urlInmediato,false);
   objSrvHTTPPushNow.send (objPOSTDocumentPushNow);
   //Response.ContentType = "text/plain";   
   sessionPush = objSrvHTTPPushNow.responseText;
} else {
   //PROGRAMADO
   var objSrvHTTPPushProgramado, objPOSTDocumentPushProgramado, sessionPush, urlProgramado;
   urlProgramado = "https://api.cloud.appcelerator.com/v1/push_schedules/create.json?key="+appKey+"&_session_id="+String(sessionTokenId);
   objSrvHTTPPushProgramado = Server.CreateObject ("Msxml2.ServerXMLHTTP.6.0");
   var payload = '{"title":"'+titulo+'","alert":"'+mensaje+'","icon":"appicon","badge":"","vibrate":true,"sound":"default"}';
   objPOSTDocumentPushProgramado = 'schedule={"name":"'+titulo+'","start_time":"'+fechaEnvio+'","push_notification":{"payload":'+payload+',"channel":"news_alerts"}}';
   objSrvHTTPPushProgramado.open ("POST",urlProgramado,false);
   objSrvHTTPPushProgramado.send (objPOSTDocumentPushProgramado);
   //Response.ContentType = "text/plain";   
   sessionPush = objSrvHTTPPushProgramado.responseText;
}

var respuesta, mensaje;
respuesta = String(sessionPush).split('"status":"');
respuesta = String(respuesta[1]).split('","method_name"');
respuesta = respuesta[0];

mensaje = String(sessionPush).split('"message":"');
mensaje = String(mensaje[1]).split('","method_name');
mensaje = mensaje[0];
%>
<!DOCTYPE html>
<html>
<head>
   <head>
        <title>Status: <% if (respuesta == "ok"){ Response.write("OK"); }else{ Response.write("FAIL"); }%></title>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
        <link rel="stylesheet" type="text/css" href="<%=url%>/css/bootstrap.min.css" />
        <script type="text/javascript" src="<%=url%>/bootstrap/js/bootstrap.min.js"></script>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
        <script type="text/javascript">
            history.pushState(null, null, location.href);
            window.onpopstate = function(event) {
                history.go(1);
            };
        </script>
    </head>
</head>
<body>
    <div class="container">
        <% if (respuesta == "ok"){ %>
            <div class="row">
                <div class="alert alert-success" role="alert">
                  <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
                  <strong>OhYeah!</strong>
                  Se envio o a quedado programado el mensaje. :D
                </div>
                <div style="margin-top:15px;">
                    Si no eres redirijido en <label id="numero">10</label>, da click <a href="<%=url%>/enviar.asp">aqui</a>
                </div>
            </div>
            <script type="text/javascript">
            var numero, segundos;
                setInterval(function() {
                    numero = parseInt(document.getElementById('numero').innerText);
                    segundos = numero - 1;
                    document.getElementById('numero').innerText = segundos;
                    if (segundos == 1) {
                        window.location = "<%=url%>/enviar.asp"
                    };
                }, 1000);
            </script>
        <% } else { %>
            <div class="row">
                <div class="alert alert-danger" role="alert">
                  <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>
                  <strong>¡Ups!</strong>
                  <%=respuesta%>
                </div>
                <div style="margin-top:15px;">
                    <a href="<%=url%>/enviar.asp">Volver a intentar</a>
                </div>
            </div>
        <% } %>
    </div>
    </body>
</html>
