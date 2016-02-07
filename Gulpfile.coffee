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
  child = cp.spawn 'curl', ['https://api.github.com/users/JustusAdam/repos']
  writer = fs.createWriteStream('blog-data/github-data/JustusAdam.json')
  child.stdout.pipe(writer)


gulp.task 'default', ['css', 'elm', 'github-data']
