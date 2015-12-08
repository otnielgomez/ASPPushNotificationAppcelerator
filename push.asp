<%@language="JScript" Codepage="65001"%>
<%
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
var appKey = "<APP KEY>";
var userPush = "<USER>";
var passwordPush = "<PASSWORD>";
//RECIBIMOS JSON DE SESION
var objSrvHTTP, objPOSTDocument, session1;
objSrvHTTP = Server.CreateObject ("Msxml2.ServerXMLHTTP.6.0");
objPOSTDocument = "login="+userPush+"&password="+passwordPush;
objSrvHTTP.open ("POST","https://api.cloud.appcelerator.com/v1/users/login.json?key="+appKey,false);
objSrvHTTP.send (objPOSTDocument);
Response.ContentType = "text/plain";
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
   Response.ContentType = "text/plain";   
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
   Response.ContentType = "text/plain";   
   sessionPush = objSrvHTTPPushProgramado.responseText;
}

var respuesta, mensaje;
respuesta = String(sessionPush).split('"status":"');
respuesta = String(respuesta[1]).split('","method_name"');
respuesta = respuesta[0];

mensaje = String(sessionPush).split('"message":"');
mensaje = String(mensaje[1]).split('","method_name');
mensaje = mensaje[0];
if (respuesta == "ok"){
   Response.write("Todo esta bien. El mensaje se a enviado o a quedado programado.");
}else{
   Response.write("ERROR");
}
%>
