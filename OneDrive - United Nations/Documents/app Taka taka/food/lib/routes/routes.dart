enum Routes {
  splashScreen("/"),
  login("/login"),
  superPage("/home"),
  newPost("/post"),
  settings("/settings"),
  editProfile("/editProfile");

  final String path;

  const Routes(this.path);

}