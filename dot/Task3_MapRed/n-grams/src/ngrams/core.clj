(ns ngrams.core
  (:gen-class)
  (:require [clojure.string :as str]
            [parkour (conf :as conf) (fs :as fs) (mapreduce :as mr)
             (graph :as pg) (toolbox :as ptb) (tool :as tool)]
            [parkour.io (text :as text) (seqf :as seqf)])
  (:import [org.apache.hadoop.io Text]))

(defn n-grams [n sentence]
  (->> (-> sentence count (- n) inc range)
       (map #(subvec sentence % (+ % n)))))

(defn group-ngrams [sentence]
  (let [bi-grams (->>
                   sentence
                   (n-grams 2)
                   (map (fn [[x y]] [(str x " " y) ""])))
        tri-grams (->>
                    sentence
                    (n-grams 3)
                    (map (fn [[x y z]] [(str x " " y) (str x " " y " " z)])))]
    (concat bi-grams tri-grams)))

(defn mapper [coll]
  (->>
    coll
    (mapcat #(->>
                (str/split % #"\P{L}")
                (map str/lower-case)
                (drop 1)
                (filterv (comp not empty?))
                group-ngrams))))

(defn reducer
  {::mr/source-as :keyvalgroups}
  [coll]
  (->>
    coll
    (mapcat
      (fn [[_ vs]]
        (let [freqs (frequencies vs)]
          (->>
            freqs
            (filter (fn [[k _]] (not= k "")))
            (map (fn [[k v]] [k (str v ", " (freqs "") ", " (/ v (freqs "")))]))))))))

(defn tri-grams
  [conf lines]
  (-> (pg/input lines)
      (pg/map #'mapper)
      (pg/partition [Text Text])
      (pg/reduce #'reducer)
      (pg/output (seqf/dsink [Text Text]))
      (pg/fexecute conf `tri-grams)))

(defn tool
  [conf _ inpath & _]
  (->> (text/dseq inpath)
       (tri-grams conf)
       (into {})
       (prn)))

(defn -main
  [& args] (System/exit (tool/run tool args)))