(defproject mq "0.1.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.clojure/clojurescript "1.9.227"]
                 [reagent "0.6.0-rc"]
                 [binaryage/devtools "0.8.1"]
                 [re-frame "0.8.0"]
                 [secretary "1.2.3"]
                 [compojure "1.5.1"]
                 [yogthos/config "0.8"]
                 [ring "1.5.0"]
                 [reagent-forms "0.5.25"]
                 [org.clojure/core.match "0.3.0-alpha4"]
                 [com.rpl/specter "0.12.0"]
                 [org.clojure/test.check "0.9.0"]
                 [day8.re-frame/http-fx "0.0.4"]
                 [com.rpl/specter "0.13.0"]
                 [figwheel-sidecar "0.5.0"]]



  :plugins [[lein-cljsbuild "1.1.3"]
            [lein-ancient "0.6.10"]
            [lein-npm "0.6.2"]]


  :npm {:dependencies [[bootstrap "4.0.0-alpha.4"]
                       [codemirror "5.20.2"]
                       [jszip "3.1.3"]
                       [filesaverjs "0.2.2"]
                       [font-awesome "4.6.3"]
                       [phantomjs "2.1.7"]
                       [tether "1.3.7"]]}

  :min-lein-version "2.5.3"

  :source-paths ["src/clj" "script"]

  :clean-targets ^{:protect false} ["resources/public/js/compiled" "target"
                                    "test/js"]

  :figwheel {:css-dirs     ["resources/public/css"]
             :ring-handler mq.handler/dev-handler}

  :profiles
  {:dev
   {:dependencies []

    :plugins      [[lein-doo "0.1.7"]
                   [lein-checkall "0.1.1"]
                   [lein-cljs-externs "0.1.0"]]}}

  :cljsbuild
  {:builds
   [{:id           "dev"
     :source-paths ["src/cljs"]
     :figwheel     {:on-jsload "mq.core/mount-root"}
     :compiler     {:main                 mq.core
                    :output-to            "resources/public/js/compiled/app.js"
                    :output-dir           "resources/public/js/compiled/out"
                    :asset-path           "js/compiled/out"
                    :foreign-libs         [{:file     "node_modules/codemirror/lib/codemirror.js"
                                            :provides ["CodeMirror"]}
                                           {:file     "node_modules/codemirror/mode/octave/octave.js"
                                            :provides ["Octave"]
                                            :requires ["CodeMirror"]}
                                           {:file     "node_modules/jquery/dist/jquery.js"
                                            :file-min "node_modules/jquery/dist/jquery.min.js"
                                            :provides ["JQuery"]}
                                           {:file     "node_modules/jszip/dist/jszip.js"
                                            :file-min "node_modules/jszip/dist/jszip.min.js"
                                            :provides ["JSZip"]}
                                           {:file     "node_modules/filesaverjs/FileSaver.js"
                                            :file-min "node_modules/filesaverjs/FileSaver.min.js"
                                            :provides ["FileSaver"]}
                                           {:file     "node_modules/bootstrap/dist/js/bootstrap.js"
                                            :file-min "node_modules/bootstrap/dist/js/bootstrap.min.js"
                                            :requires ["JQuery" "Tether"]
                                            :provides ["Bootstrap"]}
                                           {:file     "node_modules/tether/dist/js/tether.js"
                                            :file-min "node_modules/tether/dist/js/tether.min.js"
                                            :provides ["Tether"]}]
                    :source-map-timestamp true}}

    {:id           "min"
     :source-paths ["src/cljs"]
     :jar          true
     :compiler     {:main            mq.core
                    :output-to       "resources/public/js/compiled/app.js"
                    :optimizations   :advanced
                    :closure-defines {goog.DEBUG false}
                    :pretty-print    false
                    :foreign-libs    [{:file     "node_modules/codemirror/lib/codemirror.js"
                                       :provides ["CodeMirror"]}
                                      {:file     "node_modules/codemirror/mode/octave/octave.js"
                                       :provides ["Octave"]
                                       :requires ["CodeMirror"]}
                                      {:file     "node_modules/jquery/dist/jquery.js"
                                       :file-min "node_modules/jquery/dist/jquery.min.js"
                                       :provides ["JQuery"]}
                                      {:file     "node_modules/jszip/dist/jszip.js"
                                       :file-min "node_modules/jszip/dist/jszip.min.js"
                                       :provides ["JSZip"]}
                                      {:file     "node_modules/filesaverjs/FileSaver.js"
                                       :file-min "node_modules/filesaverjs/FileSaver.min.js"
                                       :provides ["FileSaver"]}
                                      {:file     "node_modules/bootstrap/dist/js/bootstrap.js"
                                       :file-min "node_modules/bootstrap/dist/js/bootstrap.min.js"
                                       :requires ["JQuery" "Tether"]
                                       :provides ["Bootstrap"]}
                                      {:file     "node_modules/tether/dist/js/tether.js"
                                       :file-min "node_modules/tether/dist/js/tether.min.js"
                                       :provides ["Tether"]}]}}
    {:id           "test"
     :source-paths ["src/cljs" "test/cljs"]
     :compiler     {:output-to     "resources/public/js/compiled/test.js"
                    :main          mq.runner
                    :optimizations :none
                    :foreign-libs  [{:file     "node_modules/codemirror/lib/codemirror.js"
                                     :provides ["CodeMirror"]}
                                    {:file     "node_modules/codemirror/mode/octave/octave.js"
                                     :provides ["Octave"]
                                     :requires ["CodeMirror"]}
                                    {:file     "node_modules/jquery/dist/jquery.js"
                                     :file-min "node_modules/jquery/dist/jquery.min.js"
                                     :provides ["JQuery"]}
                                    {:file     "node_modules/jszip/dist/jszip.js"
                                     :file-min "node_modules/jszip/dist/jszip.min.js"
                                     :provides ["JSZip"]}
                                    {:file     "node_modules/filesaverjs/FileSaver.js"
                                     :file-min "node_modules/filesaverjs/FileSaver.min.js"
                                     :provides ["FileSaver"]}
                                    {:file     "node_modules/bootstrap/dist/js/bootstrap.js"
                                     :file-min "node_modules/bootstrap/dist/js/bootstrap.min.js"
                                     :requires ["JQuery" "Tether"]
                                     :provides ["Bootstrap"]}
                                    {:file     "node_modules/tether/dist/js/tether.js"
                                     :file-min "node_modules/tether/dist/js/tether.min.js"
                                     :provides ["Tether"]}]}}]}


  :main mq.server

  :aot [mq.server]

  :uberjar-name "mq.jar"

  :prep-tasks [["cljsbuild" "once" "min"] "compile"])

