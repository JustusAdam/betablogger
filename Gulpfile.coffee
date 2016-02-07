gulp = require 'gulp'
elm = require 'gulp-elm'
cp = require 'child_process'
fs = require 'fs'

gulp.task 'css', ->
    less    = require('gulp-less')
    gulp.src('./less/main.less')
      .pipe(less())
      .pipe(gulp.dest('./dist/css'))


gulp.task 'elm-init', elm.init


gulp.task 'elm', ['elm-init'], ->
    gulp.src('app/Main.elm')
        .pipe(elm.make())
        .pipe(gulp.dest('dist/js/'))


gulp.task 'github-data', (finish) ->
  if not fs.existsSync('blog-data/github-data')
    fs.mkdirSync('blog-data/github-data')

  page = 'https://api.github.com/users/JustusAdam/repos?per_page=100'

  proc = cp.spawn 'curl', [page]

  writer = fs.createWriteStream('blog-data/github-data/JustusAdam.json')

  proc.stdout.pipe writer



gulp.task 'default', ['css', 'elm', 'github-data']


gulp.task 'build', ['css', 'elm']
