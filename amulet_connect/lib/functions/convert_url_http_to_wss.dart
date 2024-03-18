String convertUrlHttpToWSS(String url, {String port = '8080'}) =>
  url.replaceAll('https', 'wss') + '/:$port';