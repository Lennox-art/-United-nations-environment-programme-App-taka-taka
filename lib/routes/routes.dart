enum Routes {
  splashScreen("/"),
  login("/login"),
  superPage("/home"),
  newPost("/post"),
  adminNewPost("/adminPost"),
  editProfile("/editProfile");

  final String path;

  const Routes(this.path);

}