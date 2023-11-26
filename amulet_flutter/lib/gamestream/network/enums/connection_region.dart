enum ConnectionRegion {
  America_North ('https://gamestream-ws-iowa-osbmaezptq-uc.a.run.app'),
  America_South ('https://gamestream-ws-sao-paulo-osbmaezptq-rj.a.run.app'),
  Europe        ('https://gamestream-ws-frankfurt-osbmaezptq-ey.a.run.app'),
  Asia_North    ('https://gamestream-ws-seoul-osbmaezptq-du.a.run.app'),
  Asia_South    ('https://gamestream-ws-singapore-osbmaezptq-as.a.run.app'),
  Oceania       ('https://gamestream-ws-sydney-osbmaezptq-ts.a.run.app'),
  LocalHost     ('http://localhost:8080/'),
  Custom        ('custom');
  final String url;
  const ConnectionRegion(this.url);
}
