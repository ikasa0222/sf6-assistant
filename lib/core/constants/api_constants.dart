class ApiConstants {
  static const String bucklerBaseUrl = 'https://www.streetfighter.com/6/buckler/zh-hans';
  static const String capcomIdLoginUrl = 'https://cid.capcom.com/';
  static const String bucklerAuthUrl = 'https://www.streetfighter.com/6/buckler/zh-hans';
  
  // Endpoints
  static const String profilePath = '/profile';
  static const String battlelogPath = '/battlelog';
  static const String friendPath = '/friend';
  static const String clubPath = '/club';
  static const String statsUserRatePath = '/stats/userrate';
  static const String framedataPath = '/framedata';
  
  // GitHub Releases Auto-Update
  static const String githubOwner = 'OldSea';
  static const String githubRepo = 'SF6_Assistant';
  static const String githubReleasesApiUrl = 'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';
  static const String githubReleasesWebUrl = 'https://github.com/$githubOwner/$githubRepo/releases/latest';
  static const String githubMirrorProxyPrefix = 'https://ghproxy.net/';
}
