enum Routes {
  splashScreen("/"),
  login("/login"),
  superPage("/home"),
  newPost("/post"),
  editProfile("/editProfile");

  final String path;

  const Routes(this.path);

}