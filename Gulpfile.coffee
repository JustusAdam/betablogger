gulp = require 'gulp'
elm = require 'gulp-elm'

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


gulp.task 'default', ['css', 'elm']
