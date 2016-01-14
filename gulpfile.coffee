g              = require "gulp"
gulpFilter     = require "gulp-filter"
bower          = require 'bower'
mainBowerFiles = require "main-bower-files"
sass           = require "gulp-sass"
coffee         = require "gulp-coffee"
plumber        = require "gulp-plumber"
del            = require "del"

libs =
  js: [
    'bootstrap/dist/js/*.js'
    'jquery/dist/*.js'
    'jeditable/jquery.jeditable.js'
  ]
  css:    ['bootstrap/dist/css/*.min.css']


g.task "bower-files", ->
  jsFilter = gulpFilter("**/*.js", restore: true)
  cssFilter = gulpFilter("**/*.css")
  g.src mainBowerFiles()
      .pipe jsFilter
      .pipe g.dest("public/js/libs")
      .pipe jsFilter.restore
      .pipe cssFilter
      .pipe g.dest("public/css/libs")

g.task 'compiled', ->
  g.src libs.js.map (e) -> "bower_components/#{e}"
  .pipe g.dest 'public/js/libs/'
  g.src libs.css.map (e) -> "bower_components/#{e}"
  .pipe g.dest 'public/css/libs/'


g.task "css", ->
  g.src "assets/sass/*.scss"
      .pipe plumber()
      .pipe sass()
      .pipe g.dest("public/css")

g.task "js", ->
  g.src "assets/coffee/*.coffee"
      .pipe plumber()
      .pipe coffee()
      .pipe g.dest("public/js")

g.task "clean" , ->
  del [
      "public/js/libs/*"
      "public/css/libs/*"
      "public/js/*.js"
      "public/css/*.css"
  ]

g.task "build"  ,
    [
        "js"
        "css"
    ]

g.task "default", ["clean","build"], ->
  g.watch "assets/coffee/*.coffee" ,["js"]
  g.watch "assets/sass/*.scss" ,["css"]
