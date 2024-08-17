enum Routes {
  splashScreen("/"),
  login("/login"),
  superPage("/home"),
  timeline("/timeline"),
  wasteEstimation("/wasteEstimation"),
  mvp("/mvp"),
  profile("/profile"),
  notifications("/notifications"),
  users("/users"),
  newPost("/post"),
  adminNewPost("/adminPost"),
  editProfile("/editProfile");

  final String path;

  const Routes(this.path);

}