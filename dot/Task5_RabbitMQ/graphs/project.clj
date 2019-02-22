(defproject graphs "0.1.0-SNAPSHOT"
  :min-lein-version "2.5.3"

  :dependencies [[org.clojure/clojure "1.8.0"]
                 [org.clojure/clojurescript "1.7.228"]
                 [binaryage/dirac "0.1.3"]
                 [binaryage/devtools "0.5.2"]]

  :plugins [[lein-figwheel "0.5.2"]
            [lein-cljsbuild "1.1.3" :exclusions [[org.clojure/clojure]]]]

  :source-paths ["src"]

  :clean-targets ^{:protect false} ["resources/public/js/compiled" "target"]

  :figwheel {:css-dirs ["resources/public/css"]}

  :repl-options {:init             (do
                                     (require 'dirac.agent)
                                     (dirac.agent/boot!))
                 :port             8230
                 :nrepl-middleware [dirac.nrepl.middleware/dirac-repl]}
  :cljsbuild {:builds
              [{:id           "dev"
                :source-paths ["src"]
                :figwheel     {:on-jsload "graphs.core/on-js-reload"}
                :compiler     {:main                 graphs.core
                               :asset-path           "js/compiled/out"
                               :output-to            "resources/public/js/compiled/graphs.js"
                               :output-dir           "resources/public/js/compiled/out"
                               :source-map-timestamp true}}
               {:id           "min"
                :source-paths ["src"]
                :compiler     {:externs         ["resources/public/c3.min.js"
                                                 "resources/public/d3.min.js"
                                                 "resources/public/config.js"]
                               :main            graphs.core
                               :output-to       "resources/public/js/compiled/graphs.js"
                               :closure-defines {goog.DEBUG false}
                               :optimizations   :advanced
                               :pretty-print    false}}]})