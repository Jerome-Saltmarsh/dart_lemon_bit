
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  var handler =
  const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);
  var server = await shelf_io.serve(handler, 'localhost', 8082);
  // Enable content compression
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request){
  final path = request.url.path;
  switch(path){
    case "webhook":
      print("handling webhook");
      return Response.ok('Request for "${request.url}"');
    default:
      print("Cannot handle request $path");
      return Response.ok('Request for "${request.url}"');
  }
}

