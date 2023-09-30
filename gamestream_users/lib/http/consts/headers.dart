import 'dart:io';

const headersAcceptJson = {
  HttpHeaders.contentTypeHeader: "application/json",
  HttpHeaders.accessControlAllowMethodsHeader: "POST, OPTIONS, GET",
  HttpHeaders.accessControlAllowOriginHeader: "*",
  HttpHeaders.accessControlAllowHeadersHeader: "*",
};

const headersAcceptText = {
  HttpHeaders.contentTypeHeader: "text/plain",
  HttpHeaders.accessControlAllowMethodsHeader: "POST, OPTIONS, GET",
  HttpHeaders.accessControlAllowOriginHeader: "*",
  HttpHeaders.accessControlAllowHeadersHeader: "*",
};