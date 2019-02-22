(defproject n-grams "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url  "http://www.eclipse.org/legal/epl-v10.html"}
  :repositories [["cloudera" "https://repository.cloudera.com/artifactory/cloudera-repos/"]]
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [com.damballa/parkour "0.6.0"]]
  :main ^:skip-aot ngrams.core
  :target-path "target/%s"
  :profiles {:uberjar  {:aot :all}
             :provided {:dependencies [[org.apache.hadoop/hadoop-client "2.0.0-cdh4.6.0"]]}})
