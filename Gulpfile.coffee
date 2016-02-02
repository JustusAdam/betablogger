gulp = require 'gulp'
elm = require 'gulp-elm'

gulp.task 'css', ->
    postcss    = require('gulp-postcss')
    sourcemaps = require('gulp-sourcemaps')

    gulp.src('css/*.css')
        .pipe( sourcemaps.init() )
        .pipe( postcss(
          [ require('autoprefixer')
          , require('precss')
          , require('postcss-font-magician')
          , require('postcss-center')
          , require 'postcss-clearfix'
          ]) )
        .pipe( sourcemaps.write('.') )
        .pipe( gulp.dest('dist/css/') )


gulp.task 'elm-init', elm.init


gulp.task 'elm', ['elm-init'], ->
    gulp.src('app/Main.elm')
        .pipe(elm.make())
        .pipe(gulp.dest('dist/js/'))


gulp.task 'default', ['css', 'elm']
