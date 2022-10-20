enum ConnectionStatus {
  None,
  Connecting,
  Connected,
  Done,
  Error,
  Failed_To_Connect,
  Invalid_Connection,
}

enum OperationStatus {
  None,
  Authenticating,
  Creating_Account,
  Logging_Out,
  Opening_Secure_Payment_Session,
  Cancelling_Subscription,
  Updating_Account,
  Changing_Public_Name,
  Loading_Map,
  Saving_Map,
}

enum Region {
  Australia,
  Singapore,
  Brazil,
  Germany,
  South_Korea,
  USA_East,
  USA_West,
  LocalHost,
  Custom,
}